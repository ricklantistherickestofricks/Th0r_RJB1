//
//  shenanigans.h


#ifndef shenanigans_h
#define shenanigans_h

#include <stdio.h>
#include "common.h"

void runShenPatch(void);
kptr_t get_kernel_cred_addr(void);
uint64_t give_creds_to_process_at_addr(uint64_t proc, uint64_t cred_addr);
kptr_t get_kernel_proc_struct_addr(void);
bool set_platform_binary(kptr_t proc, bool set);

#endif /* shenanigans_h */
