//
//  UploadSoundViewController.h
//  Otamata
//
//  Created by John Baumbach on 6/3/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sound.h"
#import "SoundInfoControl.h"
#import "Config.h"


#define PRIVACY_PUBLIC_DESC     @"This sound can be downloaded by the Otamata community."
#define PRIVACY_PRIVATE_DESC    @"This sound can only be played by people with the link."

@protocol UploadSoundDelegate <NSObject>

-(void) userAction:(ModalResult)action withUserName:(NSString *)userName andSharingPreference:(BOOL)allUsers;

@end

@interface UploadSoundViewController : UIViewController
    <UITextFieldDelegate>

//
// Instance properties
//
@property (nonatomic, retain) Sound *sound;
@property (nonatomic, retain) SoundInfoControl *soundInfoControl;
@property (nonatomic, retain) id<UploadSoundDelegate> delegate;
@property BOOL enableAllUsersDefaultIsOn;

//
// UI Elements
//
@property (retain, nonatomic) IBOutlet UIView *soundInfoHolder;
@property (retain, nonatomic) IBOutlet UINavigationBar *actualNavBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navItemTitle;
@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (retain, nonatomic) IBOutlet UISwitch *enableAllUsers;
@property (retain, nonatomic) IBOutlet UILabel *lblPrivacyNotice;
@property (retain, nonatomic) IBOutlet UILabel *lblTermsLink;

//
// User actions
//
- (IBAction)cancelClicked:(id)sender;
- (IBAction)uploadClicked:(id)sender;
- (IBAction)privacySwitchToggled:(id)sender;
-(void) buttonClicked:(ModalResult)action;
-(void) lblTermsLinkClicked:(UIGestureRecognizer *)gestureRecognizer;

//
// Instance methods
//
-(void) setPrivacyMessage;
-(void) setButtonStates;


@end
