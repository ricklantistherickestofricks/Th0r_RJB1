#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <dlfcn.h>
#include "CSCommon.h"
#include "common.h"
#include "KernelUtils.h"




#include "amfi_utils.h"
#include "kutils.h"
#include "kernel_memorySP.h"
#include "kernel_memory.h"
#include "patchfinder64og.h"
#include <stdlib.h>
#include <mach-o/loader.h>
#include <CommonCrypto/CommonDigest.h>

uint32_t swap_uint321( uint32_t val ) {
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | (val >> 16);
}

void getSHA256inplace1(const uint8_t* code_dir, uint8_t *out) {
    if (code_dir == NULL) {
        printf("NULL passed to getSHA256inplace!\n");
        return;
    }
    uint32_t* code_dir_int = (uint32_t*)code_dir;
    
    uint32_t realsize = 0;
    for (int j = 0; j < 10; j++) {
        if (swap_uint321(code_dir_int[j]) == 0xfade0c02) {
            realsize = swap_uint321(code_dir_int[j+1]);
            code_dir += 4*j;
        }
    }
    
    CC_SHA256(code_dir, realsize, out);
}

uint8_t *getSHA256(const uint8_t* code_dir) {
    uint8_t *out = malloc(CC_SHA256_DIGEST_LENGTH);
    getSHA256inplace1(code_dir, out);
    return out;
}

uint8_t *getCodeDirectory1(const char* name) {
    // Assuming it is a macho
    
    FILE* fd = fopen(name, "r");
    
    uint32_t magic;
    fread(&magic, sizeof(magic), 1, fd);
    fseek(fd, 0, SEEK_SET);
    
    long off;
    int ncmds;
    
    if (magic == MH_MAGIC_64) {
        struct mach_header_64 mh64;
        fread(&mh64, sizeof(mh64), 1, fd);
        off = sizeof(mh64);
        ncmds = mh64.ncmds;
    } else if (magic == MH_MAGIC) {
        struct mach_header mh;
        fread(&mh, sizeof(mh), 1, fd);
        off = sizeof(mh);
        ncmds = mh.ncmds;
    } else {
        printf("%s is not a macho! (or has foreign endianness?) (magic: %x)\n", name, magic);
        return NULL;
    }
    
    for (int i = 0; i < ncmds; i++) {
        struct load_command cmd;
        fseek(fd, off, SEEK_SET);
        fread(&cmd, sizeof(struct load_command), 1, fd);
        if (cmd.cmd == LC_CODE_SIGNATURE) {
            uint32_t off_cs;
            fread(&off_cs, sizeof(uint32_t), 1, fd);
            uint32_t size_cs;
            fread(&size_cs, sizeof(uint32_t), 1, fd);
            
            uint8_t *cd = malloc(size_cs);
            fseek(fd, off_cs, SEEK_SET);
            fread(cd, size_cs, 1, fd);
            return cd;
        } else {
            off += cmd.cmdsize;
        }
    }
    return NULL;
}

void inject_trusts(int pathc, const char *paths[]) {
    printf("Injecting into trust cache...\n");
    
    static uint64_t tc = 0;
    if (tc == 0) tc = find_trustcache1();
    
    printf("Trust cache: 0x%llx\n", tc);
    
    struct trust_chain fake_chain;
    fake_chain.next = rk64SP(tc);
    *(uint64_t *)&fake_chain.uuid[0] = 0xabadbabeabadbabe;
    *(uint64_t *)&fake_chain.uuid[8] = 0xabadbabeabadbabe;
    
    int cnt = 0;
    uint8_t hash[CC_SHA256_DIGEST_LENGTH];
    hash_t *allhash = malloc(sizeof(hash_t) * pathc);
    for (int i = 0; i != pathc; ++i) {
        uint8_t *cd = getCodeDirectory1(paths[i]);
        if (cd != NULL) {
            getSHA256inplace1(cd, hash);
            memmove(allhash[cnt], hash, sizeof(hash_t));
            ++cnt;
        }
    }
    
    fake_chain.count = cnt;
    
    size_t length = (sizeof(fake_chain) + cnt * sizeof(hash_t) + 0xFFFF) & ~0xFFFF;
    uint64_t kernel_trust = kalloc(length);
    
    printf("Writing fake_chain\n");
    kwrite(kernel_trust, &fake_chain, sizeof(fake_chain));
    printf("allhash\n");
    kwrite(kernel_trust + sizeof(fake_chain), allhash, cnt * sizeof(hash_t));
    printf("Writing trust cache\n");
    wk64SP(tc, kernel_trust);
    
    printf("Injected trust cache\n");
}


















