//
//  *.c
//  async_wake_ios
//
//  Created by George on 18/12/17.
//  Copyright © 2017 Ian Beer. All rights reserved.
//
#include <fcntl.h>
#include <sys/syscall.h>
#include <stdio.h>
//#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/attr.h>
#include <sys/snapshot.h>
#include <mach/mach.h>
#import <dirent.h>
#include "IOKit.h"

#import "patchfinder64.h"
#import "offsets.h"
#import <stdlib.h>
#import <stdio.h>
#include "KernelUtils.h"
#include "PFOffs.h"
#include "kernel_exec.h"
#include "kernel_memory.h"
#include "kernel_memorySP.h"
#include "offsetss3.h"
#include "unlocknvram.h"


#define _assert(test) do { \
if (test) break; \
int saved_errno = errno; \
LOG("_assert(%d:%s)%u[%s]", saved_errno, #test, __LINE__, __FUNCTION__); \
errno = saved_errno; \
goto out; \
} while(false)
#define SafeIOFree(x, size) do { if (KERN_POINTER_VALID(x)) IOFree(x, size); } while(false)
#define SafeIOFreeNULL(x, size) do { SafeIOFree(x, size); (x) = KPTR_NULL; } while(false)



// thx Siguza
typedef struct {
    uint64_t prev;
    uint64_t next;
    uint64_t start;
    uint64_t end;
} kmap_hdr_t;

uint64_t zm_fix_addr1(uint64_t addr) {
    static kmap_hdr_t zm_hdr = {0, 0, 0, 0};
    if (zm_hdr.start == 0) {
        // xxx ReadKernel64(0) ?!
        // uint64_t zone_map_ref = find_zone_map_ref();
        LOG("zone_map_ref: %llx ", GETOFFSET(zone_map_ref));
        uint64_t zone_map = ReadKernel64(GETOFFSET(zone_map_ref));
        LOG("zone_map: %llx ", zone_map);
        // hdr is at offset 0x10, mutexes at start
        size_t r = kreadOwO(zone_map + 0x10, &zm_hdr, sizeof(zm_hdr));
        LOG("zm_range: 0x%llx - 0x%llx (read 0x%zx, exp 0x%zx)", zm_hdr.start, zm_hdr.end, r, sizeof(zm_hdr));
        
        if (r != sizeof(zm_hdr) || zm_hdr.start == 0 || zm_hdr.end == 0) {
            LOG("kread of zone_map failed!");
            exit(EXIT_FAILURE);
        }
        
        if (zm_hdr.end - zm_hdr.start > 0x100000000) {
            LOG("zone_map is too big, sorry.");
            exit(EXIT_FAILURE);
        }
    }
    
    uint64_t zm_tmp = (zm_hdr.start & 0xffffffff00000000) | ((addr) & 0xffffffff);
    
    return zm_tmp < zm_hdr.start ? zm_tmp + 0x100000000 : zm_tmp;
}


uint64_t _vfs_context() {
    static uint64_t vfs_context = 0;
    if (vfs_context == 0) {
        vfs_context = kexecute2(GETOFFSET(vfs_context_current), 1, 0, 0, 0, 0, 0, 0);
        vfs_context = zm_fix_addr1(vfs_context);
    }
    return vfs_context;
}

int _vnode_lookup(const char *path, int flags, uint64_t *vpp, uint64_t vfs_context){
    size_t len = strlen(path) + 1;
    uint64_t vnode = kmem_alloc(sizeof(uint64_t));
    uint64_t ks = kmem_alloc(len);
    kwriteOwO(ks, path, len);
    int ret = (int)kexecute2(GETOFFSET(vnode_lookup), ks, 0, vnode, vfs_context, 0, 0, 0);
    if (ret != ERR_SUCCESS) {
        return -1;
    }
    *vpp = ReadKernel64(vnode);
    kmem_free(ks, len);
    kmem_free(vnode, sizeof(uint64_t));
    return 0;
}

