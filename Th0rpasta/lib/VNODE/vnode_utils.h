#include "common.h"
int vnode_lookup(const char *path, int flags, uint64_t *vnode, uint64_t vfs_context);
kptr_t _vfs_context(void);
int _vnode_put(uint64_t vnode);
uint64_t vnodeForPath(const char *path);
int64_t vnodeForSnapshot(int fd, char *name);
uint64_t zm_fix_addr1(uint64_t addr);
const char *find_snapshot_with_ref(const char *vol, const char *ref);
