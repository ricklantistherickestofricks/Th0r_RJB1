//
//  ViewController.m
//


//THIS PROJECT IS IN VERY EARLY STAGES OF DEVELOPMENT!

#import <time.h>
#import <UIKit/UIActivityViewController.h>

#import "ViewController.h"
#import "utils.h"
#include "amfi_utils.h"
#include "platform.h"
#include "offsetsSP.h"
#include "shenanigans.h"


#include "ImportantHolders.h"
#include "offsets.h"
#include "remap_tfp_set_hsp.h"
#include "kernel_exec.h"
#include "ArchiveUtils.h"
#include "libjb.h"
#include "QiLin.h"
#include <mach/host_priv.h>
#include <mach/mach_error.h>
#include <mach/mach_host.h>
#include <mach/mach_port.h>
#include <mach/mach_time.h>
#include <mach/task.h>
#include <mach/thread_act.h>
#include "reboot.h"
#include "kexecute.h"
#include "payload.h"
#include "Foundation/Foundation.h"
#include "file_utils.h"
#include "codesign.h"
#include <sys/sysctl.h>
#include <sys/utsname.h>
#include <stdio.h>
#include <pthread.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <dlfcn.h>

#include <FileProviderUI/FileProviderUI.h>
#import "kernel_memorySP.h"
#import "kernel_memory.h"
#import "patchfinder64og.h"

#include "kutils.h"
#include <spawn.h>
#include <copyfile.h>


#define in_bundle(obj) strdup([[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@obj] UTF8String])

#define localize(key) NSLocalizedString(key, @"")
#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]
#define pwned4ever_URL "https://www.dropbox.com/s/5iyz1s3ft3d7cr3/Th0r3.ipa"
#define pwned4ever_TEAM_TWITTER_HANDLE "pwned4ever____"
#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]
#define removeFile(file) if (fileExists(file)) {\
[[NSFileManager defaultManager]  removeItemAtPath:@(file) error:&error]; \
if (error) { \
LOG("[-] Error: removing file %s (%s)", file, [[error localizedDescription] UTF8String]); \
error = NULL; \
}\
}
#define copyFile(copyFrom, copyTo) [[NSFileManager defaultManager] copyItemAtPath:@(copyFrom) toPath:@(copyTo) error:&error]; \
if (error) { \
LOG("[-] Error copying item %s to path %s (%s)", copyFrom, copyTo, [[error localizedDescription] UTF8String]); \
error = NULL; \
}

#define moveFile(copyFrom, moveTo) [[NSFileManager defaultManager] moveItemAtPath:@(copyFrom) toPath:@(moveTo) error:&error]; \
if (error) {\
LOG("[-] Error moviing item %s to path %s (%s)", copyFrom, moveTo, [[error localizedDescription] UTF8String]); \
error = NULL; \
}



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface ViewController ()
@end

@implementation ViewController

//ViewController *sharedController = nil;

static ViewController *sharedController;


+ (instancetype)sharedController {
    return sharedController;
}




- (void)shareTh0r {
    struct utsname u = { 0 };
    uname(&u);
    //[self.jailbreak setEnabled:NO];
    //[self.jailbreak setHidden:YES];
    [NSString stringWithUTF8String:u.machine];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Wanna Share Th0r Jailbreak", nil) message:NSLocalizedString(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 Jailbreak?", nil) preferredStyle:UIAlertControllerStyleAlert];UIAlertAction *OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ya of course", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            if (SYSTEM_VERSION_GREATER_THAN(@"12.1.2")){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.jailbreak setEnabled:NO];//download it @ %@
                    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:localize(@"I'm using Th0r 3. A semi(no snapshot Included) Jailbreak tool for iOS 12-12.4, Updated 2/6/20 3:00PM-EDT. A copy paste of unc0ver & Ziyou, with updated bootstraps/exploits By:@%@ 🍻, to jailbreak my %@ iOS %@. Wanna download it? %@" ),@pwned4ever_TEAM_TWITTER_HANDLE , [NSString stringWithUTF8String:u.machine],[[UIDevice currentDevice] systemVersion], @pwned4ever_URL]] applicationActivities:nil];
                    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
                    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
                        activityViewController.popoverPresentationController.sourceView = self->_jailbreak;
                    }
                    [self presentViewController:activityViewController animated:YES completion:nil];
                    [self.jailbreak setEnabled:NO];
                    [self.jailbreak setHidden:YES];
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.jailbreak setEnabled:NO];//download it @ %@
                    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:localize(@"I'm using Th0r 3 Jailbreak tool for iOS 12-12.4, Updated 2/6/20 3:00PM-EDT. A copy paste of unc0ver & Ziyou, with updated bootstraps/exploits By:@%@ 🍻, to jailbreak my %@ iOS %@. Wanna download it? %@" ),@pwned4ever_TEAM_TWITTER_HANDLE , [NSString stringWithUTF8String:u.machine],[[UIDevice currentDevice] systemVersion], @pwned4ever_URL]] applicationActivities:nil];
                    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
                    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
                        activityViewController.popoverPresentationController.sourceView = self->_jailbreak;
                    }
                    [self presentViewController:activityViewController animated:YES completion:nil];
                    [self.jailbreak setEnabled:NO];
                    [self.jailbreak setHidden:YES];
                });
            }
        }];
        UIAlertAction *Cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Nah, don't want anyone to know", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.jailbreak setEnabled:NO];
                [self.jailbreak setHidden:YES];
            });
        }];
        [alertController addAction:OK];
        [alertController addAction:Cancel];
        [alertController setPreferredAction:Cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
}










- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    NSString *music=[[NSBundle mainBundle]pathForResource:@"Godzilla" ofType:@"mp3"];
    audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music]error:NULL];
    audioPlayer1.delegate=self;
    audioPlayer1.volume=1;
    audioPlayer1.numberOfLoops=-0;
    [audioPlayer1 play];
    [self.Th0rsharebtn setEnabled:NO];
    [self.Th0rsharebtn setHidden:YES];
    int checkuncovermarker = (file_exists("/.installed_unc0ver"));
    int checkziyouthormarker = (file_exists("/.ziyou_installed"));
    int checkCHIMERAmarker = (file_exists("/chimera"));

    int checkth0rmarker = (file_exists("/.bootstrapped_Th0r"));
    int checkelectramarker = (file_exists("/.bootstrapped_electra"));
    int checkJBRemoverMarker = (file_exists("/var/mobile/Media/.bootstrapped_electraremover"));
    int checkjailbreakdRun = (file_exists("/var/run/jailbreakd.pid"));
    int checkjailbreakdRuntmp = (file_exists("/var/tmp/jailbreakd.pid"));

    int checkpspawnhook = (file_exists("/var/run/pspawn_hook.ts"));
    int checkSubstratedhook = (file_exists("/usr/libexec/substrated"));
    int checkSlidehook = (file_exists("/var/tmp/slide.txt"));

    printf("Uncover marker exists?: %d\n",checkuncovermarker);
    printf("Uncover marker exists?: %d\n",checkuncovermarker);
    printf("JBRemover marker exists?: %d\n",checkJBRemoverMarker);
    printf("Th0r marker exists?: %d\n",checkth0rmarker);
    printf("Electra marker exists?: %d\n",checkelectramarker);
    printf("Jailbreakd Run marker exists?: %d\n",checkjailbreakdRun);
    printf("Jailbreakd Run marker from ziyou? exists?: %d\n",checkjailbreakdRuntmp);

    //myUiPickerView.delegate = self;
    // myUiPickerView.dataSource = self;
    // newTFcheckMyRemover4me =0;

     /**/
     uint32_t flags;
     csops(getpid(), CS_OPS_STATUS, &flags, 0);

    struct utsname u = { 0 };
    uname(&u);
    [NSString stringWithUTF8String:u.machine];

    //
    
    initSettingsIfNotExist();
    NSLog(@"Starting the jailbreak...");
    sharedController = self;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.backGroundView.bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0.9 blue:1.0 alpha:0.95] CGColor], (id)[[UIColor colorWithRed:0 green:0.9 blue:1.0 alpha:0.95] CGColor]];
    [self.backGroundView.layer insertSublayer:gradient atIndex:0];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/tmp/.jailbroken_ziyou"])
    {
        [[self buttontext] setEnabled:false];
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressFromNotification:) name:@"JB" object:nil];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [_jailbreak setTitle:localize(@"Wann gRoot?") forState:UIControlStateNormal];

    bool newTFcheckofCyforce;
    bool testRebootcheck;
    bool newTFcheckMyRemover4me;
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkJBRemoverMarker == 0) && (checkuncovermarker == 0) && (checkelectramarker == 0)){
            [_jailbreak setHidden:NO];
            [self.jailbreak  setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r?") forState:UIControlStateNormal];
           [self.Th0rsharebtn setEnabled:YES];
           [self.Th0rsharebtn setHidden:NO];
            [self shareTh0r];
            goto end;
        }
    
    

        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0) && (checkelectramarker == 0)){
            [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ JB Remover?") forState:UIControlStateNormal];
            //_pickviewarray = @[@"𝓢Ⓗ⒜𝕽ᴱ JB Remover"];
            [self.jailbreak  setHidden:NO];
            goto end;
        }
    
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 1) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0) && (checkelectramarker == 0)){
            [self.jailbreak  setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ JB Remover?") forState:UIControlStateNormal];
            //_pickviewarray = @[@"𝓢Ⓗ⒜𝕽ᴱ JB Remover"];
            [self.jailbreak  setHidden:NO];
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 0) && ((CS_PLATFORM_BINARY) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0) && (checkelectramarker == 0))){
            newTFcheckMyRemover4me = TRUE;
            [self.jailbreak  setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ JB Remover?") forState:UIControlStateNormal];
            //_pickviewarray = @[@"𝓢Ⓗ⒜𝕽ᴱ JB Remover"];
            [_jailbreak setHidden:NO];
            //[self shareTh0rRemover];
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 1) && ((CS_PLATFORM_BINARY) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0) && (checkelectramarker == 0))){
            newTFcheckMyRemover4me = TRUE;
            [self.jailbreak  setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ JB Remover?") forState:UIControlStateNormal];
            //_pickviewarray = @[@"𝓢Ⓗ⒜𝕽ᴱ JB Remover"];
            [_jailbreak setHidden:NO];
            //[self shareTh0rRemover];
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkuncovermarker == 0) && (checkpspawnhook == 0) && (newTFcheckMyRemover4me) && (checkJBRemoverMarker == 1)){
            newTFcheckMyRemover4me = TRUE;
            [self.jailbreak  setTitle:localize(@"Remove JB?") forState:UIControlStateNormal];
            goto end;
        }

        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            [_jailbreak setTitle:localize(@"Reboot Please") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            //enable3DTouch = NO;
            testRebootcheck = TRUE;
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            [_jailbreak setTitle:localize(@"Reboot Please") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];//
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1)  && (checkSlidehook == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0)  && (checkSlidehook == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkJBRemoverMarker == 0) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkCHIMERAmarker ==1)){

            testRebootcheck = FALSE;
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            checkCHIMERAmarker = TRUE;
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [_jailbreak setHidden:NO];
                 [_jailbreak setTitle:localize(@"Remove chimera 1st") forState:UIControlStateNormal];
                 testRebootcheck = FALSE;
                 newTFcheckofCyforce = FALSE;
                 newTFcheckMyRemover4me = TRUE;
                 {[[self buttontext] setEnabled:false];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            testRebootcheck = FALSE;
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = TRUE;
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [_jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 testRebootcheck = FALSE;
                 newTFcheckofCyforce = FALSE;
                 newTFcheckMyRemover4me = TRUE;
                 {[[self buttontext] setEnabled:false];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [_jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 testRebootcheck = FALSE;
                 newTFcheckofCyforce = FALSE;
                 newTFcheckMyRemover4me = TRUE;
                 {[[self buttontext] setEnabled:false];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkelectramarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot Please") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkelectramarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot Please") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkelectramarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot Please") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0) && (checkelectramarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot electra 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkJBRemoverMarker == 0) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkCHIMERAmarker ==1)){

            testRebootcheck = FALSE;
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            checkCHIMERAmarker = TRUE;
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [_jailbreak setHidden:NO];
                 [_jailbreak setTitle:localize(@"Remove chimera 1st") forState:UIControlStateNormal];
                 testRebootcheck = FALSE;
                 newTFcheckofCyforce = FALSE;
                 newTFcheckMyRemover4me = TRUE;
                 {[[self buttontext] setEnabled:false];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkelectramarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot electra 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkJBRemoverMarker == 0) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkCHIMERAmarker ==1)){

            testRebootcheck = FALSE;
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            checkCHIMERAmarker = TRUE;
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [_jailbreak setHidden:NO];
                 [_jailbreak setTitle:localize(@"Remove chimera 1st") forState:UIControlStateNormal];
                 testRebootcheck = FALSE;
                 newTFcheckofCyforce = FALSE;
                 newTFcheckMyRemover4me = TRUE;
                 {[[self buttontext] setEnabled:false];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp == 1) && (checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkelectramarker == 1 )){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot electra 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkJBRemoverMarker == 0) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkCHIMERAmarker ==1)){

            testRebootcheck = FALSE;
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            checkCHIMERAmarker = TRUE;
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [_jailbreak setHidden:NO];
                 [_jailbreak setTitle:localize(@"Remove chimera 1st") forState:UIControlStateNormal];
                 testRebootcheck = FALSE;
                 newTFcheckofCyforce = FALSE;
                 newTFcheckMyRemover4me = TRUE;
                 {[[self buttontext] setEnabled:false];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if (((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 1)) || ((checkjailbreakdRun == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 1) && (checkelectramarker == 1))){
            //_pickviewarray = @[@"Remove Electra"];
            [_jailbreak setTitle:localize(@"Remove All JB's") forState:UIControlStateNormal];
            newTFcheckMyRemover4me = TRUE;
            goto end;
        }
        
        if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkCHIMERAmarker == 0) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){

            if (shouldRestoreFS())
             {
                 [_jailbreak setTitle:localize(@"Restore gRoot FS") forState:UIControlStateNormal];

             }else {
                 [[self buttontext] setEnabled:true];
                 [[self jailbreak] setEnabled:true];
                 [self.buttontext setEnabled:true];
                 [self.jailbreak setEnabled:true];
                 [self.buttontext setHidden:false];
                 NSString *msg = [NSString stringWithFormat:localize(@"%s Enable gRoot?"), u.machine];
                 [_jailbreak setTitle:localize(msg) forState:UIControlStateNormal];
                 
             }
            goto end;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkuncovermarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver?") forState:UIControlStateNormal];
            printf("[*] Please reboot first\n");
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkuncovermarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver?") forState:UIControlStateNormal];
            printf("[*] Please reboot first\n");
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkuncovermarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot unc0ver?") forState:UIControlStateNormal];
            printf("[*] Please reboot first\n");
            goto end;
            return;
        }
        
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkelectramarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot electra?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkelectramarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [_jailbreak setTitle:localize(@"Reboot electra?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkelectramarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0)){
            //[_enableTweaks setEnabled:NO];
            [self.jailbreak setTitle:localize(@"Share JB Remover?") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1)){
            //[_enableTweaks setEnabled:NO];
            [self.jailbreak setTitle:localize(@"Share JB Remover?") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkJBRemoverMarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 1)){
            //[_enableTweaks setEnabled:NO];
            [self.jailbreak setTitle:localize(@"Share JB Remover?") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkuncovermarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot unc0ver JB?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkuncovermarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot unc0ver JB?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkuncovermarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot unc0ver JB?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkelectramarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 0)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra JB?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkelectramarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra JB?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        if ((flags & CS_PLATFORM_BINARY) && (checkelectramarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkpspawnhook == 1)){
            {[[self buttontext] setEnabled:false];}
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra JB?") forState:UIControlStateNormal];
            goto end;
            return;
        }
        
        if ((checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 ) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
            return;
        }
        if ((checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 ) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
            return;
        }
        if ((checkpspawnhook == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 ) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot unc0ver 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}
            goto end;
            return;
        }
        
        if ((checkuncovermarker == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0)){
            {[[self buttontext] setEnabled:false];}
            [self.jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
            //_pickviewarray = @[@"Remove JB"];
            goto end;
            return;
        }
        if ((checkuncovermarker == 0) && (checkpspawnhook == 1) && (checkCHIMERAmarker == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            {[[self buttontext] setEnabled:true];}

            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:true];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                 [self shareTh0r];
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
            
            return;
        }
        if ((checkuncovermarker == 1 || checkCHIMERAmarker == 1) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) ){
            {[[self buttontext] setEnabled:false];}
            [_jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            testRebootcheck = TRUE;
            //_pickviewarray = @[@"Reboot"];
            goto end;
            return;
        }
        if ((checkuncovermarker == 1 || checkCHIMERAmarker == 1) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            {[[self buttontext] setEnabled:false];}
            [_jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            testRebootcheck = TRUE;
            //_pickviewarray = @[@"Reboot"];
            goto end;
            return;
        }
        
        
        if ((checkpspawnhook == 0) && (checkuncovermarker == 1 || checkCHIMERAmarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkuncovermarker == 1 || checkCHIMERAmarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkuncovermarker == 1 || checkCHIMERAmarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }

        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1 || checkCHIMERAmarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 0 || checkCHIMERAmarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        
        
        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];//
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 1) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1 || checkCHIMERAmarker == 1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 1) && (checkelectramarker == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 1) && (checkelectramarker == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 1) && (checkelectramarker == 0) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }

        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 0) && (checkelectramarker == 1 || checkCHIMERAmarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1 || checkCHIMERAmarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Reboot electra 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        if ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0) && (checkelectramarker == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1)){
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
        
        if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 1)) {
            //_pickviewarray = @[@"Reboot"];
            testRebootcheck = TRUE;
            [self.jailbreak setTitle:localize(@"Please Reboot 1st") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:false];}

            goto end;
        }
    
    if ((checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
        if (shouldRestoreFS()){
            [[self buttontext] setEnabled:true];
            [[self jailbreak] setEnabled:true];
            [self.buttontext setEnabled:true];
            [self.jailbreak setEnabled:true];
            [self.buttontext setHidden:false];
            [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
             {[[self buttontext] setEnabled:true];}
             goto end;
             checkJBRemoverMarker = TRUE;
         }else{
             //[[self buttontext] setBackgroundColor:(black)];
             [[self buttontext] setEnabled:false];
             [[self jailbreak] setEnabled:false];
             [self.buttontext setEnabled:false];
             [self.jailbreak setEnabled:false];
             [self.buttontext setHidden:true];
             [self.Th0rsharebtn setEnabled:YES];
             [self.Th0rsharebtn setHidden:NO];
             [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
             [self shareTh0r];
             goto end;
             checkJBRemoverMarker = TRUE;
         }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
        if  ((checkpspawnhook == 0) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkelectramarker == 0) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            {[[self buttontext] setEnabled:true];}
            [self.jailbreak setTitle:localize(@"Share JB Remover?👍🏽") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            newTFcheckMyRemover4me = TRUE;
            goto end;
            return;
        }
        if  ((checkpspawnhook == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkelectramarker == 0) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            {[[self buttontext] setEnabled:true];}
            [self.jailbreak setTitle:localize(@"Share JB Remover?👍🏽") forState:UIControlStateNormal];
           // [self shareTh0rRemover];
            newTFcheckMyRemover4me = TRUE;
            goto end;
            return;
        }
        if  ((checkpspawnhook == 1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkelectramarker == 0) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            {[[self buttontext] setEnabled:true];}
            [self.jailbreak setTitle:localize(@"Share JB Remover?👍🏽") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            newTFcheckMyRemover4me = TRUE;
            goto end;
            return;
        }

        if ((flags & CS_PLATFORM_BINARY) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkelectramarker == 0) && (checkJBRemoverMarker == 1) && (checkth0rmarker == 0 || checkziyouthormarker ==0)){
            {[[self buttontext] setEnabled:true];}
            [self.jailbreak setTitle:localize(@"Share JB Remover?👍🏽") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            goto end;
            return;
        }
        if (newTFcheckMyRemover4me & CS_PLATFORM_BINARY){
            {[[self buttontext] setEnabled:true];}
            [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ JB Remover?") forState:UIControlStateNormal];
            //[self shareTh0rRemover];
            goto end;
            return;
        }
        if ((checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0 || checkCHIMERAmarker == 0)) {
            {[[self buttontext] setEnabled:true];}
            [self.Th0rsharebtn setEnabled:YES];
            [self.Th0rsharebtn setHidden:NO];
            [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r?👍🏽") forState:UIControlStateNormal];
            [self shareTh0r];
            goto end;
            return;
            
        }
        if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)) {
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            {[[self buttontext] setEnabled:true];}
           
            if (shouldRestoreFS())
             {
                 [self.jailbreak setTitle:localize(@"Restore strapped") forState:UIControlStateNormal];

             }else {
                 struct utsname u = { 0 };
                 uname(&u);
                 [NSString stringWithUTF8String:u.machine];

                 NSString *msg = [NSString stringWithFormat:localize(@"%s Enable gRoot?"), u.machine];
                 [self.jailbreak setTitle:localize(msg) forState:UIControlStateNormal];
                 
             }
            
            {[[self buttontext] setEnabled:true];}
            goto end;
        }
        if ((checkuncovermarker == 1 && checkCHIMERAmarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){
            {[[self buttontext] setEnabled:true];}

            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = TRUE;
            //_pickviewarray = @[@"Remove unc0ver JB"];
            [self.jailbreak setTitle:localize(@"Remove unc0ver?") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:true];}
            goto end;
            
        }
        if ((checkelectramarker == 1 || checkCHIMERAmarker == 1) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){
            {[[self buttontext] setEnabled:true];}

            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = TRUE;
            //_pickviewarray = @[@"Remove electra JB"];
            [self.jailbreak setTitle:localize(@"Remove Chimera?") forState:UIControlStateNormal];
            {[[self buttontext] setEnabled:true];}
            goto end;
            
        }
        if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 1)){
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            checkJBRemoverMarker = TRUE;
            {[[self buttontext] setEnabled:true];}

            //_pickviewarray = @[@"Jailbreak",@"𝓢Ⓗ⒜𝕽ᴱ JB Remover"];

            //[_jailbreak setTitleColor:localize(GL_BLUE) forState:UIControlStateNormal];
            [self.jailbreak setTitle:localize(@"Please select below") forState:UIControlStateNormal];
            [_jailbreak setEnabled:NO];
            goto end;
            
        }
        if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0 || checkCHIMERAmarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 0)){
            newTFcheckofCyforce = FALSE;
            newTFcheckMyRemover4me = FALSE;
            checkJBRemoverMarker = TRUE;
            {[[self buttontext] setEnabled:true];}

            
            if (shouldRestoreFS())
            {        [self.jailbreak setTitle:localize(@"Restore DAROOT FS") forState:UIControlStateNormal];

            }else{
            
                [self.jailbreak setTitle:localize(@"Journey 2 gRoot?") forState:UIControlStateNormal];
                [_jailbreak setEnabled:YES];
            }
            goto end;

        }
    
        if ((checkuncovermarker == 0 || checkCHIMERAmarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            if (shouldRestoreFS()){
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:true];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                 [self shareTh0r];
                 goto end;
                 checkJBRemoverMarker = TRUE;
             }
        }
    end:
    
    
    [NSString stringWithUTF8String:u.machine];
    NSString *msglabelscroll = [NSString stringWithFormat:localize(@"getuid = %d"), getuid()];

    [self.labeloutput1 setText:(msglabelscroll)];
    //create UITextView
    NSString *msg = [NSString stringWithFormat:localize(@"Th0r Failbreak\n For iOS 13-13.3\nSupports your %s\nvirgin %s\n%s\ngetuid = %d"), u.machine, platform.osversion,u.nodename ,getuid()];
    //[self.failbeaklblout setTitle:localize(msg) forState:UIControlStateNormal];
    ;
    
    //NSString *msglfailbreak = [NSString stringWithFormat:localize(@"Th0r Failbreak\n For your %s virgin iOS : %s\ngetuid = %d"), u.sysname,getuid(), u.machine];
    [self.failbeaklblout setText:(msg)];
    


    UIScrollView *myUIscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20,188,280,260)];
    //myUIscrollView.text = msglabelscroll;
   // myUIscrollView.textColor = [UIColor darkGrayColor];
    //myUIscrollView.font = [UIFont systemFontOfSize:19];
    [myUIscrollView setBackgroundColor:[UIColor blackColor]];
    //myUIscrollView.editable = YES;
    myUIscrollView.scrollEnabled = YES;
   // [myUIscrollView addSubview:myUIscrollView];
    
    
    UITextView *myUITextView = [[UITextView alloc] initWithFrame:CGRectMake(20,188,280,260)];
    myUITextView.text = msglabelscroll;
    myUITextView.textColor = [UIColor blackColor];
    myUITextView.font = [UIFont systemFontOfSize:19];
    [myUITextView setBackgroundColor:[UIColor clearColor]];
    myUITextView.editable = YES;
    myUITextView.scrollEnabled = YES;
    [myUIscrollView addSubview:myUITextView];
    //[myUITextView release];
    //[self.labeloutput1 setText:(msglabelscroll)];
    //[self.labeloutput1 setText:(msglabelscroll)];
    

    
    
    
    