uint64_t vnodeForPath(const char *path) {
    uint64_t vfs_context = 0;
    uint64_t *vpp = NULL;
    uint64_t vnode = 0;
    vfs_context = _vfs_context();
    printf("vfs_context ? = 0x%llx",vfs_context);
    if (!ISADDR(vfs_context)) {
        LOG("Failed to get vfs_context.");
        goto out;
    }
    vpp = malloc(sizeof(uint64_t));
    if (vpp == NULL) {
        LOG("Failed to allocate memory.");
        goto out;
    }
    if (_vnode_lookup(path, O_RDONLY, vpp, vfs_context) != ERR_SUCCESS) {
        LOG("Failed to get vnode at path \"%s\".", path);
        goto out;
    }
    vnode = *vpp;
    out:
    if (vpp != NULL) {
        free(vpp);
        vpp = NULL;
    }
    return vnode;
}

int _vnode_put(uint64_t vnode){
    return (int)kexecute2(GETOFFSET(vnode_put), vnode, 0, 0, 0, 0, 0, 0);
}


#define _assert(test) do { \
if (test) break; \
int saved_errno = errno; \
LOG("_assert(%d:%s)%u[%s]", saved_errno, #test, __LINE__, __FUNCTION__); \
errno = saved_errno; \
goto out; \
} while(false)
#define SafeIOFree(x, size) do { if (KERN_POINTER_VALID(x)) IOFree(x, size); } while(false)
#define SafeIOFreeNULL(x, size) do { SafeIOFree(x, size); (x) = KPTR_NULL; } while(false)
#define get_dirfd(vol) open(vol, O_RDONLY, 0)


const char *find_snapshot_with_ref(const char *vol, const char *ref) {
    int dirfd = get_dirfd(vol);
    
    if (dirfd < 0) {
        perror("get_dirfd");
        return NULL;
    }
    
    struct attrlist alist = { 0 };
    char abuf[2048];
    
    alist.commonattr = ATTR_BULK_REQUIRED;
    
    int count = fs_snapshot_list(dirfd, &alist, &abuf[0], sizeof (abuf), 0);
    close(dirfd);
    
    if (count < 0) {
        perror("fs_snapshot_list");
        return NULL;
    }
    
    char *p = &abuf[0];
    for (int i = 0; i < count; i++) {
        char *field = p;
        uint32_t len = *(uint32_t *)field;
        field += sizeof (uint32_t);
        attribute_set_t attrs = *(attribute_set_t *)field;
        field += sizeof (attribute_set_t);
        
        if (attrs.commonattr & ATTR_CMN_NAME) {
            attrreference_t ar = *(attrreference_t *)field;
            char *name = field + ar.attr_dataoffset;
            field += sizeof (attrreference_t);
            if (strstr(name, ref)) {
                return name;
            }
        }
        
        p += len;
    }
    
    return NULL;
}