OSStatus SecStaticCodeCreateWithPathAndAttributes(CFURLRef path, SecCSFlags flags, CFDictionaryRef attributes, SecStaticCodeRef  _Nullable *staticCode);
OSStatus SecCodeCopySigningInformation(SecStaticCodeRef code, SecCSFlags flags, CFDictionaryRef  _Nullable *information);
CFStringRef (*_SecCopyErrorMessageString)(OSStatus status, void * __nullable reserved) = NULL;
extern int MISValidateSignatureAndCopyInfo(NSString *file, NSDictionary *options, NSDictionary **info);

extern NSString *MISCopyErrorStringForErrorCode(int err);
extern NSString *kMISValidationOptionRespectUppTrustAndAuthorization;
extern NSString *kMISValidationOptionValidateSignatureOnly;
extern NSString *kMISValidationOptionUniversalFileOffset;
extern NSString *kMISValidationOptionAllowAdHocSigning;
extern NSString *kMISValidationOptionOnlineAuthorization;

enum cdHashType {
    cdHashTypeSHA1 = 1,
    cdHashTypeSHA256 = 2
};

static char *cdHashName[3] = {NULL, "SHA1", "SHA256"};

static enum cdHashType requiredHash = cdHashTypeSHA256;

#define TRUST_CDHASH_LEN (20)

struct trust_mem {
    uint64_t next; //struct trust_mem *next;
    unsigned char uuid[16];
    unsigned int count;
    //unsigned char data[];
} __attribute__((packed));

struct hash_entry_t {
    uint16_t num;
    uint16_t start;
} __attribute__((packed));

//typedef uint8_t hash_t[TRUST_CDHASH_LEN];

bool is_amfi_cache(NSString *path) {
    return MISValidateSignatureAndCopyInfo(path, @{kMISValidationOptionAllowAdHocSigning: @YES, kMISValidationOptionRespectUppTrustAndAuthorization: @YES}, NULL) == 0;
}

NSString *cdhashFor(NSString *file) {
    NSString *cdhash = nil;
    SecStaticCodeRef staticCode;
    OSStatus result = SecStaticCodeCreateWithPathAndAttributes(CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)file, kCFURLPOSIXPathStyle, false), kSecCSDefaultFlags, NULL, &staticCode);
    const char *filename = file.UTF8String;
    if (result != errSecSuccess) {
        if (_SecCopyErrorMessageString != NULL) {
            CFStringRef error = _SecCopyErrorMessageString(result, NULL);
            LOG("Unable to generate cdhash for %s: %s", filename, [(__bridge id)error UTF8String]);
            CFRelease(error);
        } else {
            LOG("Unable to generate cdhash for %s: %d", filename, result);
        }
        return nil;
    }
    
    CFDictionaryRef cfinfo;
    result = SecCodeCopySigningInformation(staticCode, kSecCSDefaultFlags, &cfinfo);
    NSDictionary *info = CFBridgingRelease(cfinfo);
    CFRelease(staticCode);
    if (result != errSecSuccess) {
        LOG("Unable to copy cdhash info for %s", filename);
        return nil;
    }
    NSArray *cdhashes = info[@"cdhashes"];
    NSArray *algos = info[@"digest-algorithms"];
    NSUInteger algoIndex = [algos indexOfObject:@(requiredHash)];
    
    if (cdhashes == nil) {
        LOG("%s: no cdhashes", filename);
    } else if (algos == nil) {
        LOG("%s: no algos", filename);
    } else if (algoIndex == NSNotFound) {
        LOG("%s: does not have %s hash", cdHashName[requiredHash], filename);
    } else {
        cdhash = [cdhashes objectAtIndex:algoIndex];
        if (cdhash == nil) {
            LOG("%s: missing %s cdhash entry", file.UTF8String, cdHashName[requiredHash]);
        }
    }
    return cdhash;
}

