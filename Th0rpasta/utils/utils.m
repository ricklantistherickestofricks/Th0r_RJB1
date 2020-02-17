//
//  utils.m
//  Ziyou
//
//  Created by Brandon Plank on 5/8/19.
//  Copyright © 2019 Ziyou Team. All rights reserved.
//

#define KADD_SEARCH 0xfffffff007004000

#import <Foundation/Foundation.h>
#include <sys/utsname.h>
#include "kernel_memory.h"
#include "lzssdec.h"
#import <UIKit/UIView.h>
#include "find_port.h"
#include "vnode_utils.h"
#include "kernel_structs.h"
#include "utils.h"
#include "shenanigans.h"
#include "common.h"
#include "ms_offs.h"
#include "bypass.h"
#include "KernelUtils.h"
#include "remap_tfp_set_hsp.h"
#include "patchfinder64.h"
#include "parameters.h"
#include "PFOffs.h"
#include "ImportantHolders.h"
#include "kernel_memory.h"
#include "kernel_memorySP.h"
#include "KernelUtils.h"
#include "offsetss3.h"
#include "offsets.h"
#include <sys/mount.h>
#include <spawn.h>
#include <pwd.h>
#include "kernel_exec.h"
#include <copyfile.h>
#include "insert_dylib.h"
#include "cpBootHash.h"
#include "libsnappy.h"
#include <sys/stat.h>
#include <sys/snapshot.h>

#include "ViewController.h"
#include "reboot.h"
#include "amfi_utils.h"
#include "ArchiveUtils.h"
#include "libproc.h"

#include <sys/sysctl.h>
#import "ViewController.h"
//#include "../lib/jelbrekLib.h"


#include "file_utils.h"
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <unistd.h>
#include <errno.h>
#include "oob_timestamp.h"
#include "patchfinder64og.h"





bool runShenPatchOWO = false;
#define kernel_image_base           0xfffffff007004000
#define in_bundle(obj) strdup([[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@obj] UTF8String])

#define SafeFree(x) do { if (x) free(x); } while(false)
#define SafeFreeNULL(x) do { SafeFree(x); (x) = NULL; } while(false)
#define CFSafeRelease(x) do { if (x) CFRelease(x); } while(false)
#define CFSafeReleaseNULL(x) do { CFSafeRelease(x); (x) = NULL; } while(false)
#define SafeSFree(x) do { if (KERN_POINTER_VALID(x)) sfree(x); } while(false)
#define SafeSFreeNULL(x) do { SafeSFree(x); (x) = KPTR_NULL; } while(false)
#define SafeIOFree(x, size) do { if (KERN_POINTER_VALID(x)) IOFree(x, size); } while(false)
#define SafeIOFreeNULL(x, size) do { SafeIOFree(x, size); (x) = KPTR_NULL; } while(false)

#define kCFCoreFoundationVersionNumber_iOS_12_0 1535.12
#define kCFCoreFoundationVersionNumber_iOS_11_3 1452.23
#define kCFCoreFoundationVersionNumber_iOS_11_0 1443.00

#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define SYSTEM_VERSION_BETWEEN_OR_EQUAL_TO(a, b) (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(a) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(b))

#define localize(key) NSLocalizedString(key, @"")
#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]


#define find_offset(x, symbol, critical) do { \
    if (!KERN_POINTER_VALID(getoffset(x))) { \
        setoffset(x, find_symbol(symbol != NULL ? symbol : "_" #x)); \
    } \
    if (!KERN_POINTER_VALID(getoffset(x))) { \
        kptr_t (*_find_ ##x)(void) = dlsym(RTLD_DEFAULT, "find_" #x); \
        if (_find_ ##x != NULL) { \
            setoffset(x, _find_ ##x()); \
        } \
    } \
    if (KERN_POINTER_VALID(getoffset(x))) { \
        LOG(#x " = " ADDR " + " ADDR, getoffset(x), kernel_slide); \
        setoffset(x, getoffset(x) + kernel_slide); \
    } else { \
        setoffset(x, 0); \
        if (critical) { \
            _assert(false, localize(@"Unable to find kernel offset for " #x), true); \
        } \
    } \
} while (false)

#define localizeEE(key) NSLocalizedString(key, @"")


char *sysctlWithName(const char *name) {
    kern_return_t kr = KERN_FAILURE;
    char *ret = NULL;
    size_t *size = NULL;
    size = (size_t *)malloc(sizeof(size_t));
    if (size == NULL) goto out;
    bzero(size, sizeof(size_t));
    if (sysctlbyname(name, NULL, size, NULL, 0) != ERR_SUCCESS) goto out;
    ret = (char *)malloc(*size);
    if (ret == NULL) goto out;
    bzero(ret, *size);
    if (sysctlbyname(name, ret, size, NULL, 0) != ERR_SUCCESS) goto out;
    kr = KERN_SUCCESS;
    out:
    if (kr == KERN_FAILURE)
    {
        free(ret);
        ret = NULL;
    }
    free(size);
    size = NULL;
    return ret;
}

bool machineNameContains(const char *string) {
    char *machineName = sysctlWithName("hw.machine");
    if (machineName == NULL) return false;
    bool ret = strstr(machineName, string) != NULL;
    free(machineName);
    machineName = NULL;
    return ret;
}

NSString *getKernelBuildVersion() {
    NSString *kernelBuild = nil;
    NSString *cleanString = nil;
    char *kernelVersion = NULL;
    kernelVersion = sysctlWithName("kern.version");
    if (kernelVersion == NULL) return nil;
    cleanString = [NSString stringWithUTF8String:kernelVersion];
    free(kernelVersion);
    kernelVersion = NULL;
    cleanString = [[cleanString componentsSeparatedByString:@"; "] objectAtIndex:1];
    cleanString = [[cleanString componentsSeparatedByString:@"-"] objectAtIndex:1];
    cleanString = [[cleanString componentsSeparatedByString:@"/"] objectAtIndex:0];
    kernelBuild = [cleanString copy];
    return kernelBuild;
}

bool supportsExploit(int exploit) {

    
    //0 = MachSwap
    //1 = MachSwap2
    //2 = Voucher_Swap
    //3 = SockPuppet
    
    vm_size_t kernel_page_size = 0;
    vm_size_t *out_page_size = NULL;
    host_t host = mach_host_self();
    if (!MACH_PORT_VALID(host)) goto out;
    out_page_size = (vm_size_t *)malloc(sizeof(vm_size_t));
    if (out_page_size == NULL) goto out;
    bzero(out_page_size, sizeof(vm_size_t));
    if (_host_page_size(host, out_page_size) != KERN_SUCCESS) goto out;
    kernel_page_size = *out_page_size;
    out:
    if (MACH_PORT_VALID(host)) mach_port_deallocate(mach_task_self(), host); host = HOST_NULL;
    free(out_page_size);
    out_page_size = NULL;
    
    NSString *minKernelBuildVersion = nil;
    NSString *maxKernelBuildVersion = nil;
    
    switch (exploit) {

        case 0: {
            if (kernel_page_size != 0x1000 &&
                !machineNameContains("iPad5,") &&
                !machineNameContains("iPhone8,") &&
                !machineNameContains("iPad6,")) {
                break;
            }
            minKernelBuildVersion = @"4397.0.0.2.4~1";
            maxKernelBuildVersion = @"4903.240.8~8";
            break;
        }
        case 1: {
            minKernelBuildVersion = @"4397.0.0.2.4~1";
            maxKernelBuildVersion = @"4903.240.8~8";
            break;
        }
        case 2: {
            if (kernel_page_size != 0x4000) {
                return false;
            }
            if (machineNameContains("iPad5,") &&
                kCFCoreFoundationVersionNumber >= 1535.12) {
                return false;
            }
            minKernelBuildVersion = @"4397.0.0.2.4~1";
            maxKernelBuildVersion = @"4903.240.8~8";
            break;
        }
        default:
            return false;
            break;
    }
    
    if (minKernelBuildVersion != nil && maxKernelBuildVersion != nil) {
        NSString *kernelBuildVersion = getKernelBuildVersion();
        if (kernelBuildVersion != nil) {
            if ([kernelBuildVersion compare:minKernelBuildVersion options:NSNumericSearch] != NSOrderedAscending && [kernelBuildVersion compare:maxKernelBuildVersion options:NSNumericSearch] != NSOrderedDescending) {
                return true;
            }
        }
    } else {
        return true;
    }
    
    return false;
}


int autoSelectExploit()
{
    
    
    
    //0 = MachSwap
    //1 = MachSwap2
    //2 = Voucher_Swap
    //3 = SockPuppet
    if (supportsExploit(0))
    {
        return 0;
    } else if (supportsExploit(1))
    {
        return 1;
    } else if (supportsExploit(2))
    {
        return 2;
    } else {
        return 3;
    }
    
}

uint64_t set_csflags(uint64_t proc) {
    
    uint32_t csflags = ReadKernel32(proc + koffsetS3(KSTRUCT_OFFSET_PROC_P_CSFLAGS));
    //off_p_csflags);//664
    printf("csflags                      = 0x%x\n",csflags);
    csflags |= CS_PLATFORM_BINARY;
    printf("csflags w/CS_PLATFORM_BINARY = 0x%x\n",csflags);

    WriteKernel32(proc + koffsetS3(KSTRUCT_OFFSET_PROC_P_CSFLAGS), csflags);
    return 0;
    
}

NSString *getNameFromInt(int exp_int)
{
    if (exp_int == 0)
    {
        return @"oob timestamp";
    } else if (exp_int == 1)
    {
        return @"oob timestamp";
    } else if (exp_int == 2)
    {
        return @"oob timestamp";
    } else if (exp_int == 3)
    {
        return @"oob timestamp";
    } else {
        return @"ERROR";
    }
}

void initSettingsIfNotExist()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"ExploitType"] == nil)
    {
        [defaults setInteger:0 forKey:@"ExploitType"];
        [defaults setInteger:0 forKey:@"PackagerType"];
        [defaults setInteger:0 forKey:@"LoadTweaks"];
        [defaults setInteger:1 forKey:@"RestoreFS"];
        [defaults setInteger:0 forKey:@"RootSetting"];
        [defaults setValue:@"0x1111111111111111" forKey:@"Nonce"];
        [defaults setInteger:1 forKey:@"SetNonce"];
        [defaults synchronize];
        
        if ([getNameFromInt(autoSelectExploit())  isEqual: @"ERROR"])
        {
            showMSG(@"There was an error automatically selecting your exploit. The default has been set to machswap. Please change this under settings if you would like to use a different one.", false, false);
        } else {
            NSString *msgString = [NSString stringWithFormat:@"First run? automatically selected the best exploit for your device. The exploit chosen is %@. If this doesn't work for your device, please change it under the settings menu and try the other.", getNameFromInt(autoSelectExploit())];
            
            showMSG(msgString, false, false);
            
            [defaults setInteger:autoSelectExploit() forKey:@"ExploitType"];
        }
        
        
    }
}


NSString* getBootNonce()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:@"Nonce"];
}

void saveCustomSetting(NSString *setting, int settingResult)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:settingResult forKey:setting];
}

