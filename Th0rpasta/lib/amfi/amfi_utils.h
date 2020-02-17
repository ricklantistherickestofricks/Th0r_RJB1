//Used to be electra


#include <Foundation/Foundation.h>


bool is_amfi_cache(NSString *path);
NSString *cdhashFor(NSString *file);
int injectTrustCache(NSArray <NSString*> *files, uint64_t trust_chain, int (*pmap_load_trust_cache)(uint64_t, size_t));


#include <stdio.h>

void getSHA256inplace1(const uint8_t* code_dir, uint8_t *out);
uint8_t *getSHA256(const uint8_t* code_dir);
uint8_t *getCodeDirectory1(const char* name);

// thx hieplpvip
void inject_trusts(int pathc, const char *paths[]);

// Trust cache types
typedef char hash_t[20];

struct trust_chain {
    uint64_t next;
    unsigned char uuid[16];
    unsigned int count;
} __attribute__((packed));

