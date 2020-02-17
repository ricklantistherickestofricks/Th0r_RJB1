//
//  ViewController.h
//  Ziyou
//
//  Created by Tanay Findley on 5/7/19.
//  Copyright © 2019 Ziyou Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include "utils/utils.h"

@interface ViewController : UIViewController <AVAudioPlayerDelegate>
{    SystemSoundID PlaySoundID1;
    AVAudioPlayer *audioPlayer1;
    
}
@property (readonly) ViewController *sharedController;
+ (ViewController*)sharedController;
- (void)rmounting;
- (void)labelchange;
//- (void)shareTh0rRemover;
- (void)shareTh0r;

@property (strong, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UILabel *failbeaklblout;
@property (strong, nonatomic) IBOutlet UILabel *sliceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *paintBrush;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *justsettingsBARbackground;
@property (weak, nonatomic) IBOutlet UIImageView *settings_buttun_bg;
@property (weak, nonatomic) IBOutlet UIButton *jailbreak;
@property (weak, nonatomic) IBOutlet UIButton *Th0rsharebtn;
@property (weak, nonatomic) IBOutlet UIButton *buttontext;
@property (weak, nonatomic) IBOutlet UIImageView *jailbreakButtonBackground;
@property (weak, nonatomic) IBOutlet UIView *credits_view;
@property (strong, nonatomic) IBOutlet UISwitch *restoreFSSwitch;
@property (weak, nonatomic) IBOutlet UITextField *myUITextView;
@property (weak, nonatomic) IBOutlet UILabel *labeloutput1;
@property (strong, nonatomic) IBOutlet UISwitch *loadTweakSwitch;
@property (weak, nonatomic) IBOutlet UIScrollView *logscroller;
- (void)cydiainstalled;
- (void)letsloopalpha;

- (void)littlewienners;
- (void)respringattempt;
- (void)uicaching;
- (void)serverS;
- (void)remounting;
- (void)settinghsp4;
- (void)Packmandone;
- (void)restoreyofs;
- (void)th0rlabelyo;
- (void)loadingtweaks;
- (void)cleaningshit;
- (void)installingdebsboys;
- (void)extractingbootstrap;
- (void)justJByo;

/* untar 'a' to current directory.  path is name of archive (informational) */
//void untar(FILE *a, const char *path);
@end

static inline void showAlertWithCancel(NSString *title, NSString *message, Boolean wait, Boolean destructive, NSString *cancel) {
    dispatch_semaphore_t semaphore;
    if (wait)
    semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *controller = [ViewController sharedController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"Okay" style:destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (wait)
            dispatch_semaphore_signal(semaphore);
        }];
        [alertController addAction:OK];
        [alertController setPreferredAction:OK];
        if (cancel) {
            UIAlertAction *abort = [UIAlertAction actionWithTitle:cancel style:destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (wait)
                dispatch_semaphore_signal(semaphore);
            }];
            [alertController addAction:abort];
            [alertController setPreferredAction:abort];
        }
        [controller presentViewController:alertController animated:YES completion:nil];
    });
    if (wait)
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

static inline void showAlertPopup(NSString *title, NSString *message, Boolean wait, Boolean destructive, NSString *cancel) {
    dispatch_semaphore_t semaphore;
    if (wait)
    semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *controller = [ViewController sharedController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller presentViewController:alertController animated:YES completion:nil];
    });
    if (wait)
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}



static inline void showAlert(NSString *title, NSString *message, Boolean wait, Boolean destructive) {
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    ViewController *controller = [ViewController sharedController];
    //    [controller dismissViewControllerAnimated:false completion:nil];
    //});
    
    showAlertWithCancel(title, message, wait, destructive, nil);
}



static inline void showThePopup(NSString *title, NSString *message, Boolean wait, Boolean destructive) {
    //dispatch_async(dispatch_get_main_queue(), ^{
     //   ViewController *controller = [ViewController sharedController];
    //    [controller dismissViewControllerAnimated:false completion:nil];
   // });
    
    showAlertPopup(title, message, wait, destructive, nil);
}

static inline void disableRootFS() {
    ViewController *controller = [ViewController sharedController];
    [[controller restoreFSSwitch] setOn:false];
    saveCustomSetting(@"RestoreFS", 1);
}