BOOL shouldLoadTweaks()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"LoadTweaks"] == 0)
    {
        return true;
    } else {
        return false;
    }
}

int getExploitType()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[defaults integerForKey:@"ExploitType"];
}

int getPackagerType()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[defaults integerForKey:@"PackagerType"];
}

BOOL shouldRestoreFS()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"RestoreFS"] == 0)
    {
        //restoreyofs();
        return true;
    } else {
        //justJByo();
        return false;
    }
}


uint64_t selfproc() {
    // TODO use kcall(proc_find) + ZM_FIX_ADDR
    uint64_t proc = 0;
    if (proc == 0) {
        proc = ReadKernel64(current_task_OOB + OFFSET(task, bsd_info));
        NSLog(@"Found proc 0x%llx for PID %i", proc, getpid());    }
    return proc;
}

uint64_t fport(mach_port_name_t port)
{
    uint64_t task_port_addr = find_port_SP(mach_task_self(), MACH_MSG_TYPE_COPY_SEND);;//task_self_addr();
    //uint64_t task_port_addr = find_port_address_(mach_task_self(), MACH_MSG_TYPE_COPY_SEND);;//task_self_addr();
    uint64_t task_addr = ReadKernel64(task_port_addr + koffsetS3(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
    uint64_t itk_space = ReadKernel64(task_addr + OFFSET(task, itk_space));
    uint64_t is_table = ReadKernel64(itk_space + OFFSET(ipc_space, is_table));
    uint32_t port_index = port >> 8;
    const int sizeof_ipc_entry_t = 0x18;
    uint64_t port_addr = ReadKernel64(is_table + (port_index * sizeof_ipc_entry_t));
    return port_addr;
}


uint64_t platformize(uint64_t proc) {
/* */
    uint64_t task = ReadKernel64(proc + off_task);
    uint32_t t_flags = ReadKernel32(task + off_t_flags);
    t_flags |= 0x400;
    WriteKernel32(task+off_t_flags, t_flags);
    uint32_t csflags = ReadKernel32(proc + off_p_csflags);
    WriteKernel32(proc + off_p_csflags, csflags | 0x24004001u);
    return 0;
}

uint64_t setcsflags(uint64_t proc) {
    uint32_t csflags = ReadKernel32(proc + off_p_csflags);
    uint32_t newflags = (csflags | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW | CS_DEBUGGED) & ~(CS_RESTRICT | CS_HARD | CS_KILL);
    WriteKernel32(proc + off_p_csflags, newflags);
    return 0;
}



//V_SWAP



void runoobtime() {
    uint64_t kernel_base;
    uint64_t kernel_slide;

    extern uint64_t thebaserose;
    mach_port_t run334me;
    oob_timestamp();
    printf("kernel_task_port = 0x%x\n", kernel_task_port);

    
    tfp0 = kernel_task_port;
    run334me = tfp0;
    
    if (run334me ==0){
        exit(1);//tfp0 = run334me;//fakeKernelTaskPort
    }
    kernel_slide = basefromkernelmemory - kernel_image_base;
    
    kbase = basefromkernelmemory;
    printf("basefromkernelmemory kernel base: 0x%llx\n", basefromkernelmemory);
    printf("kernel_slide: 0x%llx\n", kernel_slide);

    if (tfp0 == 0){
          printf("failed to run exploit\n");
    }
    if (MACH_PORT_VALID(tfp0)) {
        
        kbase = basefromkernelmemory;//(kernel_slide + KADD_SEARCH);
        
        set_selfproc(current_proc_OOB);
        runShenPatchOWO = true;
        
    } else {
        LOG("ERROR!");
        exit(1);
    }
    
    NSLog(@"%@", [NSString stringWithFormat:@"TFP0: 0x%x", tfp0]);
    NSLog(@"%@", [NSString stringWithFormat:@"KERNEL BASE: 0x%llx", kbase]);
    NSLog(@"%@", [NSString stringWithFormat:@"KERNEL SLIDE: 0x%06llx", kernel_slide]);
    
    NSLog(@"UID: %u", getuid());
    NSLog(@"GID: %u", getgid());
    
}
void labelchange(){
    [[ViewController sharedController] labelchange];
}

void runExploit(int expType)
{
    //0 = MachSwap
    //1 = MachSwap2
    //2 = Voucher_Swap
    //3 = SockPuppet
    if (expType == 0)
    {
        LOG("Running oobtimestamp...");
        runoobtime();
        if (MACH_PORT_VALID(kernel_task_port))
        {
            set_tfp0(kernel_task_port);
            //labelchange();
            //NSString *str = [NSString stringWithFormat:@"TFP0: 0x%x", tfp0];
            //[NSString stringWithUTF8String:u.machine];
           // NSString *msglabelscroll = [NSString stringWithFormat:localize(@"getuid = %d"), getuid()];
            //[UI labeloutput1 setText:(msglabelscroll)];
            //showMSG(str, true, false);
        }
    } else {
        LOG("Running oobtimestamp...");
        runoobtime();
        if (MACH_PORT_VALID(kernel_task_port))
        {
            set_tfp0(kernel_task_port);
            /*NSString *str = [NSString stringWithFormat:@"TFP0: 0x%x", tfp0];
            showMSG(str, true, false);
             */
            
        }
        //LOG("No Exploit? Tf...");
        //exit(1);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


NSString *get_path_res(NSString *resource) {
    static NSString *sourcePath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sourcePath = [[NSBundle mainBundle] bundlePath];
    });
    
    NSString *path = [[sourcePath stringByAppendingPathComponent:resource] stringByStandardizingPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    return path;
}

NSString *get_bootstrap_file(NSString *file)
{
    return get_path_res([@"bootstrap/" stringByAppendingString:file]);
}

NSString *get_debian_file(NSString *file)
{
    return get_path_res([@"bootstrap/DEBS/" stringByAppendingString:file]);
}

bool canRead(const char *file) {
    NSString *path = @(file);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return ([fileManager attributesOfItemAtPath:path error:nil]);
}

static void *load_bytes2(FILE *obj_file, off_t offset, uint32_t size) {
    void *buf = calloc(1, size);
    fseek(obj_file, offset, SEEK_SET);
    fread(buf, size, 1, obj_file);
    return buf;
}

static inline bool clean_file(const char *file) {
    NSString *path = @(file);
    if ([[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return YES;
}

uint32_t find_macho_header(FILE *file) {
    uint32_t off = 0;
    uint32_t *magic = load_bytes2(file, off, sizeof(uint32_t));
    while ((*magic & ~1) != 0xFEEDFACE) {
        off++;
        magic = load_bytes2(file, off, sizeof(uint32_t));
    }
    return off - 1;
}

static inline bool createFile(const char *file, int owner, mode_t mode) {
    NSString *path = @(file);
    return ([[NSFileManager defaultManager] fileExistsAtPath:path] &&
            [[NSFileManager defaultManager] setAttributes:@{NSFileOwnerAccountID: @(owner), NSFileGroupOwnerAccountID: @(owner), NSFilePosixPermissions: @(mode)} ofItemAtPath:path error:nil]);
}

bool ensure_directory(const char *directory, int owner, mode_t mode) {
    NSString *path = @(directory);
    NSFileManager *fm = [NSFileManager defaultManager];
    id attributes = [fm attributesOfItemAtPath:path error:nil];
    if (attributes &&
        [attributes[NSFileType] isEqual:NSFileTypeDirectory] &&
        [attributes[NSFileOwnerAccountID] isEqual:@(owner)] &&
        [attributes[NSFileGroupOwnerAccountID] isEqual:@(owner)] &&
        [attributes[NSFilePosixPermissions] isEqual:@(mode)]
        ) {
        // Directory exists and matches arguments
        return true;
    }
    if (attributes) {
        if ([attributes[NSFileType] isEqual:NSFileTypeDirectory]) {
            // Item exists and is a directory
            return [fm setAttributes:@{
                                       NSFileOwnerAccountID: @(owner),
                                       NSFileGroupOwnerAccountID: @(owner),
                                       NSFilePosixPermissions: @(mode)
                                       } ofItemAtPath:path error:nil];
        } else if (![fm removeItemAtPath:path error:nil]) {
            // Item exists and is not a directory but could not be removed
            return false;
        }
    }
    // Item does not exist at this point
    return [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{
                                                                                       NSFileOwnerAccountID: @(owner),
                                                                                       NSFileGroupOwnerAccountID: @(owner),
                                                                                       NSFilePosixPermissions: @(mode)
                                                                                       } error:nil];
}



bool is_mountpoint(const char *filename) {
    struct stat buf;
    if (lstat(filename, &buf) != ERR_SUCCESS) {
        return false;
    }
    
    if (!S_ISDIR(buf.st_mode))
        return false;
    
    char *cwd = getcwd(NULL, 0);
    int rv = chdir(filename);
    assert(rv == ERR_SUCCESS);
    struct stat p_buf;
    rv = lstat("..", &p_buf);
    assert(rv == ERR_SUCCESS);
    if (cwd) {
        chdir(cwd);
        free(cwd);
    }
    return buf.st_dev != p_buf.st_dev || buf.st_ino == p_buf.st_ino;
}




uint64_t set_tfplatform(uint64_t proc) {
    // task.t_flags & TF_PLATFORM
    uint64_t task = ReadKernel64(proc + off_task);
    uint32_t t_flags = ReadKernel32(task + off_t_flags);
    t_flags |= 0x400;
    WriteKernel32(task+off_t_flags, t_flags);
    return 0;
}






kptr_t swap_sandbox(kptr_t proc, kptr_t sandbox) {
    kptr_t ret = KPTR_NULL;
    kptr_t const ucred = ReadKernel64(proc + OFFSET(proc, p_ucred));
    kptr_t const cr_label = ReadKernel64(ucred + koffsetS3(KSTRUCT_OFFSET_UCRED_CR_LABEL));
    kptr_t const sandbox_addr = cr_label + 0x8 + 0x8;
    kptr_t const current_sandbox = ReadKernel64(sandbox_addr);
    WriteKernel64(sandbox_addr, sandbox);
    ret = current_sandbox;
    out:;
    return ret;
}





void setGID(gid_t gid, uint64_t proc) {
    if (getgid() == gid) return;
    uint64_t ucred = ReadKernel64(proc + OFFSET(proc, p_ucred));// off_p_ucred);
    WriteKernel32(proc + off_p_gid, gid);
    WriteKernel32(proc + off_p_rgid, gid);
    WriteKernel32(ucred + off_ucred_cr_rgid, gid);
    WriteKernel32(ucred + off_ucred_cr_svgid, gid);
    NSLog(@"Overwritten GID to %i for proc 0x%llx", gid, proc);
}

void setUID (uid_t uid, uint64_t proc) {
    if (getuid() == uid) return;
    uint64_t ucred = ReadKernel64(proc + OFFSET(proc, p_ucred));
    WriteKernel32(proc + off_p_uid, uid);
    WriteKernel32(proc + off_p_ruid, uid);
    WriteKernel32(ucred + off_ucred_cr_uid, uid);
    WriteKernel32(ucred + off_ucred_cr_ruid, uid);
    WriteKernel32(ucred + off_ucred_cr_svuid, uid);
    NSLog(@"Overwritten UID to %i for proc 0x%llx", uid, proc);
}

extern char **environ;
NSData *lastSystemOutput=nil;
int execCmdV(const char *cmd, int argc, const char * const* argv, void (^unrestrict)(pid_t)) {
    pid_t pid;
    posix_spawn_file_actions_t *actions = NULL;
    posix_spawn_file_actions_t actionsStruct;
    int out_pipe[2];
    bool valid_pipe = false;
    posix_spawnattr_t *attr = NULL;
    posix_spawnattr_t attrStruct;
    
    NSMutableString *cmdstr = [NSMutableString stringWithCString:cmd encoding:NSUTF8StringEncoding];
    for (int i=1; i<argc; i++) {
        [cmdstr appendFormat:@" \"%s\"", argv[i]];
    }
    
    valid_pipe = pipe(out_pipe) == ERR_SUCCESS;
    if (valid_pipe && posix_spawn_file_actions_init(&actionsStruct) == ERR_SUCCESS) {
        actions = &actionsStruct;
        posix_spawn_file_actions_adddup2(actions, out_pipe[1], 1);
        posix_spawn_file_actions_adddup2(actions, out_pipe[1], 2);
        posix_spawn_file_actions_addclose(actions, out_pipe[0]);
        posix_spawn_file_actions_addclose(actions, out_pipe[1]);
    }
    
    if (unrestrict && posix_spawnattr_init(&attrStruct) == ERR_SUCCESS) {
        attr = &attrStruct;
        posix_spawnattr_setflags(attr, POSIX_SPAWN_START_SUSPENDED);
    }
    
    int rv = posix_spawn(&pid, cmd, actions, attr, (char *const *)argv, environ);
    LOG("%s(%d) command: %@", __FUNCTION__, pid, cmdstr);
    
    if (unrestrict) {
        unrestrict(pid);
        kill(pid, SIGCONT);
    }
    
    if (valid_pipe) {
        close(out_pipe[1]);
    }
    
    if (rv == ERR_SUCCESS) {
        if (valid_pipe) {
            NSMutableData *outData = [NSMutableData new];
            char c;
            char s[2] = {0, 0};
            NSMutableString *line = [NSMutableString new];
            while (read(out_pipe[0], &c, 1) == 1) {
                [outData appendBytes:&c length:1];
                if (c == '\n') {
                    LOG("%s(%d): %@", __FUNCTION__, pid, line);
                    [line setString:@""];
                } else {
                    s[0] = c;
                    [line appendString:@(s)];
                }
            }
            if ([line length] > 0) {
                LOG("%s(%d): %@", __FUNCTION__, pid, line);
            }
            lastSystemOutput = [outData copy];
        }
        if (waitpid(pid, &rv, 0) == -1) {
            LOG("ERROR: Waitpid failed");
        } else {
            LOG("%s(%d) completed with exit status %d", __FUNCTION__, pid, WEXITSTATUS(rv));
        }
        
    } else {
        LOG("%s(%d): ERROR posix_spawn failed (%d): %s", __FUNCTION__, pid, rv, strerror(rv));
        rv <<= 8; // Put error into WEXITSTATUS
    }
    if (valid_pipe) {
        close(out_pipe[0]);
    }
    return rv;
}

int execCmd(const char *cmd, ...) {
    va_list ap, ap2;
    int argc = 1;
    
    va_start(ap, cmd);
    va_copy(ap2, ap);
    
    while (va_arg(ap, const char *) != NULL) {
        argc++;
    }
    va_end(ap);
    
    const char *argv[argc+1];
    argv[0] = cmd;
    for (int i=1; i<argc; i++) {
        argv[i] = va_arg(ap2, const char *);
    }
    va_end(ap2);
    argv[argc] = NULL;
    
    int rv = execCmdV(cmd, argc, argv, NULL);
    return WEXITSTATUS(rv);
}

uint64_t getKernproc()
{
    uint64_t kernproc = 0x0;
    while (kernproc != 0x0)
    {
        uint32_t found_pid = ReadKernel32(kernproc + off_p_pid);
        if (found_pid == 0)
        {
            break;
        }
        
        /*
         kernproc will always be at the start of the linked list,
         so we loop backwards in order to find it
         */
        kernproc = ReadKernel64(kernproc + 0x0);
    }
    
    LOG("GOT KERNPROC AT: %llx", kernproc);
    return kernproc;
}

void rootMe(uint64_t proc) {
    uint64_t ucred = ReadKernel64(proc + off_p_ucred);
    WriteKernel32(proc + off_p_uid, 0);
    WriteKernel32(proc + off_p_ruid, 0);
    WriteKernel32(proc + off_p_gid, 0);
    WriteKernel32(proc + off_p_rgid, 0);
    WriteKernel32(ucred + off_ucred_cr_uid, 0);
    WriteKernel32(ucred + off_ucred_cr_ruid, 0);
    WriteKernel32(ucred + off_ucred_cr_svuid, 0);
    WriteKernel32(ucred + off_ucred_cr_ngroups, 1);
    WriteKernel32(ucred + off_ucred_cr_groups, 0);
    WriteKernel32(ucred + off_ucred_cr_rgid, 0);
    WriteKernel32(ucred + off_ucred_cr_svgid, 0);
}

void unsandbox(uint64_t proc) {
    NSLog(@"Unsandboxed proc 0x%llx", proc);
    uint64_t ucred = ReadKernel64(proc + off_p_ucred);
    uint64_t cr_label = ReadKernel64(ucred + off_ucred_cr_label);
    WriteKernel64(cr_label + off_sandbox_slot, 0);
}

void list_all_snapshots(const char **snapshots, const char *origfs, bool has_origfs)
{
    for (const char **snapshot = snapshots; *snapshot; snapshot++) {
        if (strcmp(origfs, *snapshot) == 0) {
            has_origfs = true;
        }
        LOG("%s", *snapshot);
    }
}

int waitFF(const char *filename) {
    int rv = 0;
    rv = access(filename, F_OK);
    for (int i = 0; !(i >= 100 || rv == ERR_SUCCESS); i++) {
        usleep(100000);
        rv = access(filename, F_OK);
    }
    return rv;
}



bool mod_plist_file(NSString *filename, void (^function)(id)) {
    NSData *data = [NSData dataWithContentsOfFile:filename];
    if (data == nil) {
        return false;
    }
    NSPropertyListFormat format = 0;
    NSError *error = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    if (plist == nil) {
        return false;
    }
    if (function) {
        function(plist);
    }
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList:plist format:format options:0 error:&error];
    if (newData == nil) {
        return false;
    }
    if (![data isEqual:newData]) {
        if (![newData writeToFile:filename atomically:YES]) {
            return false;
        }
    }
    LOG("%s: Success", __FUNCTION__);
    return true;
}

void restoreRootFS()
{
    struct passwd *const root_pw = getpwnam("root");
    littlewienners();
    LOG("Restoring RootFS....");
    int const rootfd = open("/", O_RDONLY);
    _assert(rootfd > 0, localize(@"Unable to open RootFS."), true);
    const char **snapshots = snapshot_list(rootfd);
    _assert(snapshots != NULL, localize(@"Unable to get snapshots for RootFS."), true);
    _assert(*snapshots != NULL, localize(@"Found no snapshot for RootFS."), true);
    char *snapshot = strdup(*snapshots);
    LOG("%s", snapshot);
    _assert(snapshot != NULL, localize(@"Unable to find original snapshot for RootFS."), true);
    char *systemSnapshot = copySystemSnapshot();
    _assert(systemSnapshot != NULL, localize(@"Unable to copy system snapshot."), true);
    _assert(fs_snapshot_rename(rootfd, snapshot, systemSnapshot, 0) == ERR_SUCCESS, localize(@"Unable to rename original snapshot."), true);
    
    free(snapshot);
    snapshot = NULL;
    
    snapshot = strdup(systemSnapshot);
    _assert(snapshot != NULL, localize(@"Unable to duplicate string."), true);
    
    free(systemSnapshot);
    systemSnapshot = NULL;

    char *const systemSnapshotMountPoint = "/private/var/tmp/jb/mnt2";
    if (is_mountpoint(systemSnapshotMountPoint)) {
        _assert(unmount(systemSnapshotMountPoint, MNT_FORCE) == ERR_SUCCESS, localize(@"Unable to unmount old snapshot mount point."), true);
    }
    _assert(clean_file(systemSnapshotMountPoint), localize(@"Unable to clean old snapshot mount point."), true);
    _assert(ensure_directory(systemSnapshotMountPoint, root_pw->pw_uid, 0755), localize(@"Unable to create snapshot mount point."), true);
    _assert(fs_snapshot_mount(rootfd, systemSnapshotMountPoint, snapshot, 0) == ERR_SUCCESS, localize(@"Unable to mount original snapshot."), true);
    const char *systemSnapshotLaunchdPath = [@(systemSnapshotMountPoint) stringByAppendingPathComponent:@"sbin/launchd"].UTF8String;
    _assert(waitFF(systemSnapshotLaunchdPath) == ERR_SUCCESS, localize(@"Unable to verify mounted snapshot."), true);
    extractFile(get_bootstrap_file(@"restoreUtils.tar"), @"/");
    cleaningshit();

    _assert(execCmd("/usr/bin/rsync", "-vaxcH", "--progress", "--delete", [@(systemSnapshotMountPoint) stringByAppendingPathComponent:@"Applications/."].UTF8String, "/Applications", NULL) == 0, localize(@"Unable to sync /Applications."), true);
    _assert(unmount(systemSnapshotMountPoint, MNT_FORCE) == ERR_SUCCESS, localize(@"Unable to unmount original snapshot mount point."), true);
    close(rootfd);
    
    free(snapshot);
    snapshot = NULL;
    
    free(snapshots);
    snapshots = NULL;
    
    _assert(execCmd("/usr/bin/uicache", NULL) >= 0, localize(@"Unable to refresh icon cache."), true);
    _assert(clean_file("/usr/bin/uicache"), localize(@"Unable to clean uicache binary."), true);
    _assert(clean_file("/usr/bin/find"), localize(@"Unable to clean find binary."), true);
    LOG("Successfully reverted back RootFS remount.");
    
    // Clean up.
    
    LOG("Cleaning up...");
    NSArray *const cleanUpFileList = @[@"/var/cache",
                                       @"/var/lib",
                                       @"/Library/TweakInject",
                                       @"/Library/MobileSubstrate",
                                       @"/usr/lib/MobileSubstrate",
                                       @"/usr/lib/TweakInject",
                                       @"/usr/lib/TweakInject.dylib",
                                       @"/usr/lib/TweakInject",
                                       @"/usr/lib/TweakInject.bak",
                                       @"/var/stash",
                                       @"/var/db/stash",
                                       @"/var/mobile/Library/Cydia",
                                       @"/var/mobile/Library/Caches/com.saurik.Cydia",
                                       @"/etc/apt/sources.list.d",
                                       @"/etc/apt/sources.list",
                                       @"/.ziyou_installed",
                                       @"/.ziyou_bootstrap"];
    for (id file in cleanUpFileList) {
        clean_file([file UTF8String]);
    }
    
    
    //Dude, really?
    [[NSFileManager defaultManager] removeItemAtPath:@"etc/apt/sources.list.d" error:nil];
    
    
    LOG("Successfully cleaned up.");
    
    // Disallow SpringBoard to show non-default system apps.

    
    LOG("Disallowing SpringBoard to show non-default system apps...");
    _assert(mod_plist_file(@"/var/mobile/Library/Preferences/com.apple.springboard.plist", ^(id plist) {
        plist[@"SBShowNonDefaultSystemApps"] = @NO;
    }), localize(@"Unable to update SpringBoard preferences."), true);
    LOG("Successfully disallowed SpringBoard to show non-default system apps.");
    
    
    disableRootFS();
    
    char *targettype = sysctlWithName("hw.targettype");
    _assert(targettype != NULL, localize(@"Unable to get hardware targettype."), true);
    NSString *const jetsamFile = [NSString stringWithFormat:@"/System/Library/LaunchDaemons/com.apple.jetsamproperties.%s.plist", targettype];
    free(targettype);
    targettype = NULL;
    _assert(mod_plist_file(jetsamFile, ^(id plist) {
        plist[@"Version4"][@"System"][@"Override"][@"Global"][@"UserHighWaterMark"] = nil;
    }), localize(@"Unable to update Jetsam plist to restore memory limit."), true);

    
    LOG("Rebooting...");
    showMSG(NSLocalizedString(@"Cleaned out some Jailbreak files! rebooting your device.", nil), 1, 1);
    reboot(RB_QUICK);
    
    
}


int trust_file(NSString *path) {
    NSMutableArray *paths = [NSMutableArray new];
    [paths addObject:path];
    //inject_trusts(paths, pmap_load_trust_cache);
    //0xfffffff00722bb74
    //injectTrustCache(paths,  0xfffffff00722bb74, pmap_load_trust_cache);
    injectTrustCache(paths, GETOFFSET(trustcache), pmap_load_trust_cache);
    return 0;
}




void preMountFS(const char *thedisk, int root_fs, const char **snapshots, const char *origfs)
{
    LOG("Pre-Mounting RootFS...");

    _assert(!is_mountpoint("/var/MobileSoftwareUpdate/mnt1"), invalidRootMessage, true);
    char *const rootFsMountPoint = "/private/var/tmp/jb/mnt1";
    if (is_mountpoint(rootFsMountPoint)) {
        _assert(unmount(rootFsMountPoint, MNT_FORCE) == ERR_SUCCESS, localize(@"Unable to unmount old RootFS mount point."), true);
    }
    _assert(clean_file(rootFsMountPoint), localize(@"Unable to clean old RootFS mount point."), true);
    char *const hardwareMountPoint = "/private/var/hardware";
    if (is_mountpoint(hardwareMountPoint)) {
        _assert(unmount(hardwareMountPoint, MNT_FORCE) == ERR_SUCCESS, localize(@"Unable to unmount hardware mount point."), true);
    }
    _assert(ensure_directory(rootFsMountPoint, 0, 0755), localize(@"Unable to create RootFS mount point."), true);
    const char *argv[] = {"/sbin/mount_apfs", thedisk, rootFsMountPoint, NULL};
    _assert(execCmdV(argv[0], 3, argv, ^(pid_t pid) {
        kptr_t const procStructAddr = get_proc_struct_for_pid1(pid);
        LOG("procStructAddr = " ADDR, procStructAddr);
        _assert(KERN_POINTER_VALID(procStructAddr), localize(@"Unable to find mount_apfs's process in kernel memory."), true);
        give_creds_to_process_at_addr(procStructAddr, get_kernel_cred_addr());
    }) == ERR_SUCCESS, localize(@"Unable to mount RootFS."), true);
    _assert(execCmd("/sbin/mount", NULL) == ERR_SUCCESS, localize(@"Unable to print new mount list."), true);
    const char *systemSnapshotLaunchdPath = [@(rootFsMountPoint) stringByAppendingPathComponent:@"sbin/launchd"].UTF8String;
    _assert(waitFF(systemSnapshotLaunchdPath) == ERR_SUCCESS, localize(@"Unable to verify newly mounted RootFS."), true);
    LOG("Successfully mounted RootFS.");
    //renameSnapshot(//
    fs_snapshot_rename(root_fs, rootFsMountPoint, snapshots, origfs);
}


bool ensure_symlink(const char *to, const char *from) {
    ssize_t wantedLength = strlen(to);
    ssize_t maxLen = wantedLength + 1;
    char link[maxLen];
    ssize_t linkLength = readlink(from, link, sizeof(link));
    if (linkLength != wantedLength ||
        strncmp(link, to, maxLen) != ERR_SUCCESS
        ) {
        if (!clean_file(from)) {
            return false;
        }
        if (symlink(to, from) != ERR_SUCCESS) {
            return false;
        }
    }
    return true;
}


bool copyMe(const char *from, const char *to)
{
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:from]])
    {
        [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithUTF8String:from] toPath:[NSString stringWithUTF8String:to] error:&error];
        
        if (error)
        {
            LOG("ERROR: %@", error);
        } else {
            LOG("FILE COPIED!");
        }
        
    } else {
        LOG("FILE DOESN'T EXIST!");
    }
    
    return false;
}



struct hfs_mount_args {
    char    *fspec;            /* block special device to mount */
    uid_t    hfs_uid;        /* uid that owns hfs files (standard HFS only) */
    gid_t    hfs_gid;        /* gid that owns hfs files (standard HFS only) */
    mode_t    hfs_mask;        /* mask to be applied for hfs perms  (standard HFS only) */
    u_int32_t hfs_encoding;    /* encoding for this volume (standard HFS only) */
    struct    timezone hfs_timezone;    /* user time zone info (standard HFS only) */
    int        flags;            /* mounting flags, see below */
    int     journal_tbuffer_size;   /* size in bytes of the journal transaction buffer */
    int        journal_flags;          /* flags to pass to journal_open/create */
    int        journal_disable;        /* don't use journaling (potentially dangerous) */
};






void remountFS(bool shouldRestore) {
 
    int root_fs = open("/", O_RDONLY);
    _assert(root_fs > 0, @"Error Opening The Root Filesystem!", true);
    const char **snapshots = snapshot_list(root_fs);
    const char *origfs = "orig-fs";
    bool isOriginalFS = false;
    const char *root_disk = "/dev/disk0s1s1";

    if (snapshots == NULL) {
        LOG("No System Snapshot Found! Don't worry, I'll Make One!");
        //Clear Dev Flags
        uint64_t devVnode = vnodeForPath(root_disk);
        _assert(ISADDR(devVnode), @"Failed to clear dev vnode's si_flags.", true);
        uint64_t v_specinfo = ReadKernel64(devVnode + koffsetS3(KSTRUCT_OFFSET_VNODE_VU_SPECINFO));
        _assert(ISADDR(v_specinfo), @"Failed to clear dev vnode's si_flags.", true);
        WriteKernel32(v_specinfo + koffsetS3(KSTRUCT_OFFSET_SPECINFO_SI_FLAGS), 0);
        uint32_t si_flags = ReadKernel32(v_specinfo + koffsetS3(KSTRUCT_OFFSET_SPECINFO_SI_FLAGS));
        _assert(si_flags == 0, @"Failed to clear dev vnode's si_flags.", true);
        _assert(_vnode_put(devVnode) == ERR_SUCCESS, @"Failed to clear dev vnode's si_flags.", true);
        
        //Pre-Mount
        
        //Pre-Mount
        preMountFS(root_disk, root_fs, snapshots, origfs);
        
        close(root_fs);
    }
    
    list_all_snapshots(snapshots, origfs, isOriginalFS);

    
}

void installSSH()
{
    extractFile(get_bootstrap_file(@"ssh.tar"), @"/var/containers/");
    NSMutableArray *toInject = [NSMutableArray new];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:[NSURL URLWithString:@"/var/containers/"] includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:0 errorHandler:nil];
    _assert(directoryEnumerator != nil, @"Failed to enable SSH.", true);
    for (NSURL *URL in directoryEnumerator) {
        NSString *path = [URL path];
        if (cdhashFor(path) != nil) {
            if (![toInject containsObject:path]) {
                [toInject addObject:path];
            }
        }
    }
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:@"/Applications" error:nil]) {
        NSString *path = [@"/Applications" stringByAppendingPathComponent:file];
        NSMutableDictionary *info_plist = [NSMutableDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
        if (info_plist == nil) continue;
        if ([info_plist[@"CFBundleIdentifier"] hasPrefix:@"com.apple."]) continue;
        directoryEnumerator = [fileManager enumeratorAtURL:[NSURL URLWithString:path] includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:0 errorHandler:nil];
        if (directoryEnumerator == nil) continue;
        for (NSURL *URL in directoryEnumerator) {
            NSString *path = [URL path];
            if (cdhashFor(path) != nil) {
                if (![toInject containsObject:path]) {
                    [toInject addObject:path];
                }
            }
        }
    }
    if (toInject.count > 0) {
        _assert(injectTrustCache(toInject, GETOFFSET(trustcache), pmap_load_trust_cache) == ERR_SUCCESS, message, true);
    }
    _assert(ensure_symlink("/ziyou/usr/bin/scp", "/usr/bin/scp"), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/usr/local/lib", 0, 0755), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/usr/local/lib/zsh", 0, 0755), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/usr/local/lib/zsh/5.0.8", 0, 0755), @"Failed to enable SSH.", true);
    _assert(ensure_symlink("/ziyou/usr/local/lib/zsh/5.0.8/zsh", "/usr/local/lib/zsh/5.0.8/zsh"), @"Failed to enable SSH.", true);
    _assert(ensure_symlink("/ziyou/bin/zsh", "/bin/zsh"), @"Failed to enable SSH.", true);
    _assert(ensure_symlink("/ziyou/etc/zshrc", "/etc/zshrc"), @"Failed to enable SSH.", true);
    _assert(ensure_symlink("/ziyou/usr/share/terminfo", "/usr/share/terminfo"),@"Failed to enable SSH."message, true);
    _assert(ensure_symlink("/ziyou/usr/local/bin", "/usr/local/bin"), @"Failed to enable SSH.", true);
    _assert(ensure_symlink("/ziyou/etc/profile", "/etc/profile"), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/etc/dropbear", 0, 0755), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/ziyou/Library", 0, 0755), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/ziyou/Library/LaunchDaemons", 0, 0755), @"Failed to enable SSH.", true);
    _assert(ensure_directory("/ziyou/etc/rc.d", 0, 0755), @"Failed to enable SSH.", true);
    if (access("/ziyou/Library/LaunchDaemons/dropbear.plist", F_OK) != ERR_SUCCESS) {
        NSMutableDictionary *dropbear_plist = [NSMutableDictionary new];
        _assert(dropbear_plist, @"Failed to enable SSH.", true);
        dropbear_plist[@"Program"] = @"/ziyou/usr/local/bin/dropbear";
        dropbear_plist[@"RunAtLoad"] = @YES;
        dropbear_plist[@"Label"] = @"ShaiHulud";
        dropbear_plist[@"KeepAlive"] = @YES;
        dropbear_plist[@"ProgramArguments"] = [NSMutableArray new];
        dropbear_plist[@"ProgramArguments"][0] = @"/usr/local/bin/dropbear";
        dropbear_plist[@"ProgramArguments"][1] = @"-F";
        dropbear_plist[@"ProgramArguments"][2] = @"-R";
        dropbear_plist[@"ProgramArguments"][3] = @"--shell";
        dropbear_plist[@"ProgramArguments"][4] = @"/ziyou/bin/bash";
        dropbear_plist[@"ProgramArguments"][5] = @"-p";
        dropbear_plist[@"ProgramArguments"][6] = @"22";
        _assert([dropbear_plist writeToFile:@"/ziyou/Library/LaunchDaemons/dropbear.plist" atomically:YES], @"Failed to enable SSH.", true);
        _assert(createFile("/ziyou/Library/LaunchDaemons/dropbear.plist", 0, 0644), @"Failed to enable SSH.", true);
    }
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:@"/ziyou/Library/LaunchDaemons" error:nil]) {
        NSString *path = [@"/ziyou/Library/LaunchDaemons" stringByAppendingPathComponent:file];
        execCmd("/ziyou/bin/launchctl", "load", path.UTF8String, NULL);
    }
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:@"/ziyou/etc/rc.d" error:nil]) {
        NSString *path = [@"/ziyou/etc/rc.d" stringByAppendingPathComponent:file];
        if ([fileManager isExecutableFileAtPath:path]) {
            execCmd("/ziyou/bin/bash", "-c", path.UTF8String, NULL);
        }
    }
    _assert(execCmd("/ziyou/bin/launchctl", "stop", "com.apple.cfprefsd.xpc.daemon", NULL) == ERR_SUCCESS, message, true);
    LOG("Successfully enabled SSH.");
}


