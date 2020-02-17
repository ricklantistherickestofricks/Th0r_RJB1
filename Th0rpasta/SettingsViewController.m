//
//  SettingsViewViewController.m


#import "SettingsViewController.h"
#import "utils/utils.h"
#include "file_utils.h"
#import <sys/utsname.h>
@interface SettingsViewController ()

@end

@implementation SettingsViewController
#define localize(key) NSLocalizedString(key, @"")
#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]


- (void)viewDidLoad {
    [super viewDidLoad];

    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.backGroundView.bounds;
//    gradient.colors = @[(id)[[UIColor colorWithRed:0.26 green:0.81 blue:0.64 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.35 blue:0.62 alpha:1.0] CGColor]];
//green:0.9 blue:1.0 alpha:0.95
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0.5 blue:1 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.35 blue:0.62 alpha:0.1] CGColor]];
    
    [self.backGroundView.layer insertSublayer:gradient atIndex:0];

        CAGradientLayer *gradientSV = [CAGradientLayer layer];
        
        gradientSV.frame = self.settingsGradientView.bounds;
    //    gradient.colors = @[(id)[[UIColor colorWithRed:0.26 green:0.81 blue:0.64 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.35 blue:0.62 alpha:1.0] CGColor]];
    //green:0.9 blue:1.0 alpha:0.95
        gradientSV.colors = @[(id)[[UIColor colorWithRed:0 green:0.5 blue:1 alpha:0.8] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.15 blue:0.62 alpha:0.1] CGColor]];
        
        [self.settingsGradientView.layer insertSublayer:gradientSV atIndex:0];

        
    
    if (shouldLoadTweaks())
    {
        [_loadTweaksSwitch setOn:true];
    } else {
        [_loadTweaksSwitch setOn:false];
    }
    
    //0 = Cydia
    //1 = Zebra
    if (getPackagerType() == 0)
    {
        [_Cydia_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    //0 = MS
    //1 = MS2
    //2 = VS
    if (getExploitType() == 0)
    {
        [_VS_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 1)
    {
        [_VS_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 2)
    {
        [_VS_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 3)
    {
        [_SP_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
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


   
     if ([[NSFileManager defaultManager] fileExistsAtPath:@"/tmp/.jailbroken_ziyou"])


     
     
     
    if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){

        if (shouldRestoreFS())
         {
             [_jailbreak setTitle:localize(@"Restore -already strapped") forState:UIControlStateNormal];
             [_restoreFSSwitch setOn:true];
             goto end;
         }else {
             [_restoreFSSwitch setOn:false];
             [_jailbreak setTitle:localize(@"Enable gRoot?") forState:UIControlStateNormal];
             goto end;
         }
    }
     if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)) {
         //{[[self buttontext] setEnabled:true];}
         if (shouldRestoreFS()){
             [_restoreFSSwitch setOn:true];
              [_jailbreak setTitle:localize(@"Restore strapped") forState:UIControlStateNormal];
              goto end;
          }else {
              [_restoreFSSwitch setOn:false];
              [_jailbreak setTitle:localize(@"Enable gRoot?") forState:UIControlStateNormal];
              goto end;
          }
         //{[[self buttontext] setEnabled:true];}
     }
    
    if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 0)){
        checkJBRemoverMarker = TRUE;
        if (shouldRestoreFS()){
            [_restoreFSSwitch setOn:true];
            [_jailbreak setTitle:localize(@"Restore FS") forState:UIControlStateNormal];
            goto end;
        }else{
            [_restoreFSSwitch setOn:false];
            [_jailbreak setTitle:localize(@"Journey 2 gRoot?") forState:UIControlStateNormal];
            [_jailbreak setEnabled:YES];
            goto end;
        }

    }
    if ((checkuncovermarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
        if (shouldRestoreFS()){
            [_restoreFSSwitch setOn:true];
             [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
             checkJBRemoverMarker = TRUE;
             goto end;
         }else{
            [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
            [_restoreFSSwitch setOn:false];
            //[self shareTh0rSet];
            checkJBRemoverMarker = TRUE;
             goto end;
         }
    }
    if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
        if (shouldRestoreFS()){
            [_restoreFSSwitch setOn:true];
             checkJBRemoverMarker = TRUE;
            [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
             goto end;
         }else{
            [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
            [_restoreFSSwitch setOn:false];
            //[self shareTh0rSet];
            checkJBRemoverMarker = TRUE;
             goto end;
         }
        
    }
    if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 1) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
        if (shouldRestoreFS()){
            [_restoreFSSwitch setOn:true];
             checkJBRemoverMarker = TRUE;
            [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
             goto end;
         }else{
            [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
            [_restoreFSSwitch setOn:false];
            //[self shareTh0rSet];
            checkJBRemoverMarker = TRUE;
             goto end;
         }
        
    }
    if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
        if (shouldRestoreFS()){
            [_restoreFSSwitch setOn:true];
             checkJBRemoverMarker = TRUE;
            [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
             goto end;
         }else{
            [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
            [_restoreFSSwitch setOn:false];
            //[self shareTh0r];
            checkJBRemoverMarker = TRUE;
             goto end;
         }
    }else {
        if (shouldRestoreFS()){
            [_restoreFSSwitch setOn:true];
            [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
             checkJBRemoverMarker = TRUE;
             goto end;
         }else{
            [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
            [_restoreFSSwitch setOn:false];
           // [self shareTh0rSet];
            checkJBRemoverMarker = TRUE;
             goto end;
         }
    }
    end:
    if (shouldRestoreFS())
    {
        //[_jailbreak setTitle:localize(@"ok Restore The FS?") forState:UIControlStateNormal];

        restoreyofs();
        [_restoreFSSwitch setOn:true];
    } else {
        justJByo();
        //[_jailbreak setTitle:localize(@"gRoot?") forState:UIControlStateNormal];

        [_restoreFSSwitch setOn:false];
    }
    
    
}

- (IBAction)CreditsDue:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Credits" message:@"Not much to credit here, since the code is directly copied from unc0ver! The small amount of code that actually is different IDK who made, so I can't credit a ghost. Thanks to whomever wrote the new jailbreakd & figured out the patches. Credits to you any users (@DzMoha_31) whom want to & do use this... If you feel like you weren't credited here - GO CRY ELSEWHERE\n sploits/bootstraps/patch code modified & updated @pwned4ever____" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *THANKS = [UIAlertAction actionWithTitle:@"Thanks to whomever wrote the new jailbreakd" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:THANKS];
    [alertController setPreferredAction:THANKS];
    [self presentViewController:alertController animated:false completion:nil];
    
}





#define pwned4ever_URL "https://www.dropbox.com/s/9hv9rcdqs88u9tf/Th0r.ipa"
#define pwned4ever_TEAM_TWITTER_HANDLE "pwned4ever____"
- (void)shareTh0rSet {
    struct utsname u = { 0 };
    uname(&u);
    //[self.jailbreak setEnabled:NO];
    //[self.jailbreak setHidden:YES];
    [NSString stringWithUTF8String:u.machine];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Wanna Share Th0r Jailbreak", nil) message:NSLocalizedString(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 Jailbreak?", nil) preferredStyle:UIAlertControllerStyleAlert];UIAlertAction *OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ya of course", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.jailbreak setEnabled:NO];//download it @ %@
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:localize(@"I'm using Th0r 3.0  - Jailbreak for all iOS 12.0 - 12.4, Updated 2/31/20 3:40PM-EDT. A totally incomplete tool that just won't get released 😂 By:@%@ 🍻, to jailbreak my %@ iOS %@" ),@pwned4ever_TEAM_TWITTER_HANDLE , [NSString stringWithUTF8String:u.machine],[[UIDevice currentDevice] systemVersion], @pwned4ever_URL]] applicationActivities:nil];
                activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
                if ([activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
                    activityViewController.popoverPresentationController.sourceView = self->_jailbreak;
                }
                [self presentViewController:activityViewController animated:YES completion:nil];
                [self.jailbreak setEnabled:NO];
                [self.jailbreak setHidden:YES];
            });
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

- (void)viewDidAppear:(BOOL)animated{
    
//    CAGradientLayer *gradient2 = [CAGradientLayer layer];
//
//    gradient2.frame = self.settingsGradientView.bounds;
//    gradient2.colors = @[(id)[[UIColor colorWithRed:0.49 green:0.43 blue:0.84 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.36 green:0.64 blue:0.80 alpha:1.0] CGColor]];
//
//    [UIView animateWithDuration:1.0f animations:^{
//
//        [self.settingsGradientView setAlpha:1.0];
//        [self.settingsGradientView.layer insertSublayer:gradient2 atIndex:0];
//
//    }];
    
    
    }

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setGradient];
}

