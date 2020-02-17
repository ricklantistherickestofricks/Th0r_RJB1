//
//  PFOffs.c



#include "PFOffs.h"
#include "kernel_exec.h"

pf_offsets_t offs;

int (*pmap_load_trust_cache)(uint64_t kernel_trust, size_t length) = NULL;
int _pmap_load_trust_cache(uint64_t kernel_trust, size_t length) {
    return (int)kexecute2(0xfffffff00722bb74, kernel_trust, length, 0, 0, 0, 0, 0);

    //return (int)kexecute2(GETOFFSET(pmap_load_trust_cache), kernel_trust, length, 0, 0, 0, 0, 0);
}