bool doesThisExist(const char *fileToCheck)
{
    NSString *file2C = [NSString stringWithUTF8String:fileToCheck];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file2C])
    {
        return true;
    } else
    {
        return false;
    }
    return false;
}

bool ensure_file(const char *file, int owner, mode_t mode) {
    NSString *path = @(file);
    NSFileManager *fm = [NSFileManager defaultManager];
    id attributes = [fm attributesOfItemAtPath:path error:nil];
    if (attributes &&
        [attributes[NSFileType] isEqual:NSFileTypeRegular] &&
        [attributes[NSFileOwnerAccountID] isEqual:@(owner)] &&
        [attributes[NSFileGroupOwnerAccountID] isEqual:@(owner)] &&
        [attributes[NSFilePosixPermissions] isEqual:@(mode)]
        ) {
        // File exists and matches arguments
        return true;
    }
    if (attributes) {
        if ([attributes[NSFileType] isEqual:NSFileTypeRegular]) {
            // Item exists and is a file
            return [fm setAttributes:@{
                                       NSFileOwnerAccountID: @(owner),
                                       NSFileGroupOwnerAccountID: @(owner),
                                       NSFilePosixPermissions: @(mode)
                                       } ofItemAtPath:path error:nil];
        } else if (![fm removeItemAtPath:path error:nil]) {
            // Item exists and is not a file but could not be removed
            return false;
        }
    }
    // Item does not exist at this point
    return [fm createFileAtPath:path contents:nil attributes:@{
                                                               NSFileOwnerAccountID: @(owner),
                                                               NSFileGroupOwnerAccountID: @(owner),
                                                               NSFilePosixPermissions: @(mode)
                                                               }];
}