-(void)setGradient {
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    
    /*gradient2.frame = self.settingsGradientView.bounds;
    gradient2.colors = @[(id)[[UIColor colorWithRed:0.49 green:0.43 blue:0.84 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.36 green:0.64 blue:0.80 alpha:1.0] CGColor]];
    
    [UIView animateWithDuration:1.0f animations:^{
        
        [self.settingsGradientView setAlpha:1.0];
        [self.settingsGradientView.layer insertSublayer:gradient2 atIndex:0];
        
    }];
    */
}



///////////////////////----UI STUFF----////////////////////////////
- (IBAction)MS1_ACTION:(UIButton *)sender {
    
    saveCustomSetting(@"ExploitType", 0);
    
    //color var
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    UIColor *red = [UIColor colorWithRed:1.00 green:0.3 blue:0.2 alpha:1.0];
    UIColor *green = [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:1.0];;
    UIColor *yellow = [UIColor colorWithRed:0.80 green:0.80 blue:0.00 alpha:1.0];;
    
    //button color
    self.VS_Outlet.backgroundColor = red;
    self.MS1_OUTLET.backgroundColor = white;
    self.MS2_Outlet.backgroundColor = purple;
    self.SP_Outlet.backgroundColor = red;
    
    //button label color
    [self.VS_Outlet setTitleColor:green forState:UIControlStateNormal];
    [self.MS1_OUTLET setTitleColor:black forState:UIControlStateNormal];
    [self.MS2_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.SP_Outlet setTitleColor:red forState:UIControlStateNormal];

    
}