//    [self.logscroller setText:(msglabelscroll)];
        printf("wtf\n");
    [UIView animateWithDuration:1.0f animations:^{
        [[self backGroundView] setAlpha:0.0f];
    }];
    [UIView animateWithDuration:2.0f animations:^{
        [[self backGroundView] setAlpha:1.0f];
    }];
    [self letsloopalpha];


    //Disable and fade out the settings button

    
}

- (void)letsloopalpha{
    
//    while (_justsettingsBARbackground == false)
    {
      [[self justsettingsBARbackground] setEnabled:true];
      [UIView animateWithDuration:1.0f animations:^{
          [[self justsettingsBARbackground] setAlpha:0.0f];
      }];
      [self.justsettingsBARbackground setEnabled:true];
      [UIView animateWithDuration:2.0f animations:^{
          [[self justsettingsBARbackground] setAlpha:1.0f];
      }];
    }
    
    

    
}


NSString *getURLForUsername(NSString *user) {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        return [@"tweetbot:///user_profile/" stringByAppendingString:user];
    } else if ([application canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        return [@"twitterrific:///profile?screen_name=" stringByAppendingString:user];
    } else if ([application canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
        return [@"tweetings:///user?screen_name=" stringByAppendingString:user];
    } else if ([application canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        return [@"twitter://user?screen_name=" stringByAppendingString:user];
    } else {
        return [@"https://mobile.twitter.com/" stringByAppendingString:user];
    }
    return nil;
}


- (IBAction)tappedOnHyperlink:(id)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSString *str = getURLForUsername(@pwned4ever_TEAM_TWITTER_HANDLE);
    NSURL *URL = [NSURL URLWithString:str];
    [application openURL:URL options:@{} completionHandler:nil];
}

    
-(void)updateProgressFromNotification:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *prog=[sender userInfo][@"JBProgress"];
        NSLog(@"Progress: %@",prog);
        [self.jailbreak setEnabled:NO];
        [self.jailbreak setAlpha:1];
        [self.jailbreak setTitle:prog forState:UIControlStateNormal];
    });
}