//NONCE SHIT





bool doesFileExist(NSString *fileName)
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return true;
    } else {
        return false;
    }
}

void removeFileIfExists(const char *fileToRemove)
{
    NSString *fileToRM = [NSString stringWithUTF8String:fileToRemove];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileToRM])
    {
        [[NSFileManager defaultManager] removeItemAtPath:fileToRM error:&error];
        if (error)
        {
            LOG("ERROR REMOVING FILE! ERROR REPORTED: %@", error);
        } else {
            LOG("REMOVED FILE: %@", fileToRM);
        }
    } else {
        LOG("File Doesn't exist. Not removing.");
    }
}

void startJailbreakD()
{
    removeFileIfExists("/var/log/pspawn.log");
    
    removeFileIfExists("/ziyou/jailbreakd.old.log");
    copyMe("/var/log/jailbreakd-stderr.log", "/ziyou/jailbreakd.old.log");
    
    removeFileIfExists("/var/log/jailbreakd-stdout.log");
    removeFileIfExists("/var/log/jailbreakd-stderr.log");
    
    
    removeFileIfExists("/var/log/jailbreakd-stdout.log.bak");
    removeFileIfExists("/var/log/jailbreakd-stderr.log.bak");
    removeFileIfExists("/var/log/amfid_payload.log");
    removeFileIfExists("/var/log/pspawn_payload.log");
    removeFileIfExists("/var/log/pspawn_hook.log");
    removeFileIfExists("/var/log/pspawn_payload_xpcproxy.log");
    removeFileIfExists("/var/log/pspawn_payload_other.log");
    removeFileIfExists("/var/log/pspawn_hook_xpcproxy.log");
    chmod("/ziyou/jailbreakd", 4755);
    chown("/ziyou/jailbreakd", 0, 0);
    _assert(execCmd("/ziyou/launchctl", "load", "/ziyou/LD/jailbreakd.plist", NULL) == ERR_SUCCESS, @"Failed to load jailbreakd", true);
    //const char jbdfilepid; "/var/tmp/jailbreakd.pid";
    NSString *jbdfilepid = [NSString stringWithUTF8String:"/var/tmp/jailbreakd.pid"];
    NSError *error;
     while (!file_exists("/var/tmp/jailbreakd.pid")){
         printf("Waiting for jailbreakd...\n");
         //sleep(2); //100 ms
         usleep(10000);//10 ms
     }
    
    /*if ([[NSFileManager defaultManager] fileExistsAtPath:jbdfilepid])
    {
        if (error)
        {
            LOG("ERROR finding jailbreakd FILE! ERROR REPORTED: %@", error);
        } else {
            sleep(1);
            LOG("waitng for jailbreakd pid! ERROR REPORTED: %@", error);
        }
    }*/
    if (waitFF("/var/tmp/jailbreakd.pid") == ERR_SUCCESS)
    {
        LOG("Jailbreakd has been loaded!");
    } else {
        LOG("Error loading jailbreakd!");
    }

}