- (IBAction)MS2_ACTION:(UIButton *)sender {
    
    saveCustomSetting(@"ExploitType", 1);
    
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    self.VS_Outlet.backgroundColor = purple;
    self.MS1_OUTLET.backgroundColor = purple;
    self.MS2_Outlet.backgroundColor = white;
    self.SP_Outlet.backgroundColor = purple;

    
    //button label color
    [self.VS_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.MS1_OUTLET setTitleColor:white forState:UIControlStateNormal];
    [self.MS2_Outlet setTitleColor:black forState:UIControlStateNormal];
    [self.SP_Outlet setTitleColor:white forState:UIControlStateNormal];

}

- (IBAction)VS_ACTION:(UIButton *)sender {
    
    saveCustomSetting(@"ExploitType", 2);
    
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    UIColor *red = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
    UIColor *green = [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:1.0];;
    UIColor *yellow = [UIColor colorWithRed:0.80 green:0.80 blue:0.00 alpha:1.0];;
    UIColor *blue = [UIColor colorWithRed:0 green:0 blue:0.4 alpha:1.0];

    
    self.VS_Outlet.backgroundColor = green;
    self.MS1_OUTLET.backgroundColor = purple;
    self.MS2_Outlet.backgroundColor = purple;
    self.SP_Outlet.backgroundColor = blue;

    
    //button label color
    [self.VS_Outlet setTitleColor:black forState:UIControlStateNormal];
    [self.MS1_OUTLET setTitleColor:white forState:UIControlStateNormal];
    [self.MS2_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.SP_Outlet setTitleColor:yellow forState:UIControlStateNormal];

    
}