/***
 Thanks Conor
 **/
void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)runAnimateGradientOnView:(UIView*)view {
    [UIView animateWithDuration:HUGE_VAL animations:^{
        
    }];
}
 //NSString *str = [NSString stringWithFormat:@"TFP0: 0x%x", tfp0];
 //[NSString stringWithUTF8String:u.machine];
// NSString *msglabelscroll = [NSString stringWithFormat:localize(@"getuid = %d"), getuid()];
 //[UI labeloutput1 setText:(msglabelscroll)];
 //showMSG(str, true, false);
- (void)labelchange {
     //NSString *str = [NSString stringWithFormat:@"TFP0: 0x%x", tfp0];
     //[NSString stringWithUTF8String:u.machine];
    // NSString *msglabelscroll = [NSString stringWithFormat:localize(@"getuid = %d"), getuid()];
     //[self.labeloutput1 setText:(str)];
     //showMSG(str, true, false);

   // [NSString stringWithUTF8String:u.machine];
    NSString *msglabelscroll = [NSString stringWithFormat:localize(@"getuid = %d, TFP0: 0x%x"), getuid(), tfp0];
    [self.labeloutput1 setText:(msglabelscroll)];
    
}
- (void)rmounting {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"running mount"));
    });
}

- (void)finishOnView:(UIView*)view {
    
    [UIView animateWithDuration:0.5f animations:^{
        [[self sliceLabel] setAlpha:0.0f];
    }];
    
    [UIView animateWithDuration:2.5f animations:^{
        [[self paintBrush] setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    }];
}

///////////////////////----JELBREK TIEM----////////////////////////////

void logSlice(const char *sliceOfText) {
    //Simple Log Function
    NSString *stringToLog = [NSString stringWithUTF8String:sliceOfText];
    NSLog(@"%@", stringToLog);
}

- (void)updateStatus:(NSString*)statusNum {
    
    runOnMainQueueWithoutDeadlocking(^{
        [UIView transitionWithView:self.buttontext duration:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.buttontext setTitle:statusNum forState:UIControlStateNormal];
        } completion:nil];
    });
    
    
    
}

- (void)kek {
    runOnMainQueueWithoutDeadlocking(^{
        
       // [self.buttontext setTitle:localize(@"16k sockpuppet3.0") forState:UIControlStateNormal];

        [self.buttontext setTitle:[NSString stringWithFormat:@"Jailbroken"] forState:UIControlStateNormal];
    });
}
- (IBAction)stopbtnMusic:(id)sender {
    NSString *music=[[NSBundle mainBundle]pathForResource:@"Godzilla" ofType:@"mp3"];
    audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music]error:NULL];
    audioPlayer1.delegate=self;
    //audioPlayer1.volume=-5;
    //audioPlayer1.numberOfLoops=-1;
    //[audioPlayer1 play];
    [audioPlayer1 stop];
}
- (IBAction)startmusic:(id)sender {
    NSString *music=[[NSBundle mainBundle]pathForResource:@"Premonition" ofType:@"mp3"];
    audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music]error:NULL];
    audioPlayer1.delegate=self;
    audioPlayer1.volume=1;
    audioPlayer1.numberOfLoops=-1;
    [audioPlayer1 play];
    //[audioPlayer1 stop];}
}



//Wen eta bootloop?

bool restore_fs = false;
bool loadTweaks = true;
int exploitType = 0;


//0 = Cydia
//1 = Zebra