pid_t pidOfProcess(const char *name) {
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pids[numberOfProcesses];
    bzero(pids, sizeof(pids));
    proc_listpids(PROC_ALL_PIDS, 0, pids, (int)sizeof(pids));
    for (int i = 0; i < numberOfProcesses; ++i) {
        if (pids[i] == 0) {
            continue;
        }
        char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];
        bzero(pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
        proc_pidpath(pids[i], pathBuffer, sizeof(pathBuffer));
        if (strlen(pathBuffer) > 0 && strcmp(pathBuffer, name) == 0) {
            return pids[i];
        }
    }
    return 0;
}

bool reBack() {
    pid_t backboardd_pid = pidOfProcess("/usr/libexec/backboardd");
    if (!(backboardd_pid > 1)) {
        LOG("Unable to find backboardd pid.");
        return false;
    }
    if (kill(backboardd_pid, SIGTERM) != ERR_SUCCESS) {
        LOG("Unable to terminate backboardd.");
        return false;
    }
    return true;
}

void disableStashing()
{
    if (access("/.cydia_no_stash", F_OK) != ERR_SUCCESS) {
        // Disable stashing.
        
        LOG("Disabling stashing...");
        ensure_file("/.cydia_no_stash", 0, 0644);
        LOG("Successfully disabled stashing.");
    }
}


bool killAMFID() {
    pid_t amfid_pid = pidOfProcess("/usr/libexec/amfid");
    if (!(amfid_pid > 1)) {
        LOG("Unable to find amfid pid.");
        return false;
    }
    if (kill(amfid_pid, SIGKILL) != ERR_SUCCESS) {
        LOG("Unable to terminate amfid.");
        return false;
    }
    return true;
}

void createWorkingDir()
{
    _assert(ensure_directory("/var/containers/Bundle/iosbinpack64/", 0, 0777), @"yo wtf?", true);
}


bool runDpkg(NSArray <NSString*> *args, bool forceDeps) {
    if ([args count] < 2) {
        LOG("%s: Nothing to do", __FUNCTION__);
        return false;
    }
    NSMutableArray <NSString*> *command = [NSMutableArray
                                           arrayWithArray:@[
                                                            @"/usr/bin/dpkg",
                                                            @"--force-bad-path",
                                                            @"--force-configure-any",
                                                            @"--no-triggers"
                                                            ]];
    
    if (forceDeps) {
        [command addObjectsFromArray:@[@"--force-depends", @"--force-remove-essential"]];
    }
    for (NSString *arg in args) {
        [command addObject:arg];
    }
    const char *argv[command.count];
    for (int i=0; i<[command count]; i++) {
        argv[i] = [command[i] UTF8String];
    }
    argv[command.count] = NULL;
    int rv = execCmdV("/usr/bin/dpkg", (int)[command count], argv, NULL);
    return !WEXITSTATUS(rv);
}

bool installDeb(const char *debName, bool forceDeps) {
    return runDpkg(@[@"-i", @(debName)], forceDeps);
}