- (IBAction)Cydia_Button:(UIButton *)sender {
    
    saveCustomSetting(@"PackagerType", 0);
    
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    
    self.Cydia_Outlet.backgroundColor = white;
    self.Zebra_Outlet.backgroundColor = purple;
    self.Sileo_Outlet.backgroundColor = purple;
    
    //button label color
    [self.Cydia_Outlet setTitleColor:black forState:UIControlStateNormal];
    [self.Zebra_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.Sileo_Outlet setTitleColor:white forState:UIControlStateNormal];
    
}

- (IBAction)Zebra_Button:(UIButton *)sender {
    
    saveCustomSetting(@"PackagerType", 1);
    
    //color var
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    //button color
    self.Cydia_Outlet.backgroundColor = purple;
    self.Zebra_Outlet.backgroundColor = white;
    self.Sileo_Outlet.backgroundColor = purple;
    
    //button label color
    [self.Cydia_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.Zebra_Outlet setTitleColor:black forState:UIControlStateNormal];
    [self.Sileo_Outlet setTitleColor:white forState:UIControlStateNormal];
}

- (IBAction)Sileo_Button:(UIButton *)sender {
    
    saveCustomSetting(@"PackagerType", 2);
    
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    self.Cydia_Outlet.backgroundColor = purple;
    self.Zebra_Outlet.backgroundColor = purple;
    self.Sileo_Outlet.backgroundColor = white;
    
    //button label color
    [self.Cydia_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.Zebra_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.Sileo_Outlet setTitleColor:black forState:UIControlStateNormal];
}

