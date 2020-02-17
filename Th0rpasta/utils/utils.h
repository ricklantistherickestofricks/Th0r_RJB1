//
//  utils.h



#ifndef utils_h
#define utils_h

#define get_dirfd(vol) open(vol, O_RDONLY, 0)
#define showMSG(msg, wait, destructive) showAlert(@"Th0r PASTA", msg, wait, destructive)
#define showPopup(msg, wait, destructive) showThePopup(@"", msg, wait, destructive)
#define __FILENAME__ (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)
#define _assert(test, message, fatal) do \
if (!(test)) { \
int saved_errno = errno; \
LOG("__assert(%d:%s)@%s:%u[%s]", saved_errno, #test, __FILENAME__, __LINE__, __FUNCTION__); \
} \
while (false)

void getOffsets(void);
void rootMe(uint64_t proc);
void unsandbox(uint64_t proc);
void remountFS(bool shouldRestore);
void setUID (uid_t uid, uint64_t proc);
void setGID(gid_t gid, uint64_t proc);

void restoreRootFS(void);
int trust_file(NSString *path);
void installSubstitute(void);
void saveOffs(void);
void createWorkingDir(void);
void createJBDir(void);

void installSSH(void);
void xpcFucker(void);
extern uint64_t set_csflags(uint64_t proc);
extern uint64_t set_tfplatform(uint64_t proc);
extern uint64_t setcsflags(uint64_t proc);
extern uint64_t platformize(uint64_t proc);

//void selfproc(void);
extern uint64_t selfproc(void);
void finish(bool shouldLoadTweaks);
void runoobtime(void);
void runExploit(int expType);
void initInstall(int packagerType);
bool canRead(const char *file);
struct tfp0;

//SETTINGS
BOOL shouldLoadTweaks(void);
int getExploitType(void);
int getPackagerType(void);

void initSettingsIfNotExist(void);
void saveCustomSetting(NSString *setting, int settingResult);
BOOL shouldRestoreFS(void);
void serverS(void);
void cydiainstalled(void);
void littlewienners(void);
void respringattempt(void);
void uicaching(void);
void remounting(void);
void settinghsp4(void);
void Packmandone(void);
void restoreyofs(void);
void th0rlabelyo(void);
void justJByo(void);
void loadingtweaks(void);
void cleaningshit(void);
void installingdebsboys(void);
void extractingbootstrap(void);
extern uint64_t proc_find(pid_t pid);
void labelchange(void);


/*int extension_create_file(kptr_t saveto, kptr_t sb, const char *path, size_t path_len, uint32_t subtype);
int extension_create_mach(kptr_t saveto, kptr_t sb, const char *name, uint32_t subtype);
int extension_add(kptr_t ext, kptr_t sb, const char *desc);

*/
//EXPLOIT
int autoSelectExploit(void);


#endif /* utils_h */