//Many Thanks to Jake
typedef struct vnode_resolve* vnode_resolve_t;
typedef struct {
    union {
        uint64_t lck_mtx_data;
        uint64_t lck_mtx_tag;
    };
    union {
        struct {
            uint16_t lck_mtx_waiters;
            uint8_t lck_mtx_pri;
            uint8_t lck_mtx_type;
        };
        struct {
            struct _lck_mtx_ext_ *lck_mtx_ptr;
        };
    };
} lck_mtx_t;

bool runApt(NSArray <NSString*> *args) {
    if ([args count] < 1) {
        LOG("%s: Nothing to do", __FUNCTION__);
        return false;
    }
    NSMutableArray <NSString*> *command = [NSMutableArray arrayWithArray:@[
                                                                           @"/usr/bin/apt-get",
                                                                           @"-o", @"Dir::Etc::sourcelist=ziyou/ziyou.list",
                                                                           @"-o", @"Dir::Etc::sourceparts=-",
                                                                           @"-o", @"APT::Get::List-Cleanup=0"
                                                                           ]];
    [command addObjectsFromArray:args];
    
    const char *argv[command.count];
    for (int i=0; i<[command count]; i++) {
        argv[i] = [command[i] UTF8String];
    }
    argv[command.count] = NULL;
    int rv = execCmdV(argv[0], (int)[command count], argv, NULL);
    return !WEXITSTATUS(rv);
}

typedef uint32_t kauth_action_t;
LIST_HEAD(buflists, buf);

struct vnode {
    lck_mtx_t v_lock;            /* vnode mutex */
    TAILQ_ENTRY(vnode) v_freelist;        /* vnode freelist */
    TAILQ_ENTRY(vnode) v_mntvnodes;        /* vnodes for mount point */
    TAILQ_HEAD(, namecache) v_ncchildren;    /* name cache entries that regard us as their parent */
    LIST_HEAD(, namecache) v_nclinks;    /* name cache entries that name this vnode */
    vnode_t     v_defer_reclaimlist;        /* in case we have to defer the reclaim to avoid recursion */
    uint32_t v_listflag;            /* flags protected by the vnode_list_lock (see below) */
    uint32_t v_flag;            /* vnode flags (see below) */
    uint16_t v_lflag;            /* vnode local and named ref flags */
    uint8_t     v_iterblkflags;        /* buf iterator flags */
    uint8_t     v_references;            /* number of times io_count has been granted */
    int32_t     v_kusecount;            /* count of in-kernel refs */
    int32_t     v_usecount;            /* reference count of users */
    int32_t     v_iocount;            /* iocounters */
    void *   v_owner;            /* act that owns the vnode */
    uint16_t v_type;            /* vnode type */
    uint16_t v_tag;                /* type of underlying data */
    uint32_t v_id;                /* identity of vnode contents */
    union {
        struct mount    *vu_mountedhere;/* ptr to mounted vfs (VDIR) */
        struct socket    *vu_socket;    /* unix ipc (VSOCK) */
        struct specinfo    *vu_specinfo;    /* device (VCHR, VBLK) */
        struct fifoinfo    *vu_fifoinfo;    /* fifo (VFIFO) */
        struct ubc_info *vu_ubcinfo;    /* valid for (VREG) */
    } v_un;
    struct    buflists v_cleanblkhd;        /* clean blocklist head */
    struct    buflists v_dirtyblkhd;        /* dirty blocklist head */
    struct klist v_knotes;            /* knotes attached to this vnode */
    /*
     * the following 4 fields are protected
     * by the name_cache_lock held in
     * excluive mode
     */
    kauth_cred_t    v_cred;            /* last authorized credential */
    kauth_action_t    v_authorized_actions;    /* current authorized actions for v_cred */
    int        v_cred_timestamp;    /* determine if entry is stale for MNTK_AUTH_OPAQUE */
    int        v_nc_generation;    /* changes when nodes are removed from the name cache */
    /*
     * back to the vnode lock for protection
     */
    int32_t        v_numoutput;            /* num of writes in progress */
    int32_t        v_writecount;            /* reference count of writers */
    const char *v_name;            /* name component of the vnode */
    vnode_t v_parent;            /* pointer to parent vnode */
    struct lockf    *v_lockf;        /* advisory lock list head */
    int     (**v_op)(void *);        /* vnode operations vector */
    mount_t v_mount;            /* ptr to vfs we are in */
    void *    v_data;                /* private data for fs */
    
    struct label *v_label;            /* MAC security label */
    
    //#if CONFIG_TRIGGERS
    vnode_resolve_t v_resolve;        /* trigger vnode resolve info (VDIR only) */
    //#endif /* CONFIG_TRIGGERS */
};

void ls (const char *path)
{
    NSError *error;
    NSString *pathToSearch = [NSString stringWithUTF8String:path];
    NSArray *filesInDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToSearch error:&error];
    
    if (error)
    {
        LOG("ERROR LS: %@", error);
    } else {
        NSLog(@"Contents Of %@:", pathToSearch);
        for (NSString *file in filesInDir)
        {
            NSLog(@"%@", file);
        }
    }
}

int systemCmd(const char *cmd) {
    const char *argv[] = {"sh", "-c", (char *)cmd, NULL};
    return execCmdV("/bin/sh", 3, argv, NULL);
}

NSArray *getPackages(const char *packageFile)
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSError *error;
    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    
    
    //Read File Line By Line
    NSString *contentsOfFile = [NSString stringWithContentsOfFile:[NSString stringWithUTF8String:packageFile] encoding:NSASCIIStringEncoding error:&error];
    NSArray *linesOfFile = [contentsOfFile componentsSeparatedByCharactersInSet:separator];
    
    //Read Lines
    for (NSString *line in linesOfFile)
    {
        //Does the line start with Package: ?
        if ([line hasPrefix:@"Filename: "])
        {
            //If so, what is after that? Lets add it to our array.
            NSString *packageNameToAdd = [line componentsSeparatedByString:@"Filename: ./"][1];
            
            //Good Practice I guess?
            if (![array containsObject:packageNameToAdd])
            {
                [array addObject:packageNameToAdd];
            }
        }
    }
    
    //We got our array.
    return array;
}