- (IBAction)SP_Action:(UIButton *)sender {
    
    saveCustomSetting(@"ExploitType", 3);
    
    UIColor *purple = [UIColor colorWithRed:0.43 green:0.53 blue:0.82 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    UIColor *red = [UIColor colorWithRed:1.00 green:0.3 blue:0.2 alpha:1.0];
    UIColor *green = [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:1.0];;
    UIColor *yellow = [UIColor colorWithRed:0.80 green:0.80 blue:0.00 alpha:1.0];;
    UIColor *blue = [UIColor colorWithRed:0 green:0 blue:0.4 alpha:1.0];

    
    self.VS_Outlet.backgroundColor = blue;
    self.MS1_OUTLET.backgroundColor = purple;
    self.MS2_Outlet.backgroundColor = purple;
    self.SP_Outlet.backgroundColor = green;
    
    
    //button label color
    [self.VS_Outlet setTitleColor:yellow forState:UIControlStateNormal];
    [self.MS1_OUTLET setTitleColor:white forState:UIControlStateNormal];
    [self.MS2_Outlet setTitleColor:white forState:UIControlStateNormal];
    [self.SP_Outlet setTitleColor:black forState:UIControlStateNormal];
    
}
- (IBAction)Restore_FS_Switch_Action:(UISwitch *)sender {
    
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


    
    if ([sender isOn])
    {
        saveCustomSetting(@"RestoreFS", 0);
        if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){

            if (shouldRestoreFS())
             {
                 [_restoreFSSwitch setOn:true];
                 [_jailbreak setTitle:localize(@"Restore -already strapped") forState:UIControlStateNormal];
                 goto out;
             }else {
                 [_jailbreak setTitle:localize(@"Enable gRoot?") forState:UIControlStateNormal];
                 [_restoreFSSwitch setOn:false];
                 goto out;
             }
        }
         if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)) {
             {[[self buttontext] setEnabled:true];}
            
             if (shouldRestoreFS())
              {
                  [_restoreFSSwitch setOn:true];
                  [_jailbreak setTitle:localize(@"Restore strapped") forState:UIControlStateNormal];
                  goto out;

              }else {
                  [_restoreFSSwitch setOn:false];
                  [_jailbreak setTitle:localize(@"Enable gRoot?") forState:UIControlStateNormal];
                  goto out;
              }
             
             {[[self buttontext] setEnabled:true];}
         }
        
        if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 0)){
            checkJBRemoverMarker = TRUE;
            {[[self buttontext] setEnabled:true];}

            
            if (shouldRestoreFS())
            {
                [_restoreFSSwitch setOn:true];
                [_jailbreak setTitle:localize(@"Restore DAROOT FS") forState:UIControlStateNormal];
                goto out;

            }else{
            
                [_restoreFSSwitch setOn:false];
                [_jailbreak setTitle:localize(@"Journey 2 gRoot?") forState:UIControlStateNormal];
                [_jailbreak setEnabled:YES];
                goto out;
            }

        }
        if ((checkuncovermarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                 [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 checkJBRemoverMarker = TRUE;
                 goto out;
             }else{
                [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                //[self shareTh0rSet];
                checkJBRemoverMarker = TRUE;
                 goto out;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                 checkJBRemoverMarker = TRUE;
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 goto out;
             }else{
                [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                //[self shareTh0rSet];
                checkJBRemoverMarker = TRUE;
                 goto out;
             }
            
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                 checkJBRemoverMarker = TRUE;
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 goto out;
             }else{
                justJByo();
                [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                //[self shareTh0r];
                checkJBRemoverMarker = TRUE;
                 goto out;
             }
        }else {
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 checkJBRemoverMarker = TRUE;
                 goto out;
             }else{
                [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                //[self shareTh0rSet];
                checkJBRemoverMarker = TRUE;
                 goto out;
             }
        }
    out:
        //[_jailbreak setTitle:localize(@"FS about to get fucked?") forState:UIControlStateNormal];
        //restoreyofs();
        if (shouldRestoreFS())
        {
            //[_jailbreak setTitle:localize(@"ok Restore The FS?") forState:UIControlStateNormal];

            restoreyofs();
            [_restoreFSSwitch setOn:true];
        } else {
            justJByo();
            //[_jailbreak setTitle:localize(@"gRoot?") forState:UIControlStateNormal];

            [_restoreFSSwitch setOn:false];
        }
        saveCustomSetting(@"RestoreFS", 0);
        

        
    } else {
        saveCustomSetting(@"RestoreFS", 1);

        if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)){

            if (shouldRestoreFS())
             {
                 [_restoreFSSwitch setOn:true];
                 [_jailbreak setTitle:localize(@"Restore -already strapped") forState:UIControlStateNormal];
                 goto end;

             }else {
                 [_jailbreak setTitle:localize(@"Enable gRoot?") forState:UIControlStateNormal];
                 goto end;
             }
        }
         if ((checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkuncovermarker == 0) && (checkelectramarker == 0) && (checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0)) {
             {[[self buttontext] setEnabled:true];}
            
             if (shouldRestoreFS())
              {
                  [_restoreFSSwitch setOn:true];
                  [_jailbreak setTitle:localize(@"Restore strapped") forState:UIControlStateNormal];
                  goto end;

              }else {
                  [_jailbreak setTitle:localize(@"Enable gRoot?") forState:UIControlStateNormal];
                  goto end;
              }             
         }
        
        if(((checkjailbreakdRun == 0 || checkjailbreakdRuntmp ==0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 0)) && (checkelectramarker == 0) && (checkJBRemoverMarker == 0)){
            checkJBRemoverMarker = TRUE;
            {[[self buttontext] setEnabled:true];}

            
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                [_jailbreak setTitle:localize(@"Restore DAROOT FS") forState:UIControlStateNormal];
                goto end;
            }else{
                restoreyofs();
                [_jailbreak setTitle:localize(@"Journey 2 gRoot?") forState:UIControlStateNormal];
                [_jailbreak setEnabled:YES];
                goto end;
            }

        }
        if ((checkuncovermarker == 0) && (checkpspawnhook == 1) && (checkth0rmarker == 1 || checkziyouthormarker ==1) && (checkjailbreakdRun == 1 || checkjailbreakdRuntmp ==1)){
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                restoreyofs();
                 [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 checkJBRemoverMarker = TRUE;
                 goto end;
             }else{
                [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                //[self shareTh0rSet];
                 //justJByo();
                checkJBRemoverMarker = TRUE;
                 goto end;
             }
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 1) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                 checkJBRemoverMarker = TRUE;
                restoreyofs();

                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 goto end;
             }else{
                [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                justJByo();
                checkJBRemoverMarker = TRUE;
                 goto end;
             }
            
        }
        if ((checkjailbreakdRun == 0 || checkjailbreakdRuntmp == 0) && (checkSubstratedhook == 0) && (checkSlidehook == 0) && (checkpspawnhook == 0) && (checkth0rmarker == 0 || checkziyouthormarker ==0) && (checkuncovermarker == 1 )){
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                 checkJBRemoverMarker = TRUE;
                restoreyofs();
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 goto end;
             }else{
                [_jailbreak setTitle:localize(@"Remove unc0ver JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                justJByo();
                checkJBRemoverMarker = TRUE;
                 goto end;
             }
        }else {
            if (shouldRestoreFS()){
                [_restoreFSSwitch setOn:true];
                [_jailbreak setTitle:localize(@"Restore FS Yolo?") forState:UIControlStateNormal];
                 checkJBRemoverMarker = TRUE;
                 goto end;
             }else{
                [_jailbreak setTitle:localize(@"𝓢Ⓗ⒜𝕽ᴱ Th0r 👍🏽 JB?") forState:UIControlStateNormal];
                [_restoreFSSwitch setOn:false];
                //[self shareTh0rSet];
                //justJByo();
                checkJBRemoverMarker = TRUE;
                 goto end;
             }
        }
        
        //justJByo();
        //[_jailbreak setTitle:localize(@"FS saved from horror?") forState:UIControlStateNormal];
    end:
        if (shouldRestoreFS())
        {
            //[_jailbreak setTitle:localize(@"ok Restore The FS?") forState:UIControlStateNormal];

            restoreyofs();
            [_restoreFSSwitch setOn:true];
        } else {
            justJByo();
            //[_jailbreak setTitle:localize(@"gRoot?") forState:UIControlStateNormal];

            [_restoreFSSwitch setOn:false];
        }
        saveCustomSetting(@"RestoreFS", 1);
    }
    
}