int packagerType = 0;
- (void)extractingbootstrap {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"bootstrapping"));
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(black)];
        [[self buttontext] setEnabled:false];
        

    });
    
}
- (void)serverS {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"Start Patching"));
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(black)];
        [[self buttontext] setEnabled:false];

    });
    
}
- (void)installingdebsboys {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"installing debs"));
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(white)];
        [[self buttontext] setEnabled:false];
    });
    
}
- (void)cleaningshit {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"cleaning🧹💩"));
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(black)];
        [[self buttontext] setEnabled:false];

    });
    
}
- (void)cydiainstalled {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"Cydia Installed"));
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(black)];
        [[self buttontext] setEnabled:false];
    });
}
- (void)littlewienners {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"stop crying😭"));
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(purple)];
        [[self buttontext] setEnabled:false];
    });
}
- (void)respringattempt {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"respring attempt "));});
    UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    //[[self buttontext] setBackgroundColor:(white)];
    [[self buttontext] setEnabled:false];
}
- (void)uicaching {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(white)];
        [[self buttontext] setEnabled:false];
        postProgress(localize(@"uicaching"));});
}
- (void)remounting {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(white)];
        [[self buttontext] setEnabled:false];
        postProgress(localize(@"remounting"));});
}
- (void)settinghsp4 {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(purple)];
        [[self buttontext] setEnabled:false];
        postProgress(localize(@"setting hsp4"));});
}
- (void)Packmandone {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;

        
        [self.Th0rsharebtn setEnabled:NO];
        [self.Th0rsharebtn setHidden:YES];

        int checkuncovermarker = (file_exists("/.installed_unc0ver"));
        int checkziyouthormarker = (file_exists("/.ziyou_installed"));

        int checkth0rmarker = (file_exists("/.bootstrapped_Th0r"));
        int checkelectramarker = (file_exists("/.bootstrapped_electra"));
        int checkJBRemoverMarker = (file_exists("/var/mobile/Media/.bootstrapped_electraremover"));
        int checkjailbreakdRun = (file_exists("/var/run/jailbreakd.pid"));
        int checkjailbreakdRuntmp = (file_exists("/var/tmp/jailbreakd.pid"));

        int checkpspawnhook = (file_exists("/var/run/pspawn_hook.ts"));
        int checkSubstratedhook = (file_exists("/usr/libexec/substrated"));
        int checkSlidehook = (file_exists("/var/tmp/slide.txt"));

        printf("Uncover marker exists?: %d\n",checkuncovermarker);
        printf("Uncover marker exists?: %d\n",checkuncovermarker);
        printf("JBRemover marker exists?: %d\n",checkJBRemoverMarker);
        printf("Th0r marker exists?: %d\n",checkth0rmarker);
        printf("Electra marker exists?: %d\n",checkelectramarker);
        printf("Jailbreakd Run marker exists?: %d\n",checkjailbreakdRun);
        printf("Jailbreakd Run marker from ziyou? exists?: %d\n",checkjailbreakdRuntmp);

        struct utsname u = { 0 };
        uname(&u);
        [NSString stringWithUTF8String:u.machine];

        
        
        if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){
            //[[self buttontext] setBackgroundColor:(black)];
            [[self buttontext] setEnabled:true];
            [[self jailbreak] setEnabled:true];
            [self.buttontext setEnabled:true];
            [self.jailbreak setEnabled:true];
            [self.buttontext setHidden:false];
            [self.Th0rsharebtn setEnabled:NO];
            [self.Th0rsharebtn setHidden:YES];
            if (shouldRestoreFS()){
                 [self.jailbreak setTitle:localize(@"Restore FS?") forState:UIControlStateNormal];
                 goto out;
             }else {

                 NSString *msg = [NSString stringWithFormat:localize(@"%s Enable Groot?"), u.machine];
                 [self.jailbreak setTitle:localize(msg) forState:UIControlStateNormal];
                 goto out;
             }
        }
         if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)) {
             //[[self buttontext] setBackgroundColor:(black)];
             [[self buttontext] setEnabled:true];
             [[self jailbreak] setEnabled:true];
             [self.buttontext setEnabled:true];
             [self.jailbreak setEnabled:true];
             [self.buttontext setHidden:false];
             [self.Th0rsharebtn setEnabled:NO];
             [self.Th0rsharebtn setHidden:YES];
             if (shouldRestoreFS())
              {
                  [self.jailbreak setTitle:localize(@"Restore strapped") forState:UIControlStateNormal];
                  goto out;
              }else {

                  NSString *msg = [NSString stringWithFormat:localize(@"%s Enable gRoot?"), u.machine];
                  [self.jailbreak setTitle:localize(msg) forState:UIControlStateNormal];
                  goto out;
              }
         }
        if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && ((checkpspawnhook == 0 && checkth0rmarker == 0) || checkziyouthormarker ==0) && (checkuncovermarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 0)){
            checkJBRemoverMarker = TRUE;
            //[[self buttontext] setBackgroundColor:(black)];
            [[self buttontext] setEnabled:true];
            [[self jailbreak] setEnabled:true];
            [self.buttontext setEnabled:true];
            [self.jailbreak setEnabled:true];
            [self.buttontext setHidden:false];
            [self.Th0rsharebtn setEnabled:NO];
            [self.Th0rsharebtn setHidden:YES];
            if (shouldRestoreFS()){
                [self.jailbreak setTitle:localize(@"Restore FS") forState:UIControlStateNormal];
                goto out;
            }else{
                [self.jailbreak setTitle:localize(@"Journey 2 gRoot?") forState:UIControlStateNormal];
                [self.jailbreak setEnabled:YES];
                goto out;
            }
        }
        if ((checkuncovermarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            if (shouldRestoreFS()){
                //[[self buttontext] setBackgroundColor:(black)];
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.Th0rsharebtn setEnabled:NO];
                [self.Th0rsharebtn setHidden:YES];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:true];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                 [self shareTh0r];
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            if (shouldRestoreFS()){
                
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:false];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            if (shouldRestoreFS()){
                
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:false];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            if (shouldRestoreFS()){
                //[[self buttontext] setBackgroundColor:(purple)];
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:false];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        else {
            if (shouldRestoreFS()){
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:true];
                 [[self jailbreak] setEnabled:true];
                 [self.buttontext setEnabled:true];
                 [self.jailbreak setEnabled:true];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:true];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                 [self shareTh0r];
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
           
        out:
        printf("hello remover or enabler");

        });
   // postProgress(localize(@"Packman done"));
}
- (void)th0rlabelyo {
    struct utsname u = { 0 };
    uname(&u);
    [NSString stringWithUTF8String:u.machine];

    NSString *msglfailbreak = [NSString stringWithFormat:localize(@"Th0r Failbreak\n For your %s virgin iOS : %s\ngetuid = %d"), u.sysname,getuid(), u.machine];
    [self.failbeaklblout setText:(msglfailbreak)];

}