kptr_t vnodeForSnapshot(int fd, char *name) {
    kptr_t ret = KPTR_NULL;
    kptr_t snap_vnode, rvpp_ptr, sdvpp_ptr, ndp_buf, sdvpp, snap_meta_ptr, old_name_ptr, ndp_old_name;
    snap_vnode = rvpp_ptr = sdvpp_ptr = ndp_buf = sdvpp = snap_meta_ptr = old_name_ptr = ndp_old_name = KPTR_NULL;
    size_t rvpp_ptr_size, sdvpp_ptr_size, ndp_buf_size, snap_meta_ptr_size, old_name_ptr_size;
    ndp_buf_size = 816;
    rvpp_ptr_size = sdvpp_ptr_size = snap_meta_ptr_size = old_name_ptr_size = sizeof(kptr_t);
    
    rvpp_ptr = IOMalloc(rvpp_ptr_size);
     LOG("rvpp_ptr = " ADDR, rvpp_ptr);
    sdvpp_ptr = IOMalloc(sdvpp_ptr_size);
     LOG("sdvpp_ptr = " ADDR, sdvpp_ptr);
    ndp_buf = IOMalloc(ndp_buf_size);
     LOG("ndp_buf = " ADDR, ndp_buf);
    kptr_t const vfs_context = _vfs_context();
     LOG("vfs_context = " ADDR, vfs_context);
    _assert(kexecute2(GETOFFSET(vnode_get_snapshot), fd, rvpp_ptr, sdvpp_ptr, (kptr_t)name, ndp_buf, 2, vfs_context) == 0);
    sdvpp = ReadKernel64(sdvpp_ptr);
     LOG("sdvpp_ptr = " ADDR, sdvpp_ptr);
    kptr_t const sdvpp_v_mount = ReadKernel64(sdvpp + koffsetS3(KSTRUCT_OFFSET_VNODE_V_MOUNT));
     LOG("sdvpp_v_mount = " ADDR, sdvpp_v_mount);
    kptr_t const sdvpp_v_mount_mnt_data = ReadKernel64(sdvpp_v_mount + koffsetS3(KSTRUCT_OFFSET_MOUNT_MNT_DATA));
     LOG("sdvpp_v_mnt_data = " ADDR, sdvpp_v_mount_mnt_data);
    snap_meta_ptr = IOMalloc(snap_meta_ptr_size);
     LOG("snap_meta_ptr = " ADDR, snap_meta_ptr);
    old_name_ptr = IOMalloc(old_name_ptr_size);
     LOG("old_name_ptr = " ADDR, old_name_ptr);
    ndp_old_name = ReadKernel64(ndp_buf + 336 + 40);
     LOG("ndp_old_name = " ADDR, ndp_old_name);
    kptr_t const ndp_old_name_len = ReadKernel32(ndp_buf + 336 + 48);
     LOG("ndp_old_name_len = " ADDR, ndp_old_name_len);
    _assert(kexecute2(GETOFFSET(fs_lookup_snapshot_metadata_by_name_and_return_name), sdvpp_v_mount_mnt_data, ndp_old_name, ndp_old_name_len, snap_meta_ptr, old_name_ptr, 0, 0) == 0);
    kptr_t const snap_meta = ReadKernel64(snap_meta_ptr);
     LOG("snap_meta = " ADDR, snap_meta);
    if (snap_vnode == 0) {
        snap_vnode = kexecute2(GETOFFSET(apfs_jhash_getvnode), sdvpp_v_mount_mnt_data, ReadKernel32(sdvpp_v_mount_mnt_data + 440), ReadKernel64(snap_meta + 8), 1, 0, 0, 0);
        snap_vnode = zm_fix_addr1(snap_vnode);
        //return snap_vnode;
    }
    //snap_vnode = kexecute2(GETOFFSET(apfs_jhash_getvnode), sdvpp_v_mount_mnt_data, ReadKernel32(sdvpp_v_mount_mnt_data + 0), ReadKernel64(snap_meta + 8), 1, 0, 0, 0);
    
//    snap_vnode = kexecute2(GETOFFSET(apfs_jhash_getvnode), sdvpp_v_mount_mnt_data, ReadKernel32(sdvpp_v_mount_mnt_data + 440), ReadKernel64(snap_meta + 8), 1, 0, 0, 0);
    LOG("snap_vnode = " ADDR, snap_vnode);
    if (snap_vnode != KPTR_NULL) snap_vnode = zm_fix_addr1(snap_vnode);
    _assert(KERN_POINTER_VALID(snap_vnode));
    ret = snap_vnode;
    out:
    if (KERN_POINTER_VALID(sdvpp)) _vnode_put(sdvpp); sdvpp = KPTR_NULL;
    
    
    
    
    SafeIOFreeNULL(sdvpp_ptr, sdvpp_ptr_size);
    SafeIOFreeNULL(ndp_buf, ndp_buf_size);
    SafeIOFreeNULL(snap_meta_ptr, snap_meta_ptr_size);
    SafeIOFreeNULL(old_name_ptr, old_name_ptr_size);
    return ret;
}