- (IBAction)loadTweaksPushed:(id)sender {
    if ([sender isOn])
    {
        saveCustomSetting(@"LoadTweaks", 0);
    } else {
        saveCustomSetting(@"LoadTweaks", 1);
    }
    
}

- (IBAction)dismissBut:(UIButton *)sender {
[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)swipeymyarsey:(UISwipeGestureRecognizer *)sender {
        [self dismissViewControllerAnimated:YES completion:nil];

}


- (IBAction)dismissSwipe:(UISwipeGestureRecognizer *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)dismissButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)rooted_Switch:(UIButton *)sender {
    
    //0 = root
    //1 = rootless
    saveCustomSetting(@"RootSetting", 0);
    
    UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    self.rooted_Switch.backgroundColor = white;
    self.rootless_Switch.backgroundColor = purple;
    
    //button label color
    [self.rootless_Switch setTitleColor:white forState:UIControlStateNormal];
    [self.rooted_Switch setTitleColor:black forState:UIControlStateNormal];
    
}

- (IBAction)rootless_Switch:(UIButton *)sender {
    
    saveCustomSetting(@"RootSetting", 1);
    UIColor *purple = [UIColor colorWithRed:0.48 green:0.44 blue:0.83 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *black = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];;
    
    self.rooted_Switch.backgroundColor = purple;
    self.rootless_Switch.backgroundColor = white;
    
    //button label color
    [self.rootless_Switch setTitleColor:black forState:UIControlStateNormal];
    [self.rooted_Switch setTitleColor:white forState:UIControlStateNormal];
    
    
}
@end