NSArray *filteredHashes(uint64_t trust_chain, NSDictionary *hashes) {
#if !__has_feature(objc_arc)
    NSArray *result;
    @autoreleasepool {
#endif
        NSMutableDictionary *filtered = [hashes mutableCopy];
        for (NSData *cdhash in [filtered allKeys]) {
            if (is_amfi_cache(filtered[cdhash])) {
                LOG("%s: already in static trustcache, not reinjecting", [filtered[cdhash] UTF8String]);
                [filtered removeObjectForKey:cdhash];
            }
        }
        
        struct trust_mem search;
        search.next = trust_chain;
        while (search.next != 0) {
            uint64_t searchAddr = search.next;
            kreadOwO(searchAddr, &search, sizeof(struct trust_mem));
            //INJECT_LOG("Checking %d entries at 0x%llx", search.count, searchAddr);
            char *data = malloc(search.count * TRUST_CDHASH_LEN);
            kreadOwO(searchAddr + sizeof(struct trust_mem), data, search.count * TRUST_CDHASH_LEN);
            size_t data_size = search.count * TRUST_CDHASH_LEN;
            
            for (char *dataref = data; dataref <= data + data_size - TRUST_CDHASH_LEN; dataref += TRUST_CDHASH_LEN) {
                NSData *cdhash = [NSData dataWithBytesNoCopy:dataref length:TRUST_CDHASH_LEN freeWhenDone:NO];
                NSString *hashName = filtered[cdhash];
                if (hashName != nil) {
                    LOG("%s: already in dynamic trustcache, not reinjecting", [hashName UTF8String]);
                    [filtered removeObjectForKey:cdhash];
                    if ([filtered count] == 0) {
                        free(data);
                        return nil;
                    }
                }
            }
            free(data);
        }
        LOG("Actually injecting %lu keys", [[filtered allKeys] count]);
#if __has_feature(objc_arc)
        return [filtered allKeys];
#else
        result = [[filtered allKeys] retain];
    }
    return [result autorelease];
#endif
}

int injectTrustCache(NSArray <NSString*> *files, uint64_t trust_chain, int (*pmap_load_trust_cache)(uint64_t, size_t))
{
    @autoreleasepool {
        struct trust_mem mem;
        uint64_t kernel_trust = 0;
        
        mem.next = ReadKernel64(trust_chain);
        mem.count = 0;
        uuid_generate(mem.uuid);
        
        NSMutableDictionary *hashes = [NSMutableDictionary new];
        int errors=0;
        
        for (NSString *file in files) {
            NSString *cdhash = cdhashFor(file);
            if (cdhash == nil) {
                errors++;
                continue;
            }
            
            if (hashes[cdhash] == nil) {
                //LOG("%s: OK", file.UTF8String);
                hashes[cdhash] = file;
            } else {
                //LOG("%s: same as %s (ignoring)", file.UTF8String, [hashes[cdhash] UTF8String]);
            }
        }
        unsigned numHashes = (unsigned)[hashes count];
        
        if (numHashes < 1) {
            LOG("Found no hashes to inject");
            return errors;
        }
        
        
        NSArray *filtered = filteredHashes(mem.next, hashes);
        unsigned hashesToInject = (unsigned)[filtered count];
        //LOG("%u new hashes to inject", hashesToInject);
        if (hashesToInject < 1) {
            return errors;
        }
        
        size_t length = (32 + hashesToInject * TRUST_CDHASH_LEN + 0x3FFF) & ~0x3FFF;
        char *buffer = malloc(hashesToInject * TRUST_CDHASH_LEN);
        if (buffer == NULL) {
            LOG("Unable to allocate memory for cdhashes: %s", strerror(errno));
            return -3;
        }
        char *curbuf = buffer;
        for (NSData *hash in filtered) {
            memcpy(curbuf, [hash bytes], TRUST_CDHASH_LEN);
            curbuf += TRUST_CDHASH_LEN;
        }
        kernel_trust = kmem_alloc(length);
        
        mem.count = hashesToInject;
        kwriteOwO(kernel_trust, &mem, sizeof(mem));
        kwriteOwO(kernel_trust + sizeof(mem), buffer, mem.count * TRUST_CDHASH_LEN);
        if (pmap_load_trust_cache != NULL) {
            if (pmap_load_trust_cache(kernel_trust, length) != ERR_SUCCESS) {
                return -4;
            }
        } else {
            WriteKernel64(trust_chain, kernel_trust);
        }
        
        return (int)errors;
    }
}

__attribute__((constructor))
void ctor() {
    void *lib = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY);
    if (lib != NULL) {
        _SecCopyErrorMessageString = dlsym(lib, "SecCopyErrorMessageString");
        dlclose(lib);
    }
}