void createLocalRepo()
{
    _assert(ensure_directory("/etc/apt/ziyou", 0, 0755), @"Failed to extract bootstrap.", true);
    clean_file("/etc/apt/sources.list.d/ziyou");
    const char *listPath = "/etc/apt/ziyou/ziyou.list";
    NSString *listContents = @"deb file:///var/lib/ziyou/apt ./\n";
    NSString *existingList = [NSString stringWithContentsOfFile:@(listPath) encoding:NSUTF8StringEncoding error:nil];
    if (![listContents isEqualToString:existingList]) {
        clean_file(listPath);
        [listContents writeToFile:@(listPath) atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    createFile(listPath, 0, 0644);
    FILE *file;
    file = fopen("/etc/apt/sources.list.d/Th0r.list","w"); /* write file (create a file if it does not exist and if it does treat as empty.*/
    //fprintf(file,"%s","deb https://Th0r12.github.io/repo/ ./\n");
    fprintf(file,"%s","deb https://ricklantis.github.io/repo/ ./\n");
    fprintf(file,"%s","\n"); //writes
    fclose(file);
//    FILE *filecy;
    //filecy = fopen("/etc/apt/sources.list.d/cydia.list","w"); /* write file (create a file if it does not exist and if it does treat as empty.*/
    //fprintf(filecy,"%s","deb https://ricklantis.github.io/repo/ ./\n");
    //fprintf(filecy,"%s","\n"); //writes
    //fclose(filecy);
    
    NSString *repoPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/bootstrap/DEBS"];
    _assert(repoPath != nil, @"Repo path is null!", true);
    ensure_directory("/var/lib/ziyou", 0, 0755);
    ensure_symlink([repoPath UTF8String], "/var/lib/ziyou/apt");
    //runApt(@[@"update"]);
    
    // Workaround for what appears to be an apt bug
    ensure_symlink("/var/lib/ziyou/apt/./Packages", "/var/lib/apt/lists/_var_lib_ziyou_apt_._Packages");
}



void kickMe()
{
    //After we extracted the bootstrap, this is all we need to get back into jailbroken state.
    removeFileIfExists("/Library/MobileSubstrate/ServerPlugins/Unrestrict.dylib");
    trust_file(@"/usr/lib/libsubstitute.dylib");
    trust_file(@"/usr/lib/libsubstrate.dylib");
    trust_file(@"/usr/lib/TweakInject.dylib");
    trust_file(@"/usr/lib/pspawn_payload.dylib");
    trust_file(@"/usr/lib/amfid_payload.dylib");
    startJailbreakD();
    //xpcFucker();
    killAMFID();
}

void updatePayloads()
{

    //Backup Tweaks
    removeFileIfExists("/usr/lib/TweakInject.bak");
    removeFileIfExists("/usr/lib/TweakInject/Safemode.dylib");
    removeFileIfExists("/usr/lib/TweakInject/Safemode.plist");
    removeFileIfExists("/usr/lib/TweakInject/MobileSafety.dylib");
    removeFileIfExists("/usr/lib/TweakInject/MobileSafety.plist");
    
    copyMe("/usr/lib/TweakInject", "/usr/lib/TweakInject.bak");
    removeFileIfExists("/usr/bin/sbreload");
    removeFileIfExists("/usr/bin/rebackboardd");
    extractFile(get_bootstrap_file(@"AIO2.tar"), @"/");
    /*copyMe("/usr/lib/TweakInject/Safemode.dylib", "/usr/lib/TweakInject.bak/Safemode.dylib");
    copyMe("/usr/lib/TweakInject/Safemode.plist", "/usr/lib/TweakInject.bak/Safemode.plist");
    */
    removeFileIfExists("/usr/lib/TweakInject");
    copyMe("/usr/lib/TweakInject.bak", "/usr/lib/TweakInject");
    //trust_file(@"/usr/lib/TweakInject/Safemode.dylib");
    kickMe();
}


void addToArray(NSString *package, NSMutableArray *array)
{
    NSString *dir = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/bootstrap/DEBS/"];
    NSString *strToAdd = [dir stringByAppendingString:package];
    
    [array addObject:strToAdd];
}

void fixFS()
{
    LOG("[Ziyou] Fixing Fileystem");
    
    
    removeFileIfExists("/Library/MobileSubstrate/ServerPlugins/Unrestrict.dylib");
    
    if (access("/usr/bin/ldid", F_OK) != ERR_SUCCESS) {
        _assert(access("/usr/libexec/ldid", F_OK) == ERR_SUCCESS, @"Failed to copy over our resources to RootFS.", true);
        _assert(ensure_symlink("../libexec/ldid", "/usr/bin/ldid"), @"Failed to copy over our resources to RootFS.", true);
    }
    
    LOG("Allowing SpringBoard to show non-default system apps...");
    _assert(mod_plist_file(@"/var/mobile/Library/Preferences/com.apple.springboard.plist", ^(id plist) {
        plist[@"SBShowNonDefaultSystemApps"] = @YES;
    }), @"Failed to disallow SpringBoard to show non-default system apps.", true);
    LOG("Successfully allowed SpringBoard to show non-default system apps.");
    
    
    _assert(ensure_directory("/var/lib", 0, 0755), @"Failed to repair filesystem.", true);
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:@"/var/lib/dpkg" isDirectory:&isDir] && isDir) {
        if ([fm fileExistsAtPath:@"/Library/dpkg" isDirectory:&isDir] && isDir) {
            LOG(@"Removing /var/lib/dpkg...");
            _assert([fm removeItemAtPath:@"/var/lib/dpkg" error:nil], @"Failed to repair filesystem.", true);
        } else {
            LOG(@"Moving /var/lib/dpkg to /Library/dpkg...");
            _assert([fm moveItemAtPath:@"/var/lib/dpkg" toPath:@"/Library/dpkg" error:nil], @"Failed to repair filesystem.", true);
        }
    }
    
    _assert(ensure_symlink("/Library/dpkg", "/var/lib/dpkg"), @"Failed to repair filesystem.", true);
    _assert(ensure_directory("/Library/dpkg", 0, 0755), @"Failed to repair filesystem.", true);
    _assert(ensure_file("/var/lib/dpkg/status", 0, 0644), @"Failed to repair filesystem.", true);
    _assert(ensure_file("/var/lib/dpkg/available", 0, 0644), @"Failed to repair filesystem.", true);
    NSString *file = [NSString stringWithContentsOfFile:@"/var/lib/dpkg/info/firmware-sbin.list" encoding:NSUTF8StringEncoding error:nil];
    if ([file rangeOfString:@"/sbin/fstyp"].location != NSNotFound || [file rangeOfString:@"\n\n"].location != NSNotFound) {
        file = [file stringByReplacingOccurrencesOfString:@"/sbin/fstyp\n" withString:@""];
        file = [file stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        [file writeToFile:@"/var/lib/dpkg/info/firmware-sbin.list" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    _assert(ensure_symlink("/usr/lib", "/usr/lib/_ncurses"), message, true);
    _assert(ensure_directory("/Library/Caches", 0, S_ISVTX | S_IRWXU | S_IRWXG | S_IRWXO), message, true);
    LOG("[Ziyou] Finished Fixing Filesystem!");
}




void installCydia(bool post)
{
    if (post == false)
    {
        //Initial Resources
        extractingbootstrap();
        extractFile(get_bootstrap_file(@"Resources.tar"), @"/");
        fixFS();
        
        //Firmware Package
        systemCmd("/usr/libexec/cydia/firmware.sh");
        
        //Jailbreakd, Pspawn, Amfid
        extractFile(get_bootstrap_file(@"AIO2.tar"), @"/");
        
        //Start all the payloads
        kickMe();
        installingdebsboys();

        //Run DPKG on itself and readline is needed
        installDeb([get_debian_file(@"dpkg_1.18.25-9_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"readline_7.0.5-2_iphoneos-arm.deb") UTF8String], true);
        
        //PRE-DEPENDS
        installDeb([get_debian_file(@"tar.deb") UTF8String], true);
        installDeb([get_debian_file(@"debianutils.deb") UTF8String], true);
        installDeb([get_debian_file(@"darwintools.deb") UTF8String], true);
        installDeb([get_debian_file(@"uikit.deb") UTF8String], true);
        installDeb([get_debian_file(@"system-cmds.deb") UTF8String], true);
        installDeb([get_debian_file(@"cydia-lproj.deb") UTF8String], true);
        installDeb([get_debian_file(@"xz_5.2.4-4_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"sed_4.5-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"shell-cmds_118-8_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"org.thebigboss.repo.icons_1.0_all.deb") UTF8String], true);
        installDeb([get_debian_file(@"lzma.deb") UTF8String], true);
        installDeb([get_debian_file(@"lz4_1.7.5-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"bzip2_1.0.6-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"libapt-pkg5.0_1.8.2-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"libapt_1.8.2-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"apt7-lib.deb") UTF8String], true);
        installDeb([get_debian_file(@"ncurses_6.1+20181013-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"libssl1.0_1.0.2s-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"cydia.deb") UTF8String], true);

        
        //Idk why we need to do this bullshit.
        for (NSString *pkg in getPackages([get_debian_file(@"Packages") UTF8String]))
        {
            if (![pkg  isEqual: @"tar.deb"] && ![pkg  isEqual: @"installer.deb"] && ![pkg  isEqual: @"debianutils.deb"] && ![pkg  isEqual: @"darwintools.deb"] && ![pkg  isEqual: @"uikit.deb"] && ![pkg  isEqual: @"system-cmds.deb"] && ![pkg  isEqual: @"cydia.deb"]  && ![pkg  isEqual: @"readline_7.0.5-2_iphoneos-arm.deb"] && ![pkg  isEqual: @"dpkg_1.18.25-9_iphoneos-arm.deb"] && ![pkg  isEqual: @"sed_4.5-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"xz_5.2.4-4_iphoneos-arm.deb"] && ![pkg  isEqual: @"shell-cmds_118-8_iphoneos-arm.deb"] && ![pkg  isEqual: @"org.thebigboss.repo.icons_1.0_all.deb"] && ![pkg  isEqual: @"libapt-pkg5.0_1.8.2-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"libapt_1.8.2-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"apt7-lib.deb"] && ![pkg  isEqual: @"lzma.deb"] && ![pkg  isEqual: @"lz4_1.7.5-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"bzip2_1.0.6-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"ncurses_6.1+20181013-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"libssl1.0_1.0.2s-1_iphoneos-arm.deb"])
            {
                installDeb([get_debian_file(pkg) UTF8String], true);
            }
        }
        //Packmandone();
        uicaching();
        execCmd("/usr/bin/uicache", NULL);
    } else {
        
        //Initial Resources
        extractingbootstrap();
        extractFile(get_bootstrap_file(@"Resources.tar"), @"/");
        fixFS();
        
        //Firmware Package
        systemCmd("/usr/libexec/cydia/firmware.sh");
        
        //Jailbreakd, Pspawn, Amfid
        extractFile(get_bootstrap_file(@"AIO2.tar"), @"/");
        
        //Start all the payloads
        kickMe();
        installingdebsboys();

        //Run DPKG on itself and readline is needed
        installDeb([get_debian_file(@"dpkg_1.18.25-9_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"readline_7.0.5-2_iphoneos-arm.deb") UTF8String], true);
        
        //PRE-DEPENDS
        installDeb([get_debian_file(@"tar.deb") UTF8String], true);
        installDeb([get_debian_file(@"debianutils.deb") UTF8String], true);
        installDeb([get_debian_file(@"darwintools.deb") UTF8String], true);
        installDeb([get_debian_file(@"uikit.deb") UTF8String], true);
        installDeb([get_debian_file(@"system-cmds.deb") UTF8String], true);
        installDeb([get_debian_file(@"cydia-lproj.deb") UTF8String], true);
        installDeb([get_debian_file(@"xz_5.2.4-4_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"sed_4.5-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"shell-cmds_118-8_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"org.thebigboss.repo.icons_1.0_all.deb") UTF8String], true);
        installDeb([get_debian_file(@"lzma.deb") UTF8String], true);
        installDeb([get_debian_file(@"lz4_1.7.5-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"bzip2_1.0.6-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"libapt-pkg5.0_1.8.2-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"libapt_1.8.2-1_iphoneos-arm.deb") UTF8String], true);
        installDeb([get_debian_file(@"apt7-lib.deb") UTF8String], true);
        installDeb([get_debian_file(@"libssl1.0_1.0.2s-1_iphoneos-arm.deb") UTF8String], true);

        installDeb([get_debian_file(@"cydia.deb") UTF8String], true);

        //Idk why we need to do this bullshit.
        for (NSString *pkg in getPackages([get_debian_file(@"Packages") UTF8String]))
        {
            if (![pkg  isEqual: @"tar.deb"] && ![pkg  isEqual: @"installer.deb"] && ![pkg  isEqual: @"debianutils.deb"] && ![pkg  isEqual: @"darwintools.deb"] && ![pkg  isEqual: @"uikit.deb"] && ![pkg  isEqual: @"system-cmds.deb"] && ![pkg  isEqual: @"cydia.deb"]  && ![pkg  isEqual: @"readline_7.0.5-2_iphoneos-arm.deb"] && ![pkg  isEqual: @"dpkg_1.18.25-9_iphoneos-arm.deb"] && ![pkg  isEqual: @"sed_4.5-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"xz_5.2.4-4_iphoneos-arm.deb"] && ![pkg  isEqual: @"shell-cmds_118-8_iphoneos-arm.deb"] && ![pkg  isEqual: @"org.thebigboss.repo.icons_1.0_all.deb"] && ![pkg  isEqual: @"libapt-pkg5.0_1.8.2-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"libapt_1.8.2-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"apt7-lib.deb"] && ![pkg  isEqual: @"lzma.deb"] && ![pkg  isEqual: @"lz4_1.7.5-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"bzip2_1.0.6-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"ncurses_6.1+20181013-1_iphoneos-arm.deb"] && ![pkg  isEqual: @"libssl1.0_1.0.2s-1_iphoneos-arm.deb"])
            {
                installDeb([get_debian_file(pkg) UTF8String], true);
            }
        }
        cydiainstalled();

        createLocalRepo();
        runApt(@[@"update"]);
        runApt([@[@"-y", @"--allow-unauthenticated", @"--allow-downgrades", @"install"] arrayByAddingObjectsFromArray:@[@"--reinstall", @"cydia"]]);
        ensure_file("/.ziyou_installed", 0, 0644);
        //Packmandone();
        uicaching();
        execCmd("/usr/bin/uicache", NULL);
        
        
    }
}

void initInstall(int packagerType)
{
    //0 = Cydia
    //1 = Zebra
    int f = open("/.ziyou_installed", O_RDONLY);
    int f2 = open("/.ziyou_bootstrap", O_RDONLY);
    if (f == -1)
    {
        if (f2 == -1)
        {
            if (packagerType == 0)
            {
                installCydia(false);
            }
            
            ensure_file("/.ziyou_bootstrap", 0, 0644);
            showMSG(NSLocalizedString(@"Bootstrapped! rebooting your device once then resigning all binaries again to clear up any broken packages.", nil), 1, 1);
            reboot(RB_QUICK);
            
        } else {
            if (packagerType == 0)
            {
                installCydia(true);
            }
            
            char *targettype = sysctlWithName("hw.targettype");
            _assert(targettype != NULL, localize(@"Unable to get hardware targettype."), true);
            NSString *const jetsamFile = [NSString stringWithFormat:@"/System/Library/LaunchDaemons/com.apple.jetsamproperties.%s.plist", targettype];
            free(targettype);
            targettype = NULL;
            _assert(mod_plist_file(jetsamFile, ^(id plist) {
                plist[@"Version4"][@"System"][@"Override"][@"Global"][@"UserHighWaterMark"] = [NSNumber numberWithInteger:[plist[@"Version4"][@"PListDevice"][@"MemoryCapacity"] integerValue]];
            }), localize(@"Unable to update Jetsam plist to increase memory limit."), true);
            
        }
        
    } else {
        updatePayloads();
    }
}




void finish(bool shouldLoadTweaks)
{
    //TODO: Daemons, etc...
    LOG("Finishing up...");
    
    
    removeFileIfExists("/Library/MobileSubstrate/ServerPlugins/Unrestrict.dylib");
    
    disableStashing();
    
    removeFileIfExists("/bin/launchctl");
    copyMe("/ziyou/launchctl", "/bin/launchctl");
    
    systemCmd("chmod 0777 /var");
    systemCmd("chmod 0777 /var/mobile");
    systemCmd("chmod 0777 /var/mobile/Library");
    systemCmd("chmod 0777 /var/mobile/Library/Preferences");

    chmod("/var", 0777);
    chmod("/var/mobile", 0777);
    chmod("/var/mobile/Library", 0777);
    chmod("/var/mobile/Library/Preferences", 0777);
    
    systemCmd("chmod +x /usr/bin/sbreload");
    systemCmd("chown 0:0 /usr/bin/sbreload");
    
    systemCmd("chmod +x /usr/bin/rebackboardd");
    systemCmd("chown 0:0 /usr/bin/rebackboardd");
    
    createFile("/tmp/.jailbroken_ziyou", 0, 0644);
    
    if (shouldLoadTweaks)
    {
        LOG("LOADING TWEAKS...");
        clean_file("/var/tmp/.pspawn_disable_loader");
        
        systemCmd("echo 'really jailbroken';"
                  "shopt -s nullglob;"
                  "for a in /Library/LaunchDaemons/*.plist;"
                  "do echo loading $a;"
                  "launchctl load \"$a\" ;"
                  "done; ");
        systemCmd("for file in /etc/rc.d/*; do "
                  "if [[ -x \"$file\" && \"$file\" != \"/etc/rc.d/substrate\" ]]; then "
                  "\"$file\";"
                  "fi;"
                  "done");
        systemCmd("nohup bash -c \""
                  "launchctl stop com.apple.mDNSResponder ;"
                  "launchctl stop com.apple.backboardd"
                  "\" >/dev/null 2>&1 &");
                  
    } else {
        LOG("NOT LOADING TWEAKS...");
        ensure_file("/var/tmp/.pspawn_disable_loader", 0, 0644);
        systemCmd("nohup bash -c \""
                  "launchctl stop com.apple.mDNSResponder ;"
                  "launchctl stop com.apple.backboardd"
                  "\" >/dev/null 2>&1 &");
    }
    LOG("You're welcome.");
    respringattempt();
    //systemCmd("sbreload");

    
    reBack(); //Enable this to respring your device safely.
}

void serverS(){
    [[ViewController sharedController] serverS];
}
void cydiainstalled(){
    [[ViewController sharedController] cydiainstalled];
}
void littlewienners(){
    [[ViewController sharedController] littlewienners];
}
void respringattempt(){
    [[ViewController sharedController] respringattempt];
}
void uicaching(){
    [[ViewController sharedController] uicaching];
}
void remounting(){
    [[ViewController sharedController] remounting];
}
void settinghsp4(){
    [[ViewController sharedController] settinghsp4];
}
void Packmandone(){
    [[ViewController sharedController] Packmandone];
}
void restoreyofs(){
    [[ViewController sharedController] restoreyofs];
}
void th0rlabelyo(){
    [[ViewController sharedController] th0rlabelyo];
}
void justJByo(){
    [[ViewController sharedController] justJByo];
}
void installingdebsboys(){
    [[ViewController sharedController] installingdebsboys];
}
void loadingtweaks(){
    [[ViewController sharedController] loadingtweaks];
}
void cleaningshit(){
    [[ViewController sharedController] cleaningshit];
}
void extractingbootstrap(){
    [[ViewController sharedController] extractingbootstrap];
}

void getOffsets() {

   // printf("Initialized offsetfinder\n");
    
    LOG("Initializing patchfinder64...");
    const char *original_kernel_cache_path = "/System/Library/Caches/com.apple.kernelcaches/kernelcache";
    
    if (!canRead(original_kernel_cache_path))
    {
        swap_sandbox(get_selfproc(), KPTR_NULL);
    }
    
    NSString *homeDirectory = NSHomeDirectory();

    const char *decompressed_kernel_cache_path = [homeDirectory stringByAppendingPathComponent:@"Documents/kernelcache.dec"].UTF8String;
    LOG("DECOMPRESSED KERNEL CACHE AT: %s", decompressed_kernel_cache_path);
    if (!canRead(decompressed_kernel_cache_path)) {
        
        FILE *jtool2try = fopen(in_bundle("bootstrap/bins/jtool2"), "rb");
        FILE *original_kernel_cache = fopen(original_kernel_cache_path, "rb");
        execCmd(("/var/containers/usr/local/bin/jtool2"), "-dec", original_kernel_cache_path);
        _assert(original_kernel_cache != NULL, @"Failed to initialize patchfinder64.", true);
        uint32_t macho_header_offset = find_macho_header(original_kernel_cache);
        _assert(macho_header_offset != 0, @"Failed to initialize patchfinder64.", true);
        char *args[5] = { "lzssdec", "-o", (char *)[NSString stringWithFormat:@"0x%x", macho_header_offset].UTF8String, (char *)original_kernel_cache_path, (char *)decompressed_kernel_cache_path};
        _assert(lzssdec(5, args) == ERR_SUCCESS, @"Failed to initialize patchfinder64.", true);
        fclose(original_kernel_cache);
        
    }
    struct utsname u = { 0 };
    _assert(uname(&u) == ERR_SUCCESS, @"Failed to initialize patchfinder64.", true);
    //init_kernel(<#size_t (*kread)(uint64_t, void *, size_t)#>, <#uint64_t kernel_base#>, <#const char *filename#>)
    if (init_kernel(NULL, basefromkernelmemory, decompressed_kernel_cache_path) != ERR_SUCCESS || find_strref(u.version, 1, string_base_const, true, false) == 0) {
        _assert(clean_file(decompressed_kernel_cache_path), @"Failed to initialize patchfinder64.", true);
        _assert(false, @"Failed to initialize patchfinder64.", true);
    }
    if (auth_ptrs) {
        LOG("Detected A12 Device.");
        pmap_load_trust_cache = _pmap_load_trust_cache;
        setA12(1);
    }
    if (monolithic_kernel) {
        LOG("Detected monolithic kernel.");
    }
    LOG("Successfully initialized patchfinder64.");
    
    //This has to be a define rather than its own void. damn.
    #define findPFOffset(x) do { \
    SETOFFSET(x, find_symbol("_" #x)); \
    if (!ISADDR(GETOFFSET(x))) SETOFFSET(x, find_ ##x()); \
    LOG("Offset: "#x " = " ADDR, GETOFFSET(x)); \
    _assert(ISADDR(GETOFFSET(x)), @"Failed to find " #x " offset.", true); \
    SETOFFSET(x, GETOFFSET(x) + slidefromkernelmemory); \
    } while (false)
    //Get Strlen for jailbreakd
    findPFOffset(strlen);
    //Get AllProc for jailbreakd
    findPFOffset(allproc);
    //Get KFree for jailbreakd
    findPFOffset(kfree);
    //Get cs_gen_count for jailbreakd
    findPFOffset(cs_blob_generation_count);
    //Get cs_blob_allocate_site for jailbreakd
    findPFOffset(ubc_cs_blob_allocate_site);
    //Get cs_validate_csblob for jailbreakd
    findPFOffset(cs_validate_csblob);
    //Get kalloc_canblock for jailbreakd
    findPFOffset(kalloc_canblock);
    //Get cs_find_md for jailbreakd
    findPFOffset(cs_find_md);
    //Get Release Proc for jailbreakd
    findPFOffset(proc_rele);
    
    //Voucher Swap
    findPFOffset(shenanigans);
    
    //NVRam
    findPFOffset(IOMalloc);
    findPFOffset(IOFree);
    
    
    findPFOffset(trustcache);
    findPFOffset(OSBoolean_True);
    findPFOffset(osunserializexml);
    findPFOffset(smalloc);
    if (!auth_ptrs) {
        findPFOffset(add_x0_x0_0x40_ret);
    }
    findPFOffset(zone_map_ref);
    findPFOffset(vfs_context_current);
    findPFOffset(vnode_lookup);
    findPFOffset(vnode_put);
    findPFOffset(kernel_task);
    findPFOffset(lck_mtx_lock);
    findPFOffset(lck_mtx_unlock);

    findPFOffset(proc_find);
    /*
    findPFOffset(extension_create_file);
    findPFOffset(extension_add);
    findPFOffset(extension_release);
    findPFOffset(sfree);
    findPFOffset(sstrdup);
    findPFOffset(strlen);
    findPFOffset(issue_extension_for_mach_service);
    findPFOffset(issue_extension_for_absolute_path);
     
    
    findPFOffset(IOMalloc);
    findPFOffset(IOFree);
    */
    if (kCFCoreFoundationVersionNumber >= 1535.12) {
        findPFOffset(vnode_get_snapshot);
        findPFOffset(fs_lookup_snapshot_metadata_by_name_and_return_name);
        findPFOffset(apfs_jhash_getvnode);
        
        
    }
    if (auth_ptrs) {
        findPFOffset(pmap_load_trust_cache);
        findPFOffset(paciza_pointer__l2tp_domain_module_start);
        findPFOffset(paciza_pointer__l2tp_domain_module_stop);
        findPFOffset(l2tp_domain_inited);
        findPFOffset(sysctl__net_ppp_l2tp);
        findPFOffset(sysctl_unregister_oid);
        findPFOffset(mov_x0_x4__br_x5);
        findPFOffset(mov_x9_x0__br_x1);
        findPFOffset(mov_x10_x3__br_x6);
        findPFOffset(kernel_forge_pacia_gadget);
        findPFOffset(kernel_forge_pacda_gadget);
        findPFOffset(IOUserClient__vtable);
        findPFOffset(IORegistryEntry__getRegistryEntryID);
    }
    #undef findPFOffset
    
    //We got offsets.
    found_offs = true;
    term_kernel();
    
    clean_file(decompressed_kernel_cache_path);
    
    if (runShenPatchOWO)
    {
        LOG("We are going to use the shenanigans patch.");
        runShenPatch();
    }
    
}