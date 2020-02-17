#ifndef PATCHFINDER64_H_
#define PATCHFINDER64_H_

int init_kernel1(uint64_t base, const char *filename);
void term_kernel1(void);

// Fun part
uint64_t find_allproc1(void);
uint64_t find_add_x0_x0_0x40_ret1(void);
uint64_t find_copyout1(void);
uint64_t find_bzero1(void);
uint64_t find_bcopy1(void);
uint64_t find_rootvnode1(void);
uint64_t find_trustcache1(void);
uint64_t find_amficache1(void);
uint64_t find_realhost1(void);
uint64_t find_zone_map_ref1(void);
uint64_t find_zone_map1(void);

#endif