- (void)restoreyofs {
    [self Packmandone];
    
}
- (void)justJByo {
    [self.Th0rsharebtn setEnabled:NO];
    [self.Th0rsharebtn setHidden:YES];
    struct utsname u = { 0 };
    uname(&u);
    [NSString stringWithUTF8String:u.machine];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;

        int checkuncovermarker = (file_exists("/.installed_unc0ver"));
        int checkziyouthormarker = (file_exists("/.ziyou_installed"));
        int checkth0rmarker = (file_exists("/.bootstrapped_Th0r"));
        int checkelectramarker = (file_exists("/.bootstrapped_electra"));
        int checkJBRemoverMarker = (file_exists("/var/mobile/Media/.bootstrapped_electraremover"));
        int checkjailbreakdRun = (file_exists("/var/run/jailbreakd.pid"));
        int checkjailbreakdRuntmp = (file_exists("/var/tmp/jailbreakd.pid"));
        int checkpspawnhook = (file_exists("/var/run/pspawn_hook.ts"));
        int checkSubstratedhook = (file_exists("/usr/libexec/substrated"));
        int checkSlidehook = (file_exists("/var/tmp/slide.txt"));
        printf("Uncover marker exists?: %d\n",checkuncovermarker);
        printf("Uncover marker exists?: %d\n",checkuncovermarker);
        printf("JBRemover marker exists?: %d\n",checkJBRemoverMarker);
        printf("Th0r marker exists?: %d\n",checkth0rmarker);
        printf("Electra marker exists?: %d\n",checkelectramarker);
        printf("Jailbreakd Run marker exists?: %d\n",checkjailbreakdRun);
        printf("Jailbreakd Run marker from ziyou? exists?: %d\n",checkjailbreakdRuntmp);
         if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){
            //[[self buttontext] setBackgroundColor:(black)];
            [[self buttontext] setEnabled:true];
            [[self jailbreak] setEnabled:true];
            [self.buttontext setEnabled:true];
            [self.jailbreak setEnabled:true];
            [self.buttontext setHidden:false];
            if (shouldRestoreFS()){
                 [self.jailbreak setTitle:localize(@"Restore FS?") forState:UIControlStateNormal];
                 goto out;
             }else {
                 NSString *msg = [NSString stringWithFormat:localize(@"%s Enable gRoot?"), u.machine];
                 [self.jailbreak setTitle:localize(msg) forState:UIControlStateNormal];
                 goto out;
             }
        }
         if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)) {
             //[[self buttontext] setBackgroundColor:(black)];
             [[self buttontext] setEnabled:true];
             [[self jailbreak] setEnabled:true];
             [self.buttontext setEnabled:true];
             [self.jailbreak setEnabled:true];
             [self.buttontext setHidden:false];
             if (shouldRestoreFS())
              {
                  [self.jailbreak setTitle:localize(@"Restore strapped") forState:UIControlStateNormal];
                  goto out;
              }else {
                  NSString *msg = [NSString stringWithFormat:localize(@"%s Enable gRoot?"), u.machine];
                  [self.jailbreak setTitle:localize(msg) forState:UIControlStateNormal];                  goto out;
              }
         }
        if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && ((checkpspawnhook == 0 && checkth0rmarker == 0) || checkziyouthormarker ==0) && (checkuncovermarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 0)){
            checkJBRemoverMarker = TRUE;
            //[[self buttontext] setBackgroundColor:(black)];
            [[self buttontext] setEnabled:true];
            [[self jailbreak] setEnabled:true];
            [self.buttontext setEnabled:true];
            [self.jailbreak setEnabled:true];
            [self.buttontext setHidden:false];
            if (shouldRestoreFS()){
                [self.jailbreak setTitle:localize(@"Restore FS") forState:UIControlStateNormal];
                goto out;
            }else{
                [self.jailbreak setTitle:localize(@"Journey 2 gRoot?") forState:UIControlStateNormal];
                [self.jailbreak setEnabled:YES];
                goto out;
            }
        }
        if ((checkuncovermarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            if (shouldRestoreFS()){
               // [[self buttontext] setBackgroundColor:(black)];
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:true];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                 [self shareTh0r];
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            if (shouldRestoreFS()){
                //[[self buttontext] setBackgroundColor:(black)];
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:false];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            //_pickviewarray = @[@"Remove JB"];
            if (shouldRestoreFS()){
                //[[self buttontext] setBackgroundColor:(black)];
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 
                 {[[self buttontext] setEnabled:false];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            if (shouldRestoreFS()){
                //[[self buttontext] setBackgroundColor:(black)];
                [[self buttontext] setEnabled:true];
                [[self jailbreak] setEnabled:true];
                [self.buttontext setEnabled:true];
                [self.jailbreak setEnabled:true];
                [self.buttontext setHidden:false];
                [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:true];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Remove unc0ver First") forState:UIControlStateNormal];
                 {[[self buttontext] setEnabled:false];}
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }else {
            if (shouldRestoreFS()){
                 //[[self buttontext] setBackgroundColor:(black)];
                 [[self buttontext] setEnabled:true];
                 [[self jailbreak] setEnabled:true];
                 [self.buttontext setEnabled:true];
                 [self.jailbreak setEnabled:true];
                 [self.buttontext setHidden:false];
                 [self.jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }else{
                 [[self buttontext] setEnabled:false];
                 [[self jailbreak] setEnabled:false];
                 [self.buttontext setEnabled:false];
                 [self.jailbreak setEnabled:false];
                 [self.buttontext setHidden:true];
                 [self.Th0rsharebtn setEnabled:YES];
                 [self.Th0rsharebtn setHidden:NO];
                 [self.jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                 [self shareTh0r];
                 goto out;
                 checkJBRemoverMarker = TRUE;
             }
        }
           
        out:

        //[_logscroller LOG[msglabelscroll)];
        printf("hello remover or enabler");
        });
    

}
- (void)loadingtweaks {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
        UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
        UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
        //[[self buttontext] setBackgroundColor:(white)];
        [[self buttontext] setEnabled:false];
        postProgress(localize(@"loading tweaks"));});
}




- (void)Th0rSelfReboot {
    struct utsname u = { 0 };
    uname(&u);
    [self.jailbreak setEnabled:YES];
    //[self.jailbreak setHidden:YES];



    [NSString stringWithUTF8String:u.machine];
      dispatch_async(dispatch_get_main_queue(), ^{
          [self.jailbreak setEnabled:YES];

          postProgress(localize(@"Rebooting."));
          [self.jailbreak setTitle:localize(@"Rebooting.") forState:UIControlStateNormal];
          sleep(1);
          postProgress(localize(@"Rebooting.."));
          [self.jailbreak setTitle:localize(@"Rebooting..") forState:UIControlStateNormal];
          postProgress(localize(@"Rebooting..."));
          [self.jailbreak setTitle:localize(@"Rebooting...") forState:UIControlStateNormal];
          sleep(1);

          postProgress(localize(@"Reboot failed?"));
          [self.jailbreak setTitle:localize(@"Reboot failure...") forState:UIControlStateNormal];
        });
     

}
void untar3(FILE *a, const char *path);


void wannaSliceOfMe() {
    //Run The Exploit
    
    
    runOnMainQueueWithoutDeadlocking(^{
        logSlice("Jailbreaking");});
    
    //INIT. EXPLOIT. HERE WE ACHIEVE THE FOLLOWING:
    //[*] TFP0
    //[*] ROOT
    //[*] UNSANDBOX
    //[*] OFFSETS
    
    
    //0 = MachSwap
    //1 = MachSwap2
    //2 = Voucher_Swap
    //3 = SockPuppet
    UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    
    //[[UIButton self] setEnabled:false];

     //[[UIButton self] setColor:(black):true];

    runOnMainQueueWithoutDeadlocking(^{
        logSlice("running exploit");});

    postProgress(localize(@"running exploit"));
    runExploit(getExploitType()); //Change this depending on what device you have...
    
    postProgress(localize(@"exploit done"));

    serverS();

    //getOffsets();
    offs_init();
    //kernel_task_port;
    //init_with_kbase(kernel_task_port, basefromkernelmemory);
   /* FILE *f = fopen("/var/mobile/.roottest", "w");
    if (f == 1){
        printf("[-] Failed to escape sandbox!");
    }
    */
    int rv = open("/var/mobile/testwriteto_var_mobile.txt",O_RDWR|O_CREAT);
    printf("[*] test write returned rv = %d\n", rv);

    printf("[*] we can overcome the devils\n");
    printf("[*] wrote testwrite2020_Media test file : %d\n", rv);
    close(rv);
    int rvt = open("/var/mobile/Media/testwrite2020_Media.txt",O_RDWR|O_CREAT);
    printf("[*] Media/testwrite2020_Media.txt write returned rv = %d\n", rvt);
    close(rvt);
    
    //init_with_kbase(taskforpidzero, basefromkernelmemory);
    //MID-POINT. HERE WE ACHIEVE THE FOLLOWING:
    //[*] INIT KEXECUTE
    //[*] REMOUNT //
    //[*] REQUIRED FILES TO FINISH ARE EXTRACTED
    //[*] REMAP
    //extractFileWithoutInjection
    //extractFile(get_bootstrap_file1(@"AIO2.tar"), @"/var/containers/");
    //installSSH();
    //trust_file(@"/usr/lib/libsubstitute.dylib");
//
    //init_Kernel_Execute();
    //init_kexecute();
    //labelchange();
    //remounting();
    //remountFS(restore_fs);

   // createWorkingDir();
    //saveOffs();
   // settinghsp4();
    
    //setHSP4();
    //initInstall(getPackagerType());
//    Packmandone();
    offsetsSPJ_init();
    //set_csflags(current_proc_OOB);
    //
//    set_csblob(current_proc_OOB);

    printf("our_proc is %llx\n", current_proc_OOB);
    

    
    if (!fileExists("/var/containers/Bundle/.installed_rootlessJB3")) {
           
           if (fileExists("/var/containers/Bundle/iosbinpack64")) {
               
               printf("[*] Uninstalling previous build...\n");
               
               unlink("/var/LIB");
               unlink("/var/ulb");
               unlink("/var/bin");
               unlink("/var/sbin");
               unlink("/var/containers/Bundle/tweaksupport/Applications");
               unlink("/var/Apps");
               unlink("/var/profile");
               unlink("/var/motd");
               unlink("/var/dropbear");
               unlink("/var/containers/Bundle/tweaksupport");
               unlink("/var/containers/Bundle/iosbinpack64");
               unlink("/var/containers/Bundle/dylibs");
               unlink("/var/log/testbin.log");
               
               if (fileExists("/var/log/jailbreakd-stdout.log")) unlink("/var/log/jailbreakd-stdout.log");
               if (fileExists("/var/log/jailbreakd-stderr.log")) unlink("/var/log/jailbreakd-stderr.log");
           }
           
           printf("[*] Installing bootstrap...\n");
           
           chdir("/var/containers/Bundle/");
           //FILE *bootstrap = fopen((char*)in_bundle("bootstrap/tars/iosbinpack64.tar"), "r");
            createWorkingDir();
            //extractFileWithoutInjection(@"bootstrap/tars/iosbinpack64.tar", @"/var/containers/Bundle/");
           //fclose(bootstrap);
           FILE *bootstrap = fopen((char*)in_bundle("bootstrap/tars/iosbinpack64.tar"), "r");
           untar(bootstrap, "/var/containers/Bundle/iosbinpack64/");
            //extractFileWithoutInjection(@"tars/iosbinpack64.tar", @"/var/containers/Bundle/");
           fclose(bootstrap);
        
           FILE *tweaks = fopen((char*)in_bundle("bootstrap/tars/tweaksupport.tar"), "r");
           untar(tweaks, "/var/containers/Bundle/");
           fclose(tweaks);
           
           printf("[+] Creating symlinks...\n");
           
           symlink("/var/containers/Bundle/tweaksupport/Library", "/var/LIB");
           symlink("/var/containers/Bundle/tweaksupport/usr/lib", "/var/ulb");
           symlink("/var/containers/Bundle/tweaksupport/Applications", "/var/Apps");
           symlink("/var/containers/Bundle/tweaksupport/bin", "/var/bin");
           symlink("/var/containers/Bundle/tweaksupport/sbin", "/var/sbin");
           symlink("/var/containers/Bundle/tweaksupport/usr/libexec", "/var/libexec");
           
           close(open("/var/containers/Bundle/.installed_rootlessJB_pwned", O_CREAT));
           
           //limneos
           symlink("/var/containers/Bundle/iosbinpack64/etc", "/var/etc");
           symlink("/var/containers/Bundle/tweaksupport/usr", "/var/usr");
           symlink("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "/var/bin/killall");
           
           printf("[+] Installed bootstrap!\n");
       }
    unlink("/var/containers/Bundle/.installed_rootlessJB_pwned");
    mkdir("/var/containers/Bundle/iosbinpack64/", 0777);
    chdir("/var/containers/Bundle/iosbinpack64/");
    FILE *bootstrap = fopen((char*)in_bundle("bootstrap/tars/iosbinpack64.tar"), "r");
     createWorkingDir();
    untar(bootstrap, "/var/containers/Bundle/iosbinpack64/");
     //extractFileWithoutInjection(@"tars/iosbinpack64.tar", @"/var/containers/Bundle/");
    fclose(bootstrap);
    
    
    
     if (!fileExists("/var/bin/strings")) {
         chdir(in_bundle("/"));
        // execCmd1("ls", "-la");
         FILE *essentials = fopen((char*)in_bundle("bootstrap/tars/bintools.tar"), "r");
         chdir(in_bundle("bootstrap/tars/"));
         //execCmd1("ls -la");
         
         untar(essentials, "/");
         fclose(essentials);
         
         FILE *dpkg = fopen((char*)in_bundle("bootstrap/tars/dpkg-rootless.tar"), "r");
         untar(dpkg, "/");
         fclose(dpkg);
     }
    
     //---- update dropbear ----//
     chdir("/var/containers/Bundle/");
     
     unlink("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear");
     unlink("/var/containers/Bundle/iosbinpack64/usr/bin/scp");

     FILE *fixed_dropbear = fopen((char*)in_bundle("bootstrap/tars/dropbear.v2018.76.tar"), "r");
     untar(fixed_dropbear, "/var/containers/Bundle/");
     fclose(fixed_dropbear);
     
    //---- update jailbreakd ----//
    
       //---- update jailbreakd ----//
       
       unlink("/var/containers/Bundle/iosbinpack64/bins/jailbreakd");
       if (!fileExists(in_bundle("bootstrap/bins/jailbreakd"))) {
           chdir(in_bundle("bootstrap/bins/"));
           
           FILE *jbd = fopen(in_bundle("bootstrap/bins/jailbreakd.tar"), "r");
           untar(jbd, ("/var/containers/Bundle/iosbinpack64/bins/"));
           untar(jbd, ("/var/containers/Bundle/iosbinpack64/ziyou/"));
           fclose(jbd);
           
           unlink(in_bundle("bootstrap/bins/jailbreakd.tar"));
       }
       cp("/var/containers/Bundle/iosbinpack64/bins/jailbreakd", "/var/containers/Bundle/iosbinpack64/bins/jailbreakd");
    cp("/var/containers/Bundle/iosbinpack64/bins/jailbreakd", "/var/containers/Bundle/iosbinpack64/jailbreakd");

    unlink("/var/containers/Bundle/iosbinpack64/bins/pspawn.dylib");
    if (!fileExists(in_bundle("bootstrap/bins/pspawn.dylib"))) {
        chdir(in_bundle("bootstrap/bins/"));
        
        FILE *jbd = fopen(in_bundle("bootstrap/bins/pspawn.dylib.tar"), "r");
        untar(jbd, ("/var/containers/Bundle/iosbinpack64/bins/pspawn.dylib"));
        fclose(jbd);
        
        unlink(in_bundle("bootstrap/bins/pspawn.dylib.tar"));
    }
    cp(("/var/containers/Bundle/iosbinpack64/bins/pspawn.dylib"), "/var/containers/Bundle/iosbinpack64/bins/pspawn.dylib");
    cp(("/var/containers/Bundle/iosbinpack64/bins/pspawn.dylib"), "/var/containers/Bundle/iosbinpack64/pspawn.dylib");

    unlink("/var/containers/Bundle/iosbinpack64/bins/amfid_payload.dylib");
    if (!fileExists(in_bundle("bootstrap/bins/amfid_payload.dylib"))) {
        chdir(in_bundle("bootstrap/bins/"));
        
        FILE *jbd = fopen(in_bundle("bootstrap/bins/amfid_payload.dylib.tar"), "r");
        untar(jbd, ("/var/containers/Bundle/iosbinpack64/bins/"));
        fclose(jbd);
        
        unlink(in_bundle("bootstrap/bins/amfid_payload.dylib.tar"));
    }
    cp(in_bundle("/var/containers/Bundle/iosbinpack64/bins/amfid_payload.dylib"), "/var/containers/Bundle/iosbinpack64/bins/amfid_payload.dylib");
    cp(in_bundle("/var/containers/Bundle/iosbinpack64/bins/amfid_payload.dylib"), "/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");

    unlink("/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
    if (!fileExists(in_bundle("bootstrap/bins/TweakInject.dylib"))) {
        chdir(in_bundle("bootstrap/bins/"));
        
        FILE *jbd = fopen(in_bundle("bootstrap/bins/TweakInject.tar"), "r");
        untar(jbd, ("/var/containers/Bundle/iosbinpack64/bins/"));
        fclose(jbd);
        
        unlink(in_bundle("bootstrap/bins/TweakInject.tar"));
    }
    cp("/var/containers/Bundle/iosbinpack64/bins/TweakInject.dylib", "/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
    
    unlink("/var/log/pspawn_payload_xpcproxy.log");
    

    close(open("/var/containers/Bundle/.installed_rootlessJB_pwned", O_CREAT));

    //---- codesign patch ----//
    
    
    if (!fileExists(in_bundle("bootstrap/bins/tester"))) {
        chdir(in_bundle("bootstrap/bins/"));
        
        FILE *f1 = fopen(in_bundle("bootstrap/bins/tester.tar"), "r");
        untar(f1, in_bundle("bootstrap/bins/tester"));
        fclose(f1);
        
        unlink(in_bundle("bootstrap/bins/tester.tar"));
    }
    
    chmod(in_bundle("bootstrap/bins/tester"), 0777); // give it proper permissions
    #define failIf(condition, message, ...) if (condition) {\
    LOG(message);\
    goto end;\
    }
    #define LOG(what, ...) [self log:[NSString stringWithFormat:@what"\n", ##__VA_ARGS__]];\
    printf("\t"what"\n", ##__VA_ARGS__)
    //trust_file(in_bundle("bootstrap/bins/tester"));//trust_file(in_bundle("bootstrap/bins/tester"));
    //selfproc();
   // set_csflags(current_proc_OOB);
       
       
    if (execCmd1(in_bundle("bootstrap/bins/tester"), NULL, NULL)) {
       
        //load_legacy_trustcache_   ios 13 fffffff00722bb74         movz       w0, #0x2e
        //pmap_load_image4_trust_cache: fffffff00722b368
        //_pmap_is_trust_cache_loaded: fffffff00722bb7c
        //pmap_lookup_in_loaded_trust_caches: fffffff00722bd28
        //_pmap_lookup_in_static_trust_cache: fffffff00722bf9c         b          loc_fffffff007237fac  ; DATA XREF=sub_fffffff005f37364+4, 0xfffffff006dc2518
        int rvtrust = (trust_file(@"/var/containers/Bundle/iosbinpack64"));//inject_trusts(1, (const char **)&(const char*[]){"/var/containers/Bundle/iosbinpack64"});//
        if (rvtrust == -1){
            printf("[-] Failed to trust binaries!= %d\n", rvtrust);
        }
        (trust_file(@"/var/containers/Bundle/tweaksupport"));
        //inject_trusts(1, (const char **)&(const char*[]){"/var/containers/Bundle/iosbinpack64/bins/"});
        //inject_trusts(1, (const char **)&(const char*[]){"/var/containers/Bundle/tweaksupport"});//
        if (rvtrust == -1){
             printf("[-] Failed to trust binaries!= %d\n", rvtrust);
        }
        int ret = execCmd1("/var/containers/Bundle/iosbinpack64/test", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        if (ret == -1){
            printf("[-] Failed to run test binary! = %d\n", ret);
        }
        printf("[+] Successfully trusted binaries!\n");
    }
    else {
        printf("[+] binaries already trusted?\n");
    }
    
    //---- let's go! ----//

       //prepare_payload(); // this will chmod 777 everything

       //----- setup SSH -----//
       mkdir("/var/dropbear", 0777);
       unlink("/var/profile");
       unlink("/var/motd");
       chmod("/var/profile", 0777);
       chmod("/var/motd", 0777);

       cp("/var/containers/Bundle/iosbinpack64/etc/profile", "/var/profile");
       cp("/var/containers/Bundle/iosbinpack64/etc/motd", "/var/motd");
        //set_csflags(current_proc_OOB);
        set_selfproc(current_proc_OOB);
        runShenPatch();//set_csblob(current_proc_OOB);

       // kill it if running
    
       execCmd1("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "-SEGV", "dropbear", NULL, NULL, NULL, NULL, NULL);
    //launchAsPlatform for rv2 suppposed to be
       int rv2 = (execCmd1("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL));
        if (rv2 != 0){
            printf("[-] Failed to launch dropbear =%d\n", rv2);
        }
    
       pid_t dpd = find_pid_of_proc("dropbear");
    
       usleep(1000);
    if (!dpd){
        int rvtr = (execCmd1("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL));
        if (rvtr !=0 ){
            printf("[-] Failed to launch dropbear = %d\n",rvtr);
        }
    }
    
    int rvtrrebackboardd = systemCmd1("chmod +x /usr/bin/rebackboardd");
    if (rvtrrebackboardd !=0 ){
        printf("[-] Failed to chmod rebackboardd = %d\n",rvtrrebackboardd);
    }
    int rvtruicache =  systemCmd1("/usr/bin/uicache");
    if (rvtruicache !=0 ){
        printf("[-] Failed to launch uicache = %d\n",rvtruicache);
    }
    cp(in_bundle("/killall"), "/var/containers/Bundle/iosbinpack64/usr/bin/killall");

   char const *somearg =  "backboardd";
    
    //execCmdV1(<#const char *cmd#>, <#int argc#>, <#const char *const *argv#>, <#^(pid_t)unrestrict#>)
    int ervtr1K = execCmdV1(in_bundle("/killall"), 0,somearg, NULL);
    printf("[-] Failed attempt 0 to launch killall = %d\n",ervtr1K);
    int ervtrK = execCmdV1(in_bundle("/killall"), 0,"backboardd", NULL);
    printf("[-] Failed attempt 0 to launch killall = %d\n",ervtrK);

    int rvtrK = execCmd1(in_bundle("/killall"), "backboardd");
    if (rvtrK !=0 ){
        printf("[-] Failed attempt 1 to launch killall = %d\n",rvtrK);
    }
    int rvtrK1 = execCmd1(in_bundle("killall"), "backboardd");

    //int rvtrK = execCmd1("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "backboardd",NULL, NULL, NULL, NULL, NULL, NULL);

    if (rvtrK1 !=0 ){
        printf("[-] Failed attempt 2 to launch killall = %d\n",rvtrK1);
    }
    
       //------------- launch daeamons -------------//
    //getOffsets();
    //initQiLin(tfpzero, basefromkernelmemory);
    //init_kernel1(basefromkernelmemory, NULL);
    //term_kexecute();
    //loadingtweaks();
    //finish(loadTweaks);
     uint64_t launchd_proc = (get_proc_struct_for_pid(1));
     printf("launchd_proc is %llx\n", launchd_proc);
     uint64_t kern_proc = get_proc_struct_for_pid(0);
     printf("kern_proc is %llx\n", kern_proc);
     uint32_t amfid_pid = find_pid_of_proc("amfid");
     uint64_t amfid_proc = get_proc_struct_for_pid(amfid_pid);
     printf("amfid_pid is %d\n", amfid_pid);
     printf("amfid_proc is %llx\n", amfid_proc);
     uint32_t cfprefsd_pid = find_pid_of_proc("cfprefsd");
     printf("cfprefsd_pid is %d\n", cfprefsd_pid);
     
    
    th0rlabelyo();
    
    //sleep(3);
    
    NSString *str = [NSString stringWithFormat:@"TFP0: 0x%x getuid :%d\nYou know i done fucked your FS right?", tfp0, getuid()];
    showMSG(str, true, false);
    exit (1);
    
}

int systemCmd1(const char *cmd) {
    const char *argv[] = {"sh", "-c", (char *)cmd, NULL};
    return execCmdV1("/bin/sh", 3, argv, NULL);
}

extern char **environ;
NSData *lastSystemOutput1=nil;

int execCmdV1(const char *cmd, int argc, const char * const* argv, void (^unrestrict)(pid_t)) {
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
   // LOG("%s(%d) command: %@", __FUNCTION__, pid, cmdstr);
    
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
                   // LOG("%s(%d): %@", __FUNCTION__, pid, line);
                    [line setString:@""];
                } else {
                    s[0] = c;
                    [line appendString:@(s)];
                }
            }
            if ([line length] > 0) {
               // LOG("%s(%d): %@", __FUNCTION__, pid, line);
            }
            lastSystemOutput1 = [outData copy];
        }
        if (waitpid(pid, &rv, 0) == -1) {
           // LOG("ERROR: Waitpid failed");
        } else {
           // LOG("%s(%d) completed with exit status %d", __FUNCTION__, pid, WEXITSTATUS(rv));
        }
        
    } else {
       // LOG("%s(%d): ERROR posix_spawn failed (%d): %s", __FUNCTION__, pid, rv, strerror(rv));
        rv <<= 8; // Put error into WEXITSTATUS
    }
    if (valid_pipe) {
        close(out_pipe[0]);
    }
    return rv;
}

int execCmd1(const char *cmd, ...) {
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
    
    int rv = execCmdV1(cmd, argc, argv, NULL);
    return WEXITSTATUS(rv);
}



///////////////////////----BOOTON----////////////////////////////



NSString *get_path_res1(NSString *resource) {
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

NSString *get_bootstrap_file1(NSString *file)
{
    return get_path_res1([@"bootstrap/" stringByAppendingString:file]);
}


- (IBAction)CreditsDue:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Credits" message:@"Not much to credit here, since the code is directly copied from unc0ver! The small amount of code that actually is different IDK who made, so I can't credit a ghost. If you feel like you weren't credited here - GO CRY ELSEWHERE\n code modified & updated @pwned4ever____" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *THANKS = [UIAlertAction actionWithTitle:@"Thanks!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:THANKS];
    [alertController setPreferredAction:THANKS];
    [self presentViewController:alertController animated:false completion:nil];
    
}

- (IBAction)Credits:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Credits" message:@"Not much to credit here, since the code is directly copied from unc0ver! The small amount of code that actually is different IDK who made, so I can't credit a ghost. If you feel like you weren't credited here - GO CRY ELSEWHERE\n code modified & updated @pwned4ever____" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *THANKS = [UIAlertAction actionWithTitle:@"Thanks!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:THANKS];
    [alertController setPreferredAction:THANKS];
    [self presentViewController:alertController animated:false completion:nil];
    
}




- (IBAction)Th0rsharebtn:(id)sender {

    [self shareTh0r];
    
}



- (IBAction)jailbreak:(id)sender {
    
    //HERE
    if (shouldRestoreFS())
    {
        [_jailbreak setTitle:localize(@"Restoring FS") forState:UIControlStateNormal];

        restore_fs = true;
        saveCustomSetting(@"RestoreFS", 1);
    } else {
        restore_fs = false;
    }
    
    if (shouldLoadTweaks())
    {
        loadTweaks = true;
    } else {
        loadTweaks = false;
    }
    [self.jailbreak setEnabled:false];
    [self.buttontext setEnabled:false];
    [self.justsettingsBARbackground setHidden:true];
    [self.justsettingsBARbackground setEnabled:false];

    [[self settingsButton] setEnabled:false];
    [UIView animateWithDuration:1.0f animations:^{
        [[self settingsButton] setAlpha:0];
    }];
    //Disable The Button
    [sender setEnabled:false];
    
    //Disable and fade out the settings button
    [[self settingsButton] setEnabled:false];
    [UIView animateWithDuration:1.0f animations:^{
        [[self settingsButton] setAlpha:0];
    }];
    
    //Run the exploit in a void.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        wannaSliceOfMe();
    });
}







@end
