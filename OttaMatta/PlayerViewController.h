//
//  OttaFirstViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/AdBannerView.h>
#import "GADBannerView.h"

#import "Sound.h"
#import "IconViewContainer.h"
#import "SoundIconView.h"
#import "SendingDialogView.h"
#import "SmsToFriendController.h"
#import "UploadSoundViewController.h"

//
// Sound Action Sheet button titles
//
#define sacRateSound        @"Rate Sound"
#define sacInappropriate    @"Mark as Inappropriate"
#define sacSetAsDeployment  @"Save as Deployment!"
#define sacChangeIcon       @"Change Icon"
#define sacSendToFriend     @"Share Sound"
#define sacTurnAdsOff       @"Toggle ads"

//
// Alert Box Types
//
#define abtDeleteSoundBox       1
//#define abtMarkInappropriateBox 2

//
// SendingDialogView keys
// 
#define sdkUpload   @"upload"

@interface PlayerViewController : UIViewController
    <IconViewContainerProtocal,
    SoundIconViewProtocol,
    UIActionSheetDelegate,
    UIAlertViewDelegate,
    SendDialogViewComplete,
    UploadSoundDelegate,
    ADBannerViewDelegate>
{
    Sound *_currentSound;
    float _originalVolume;
}


//
// UI Elements
//
@property (retain, nonatomic) IBOutlet IconViewContainer *soundIconContainer;

//
// Instance properties
//
@property (nonatomic, retain) NSMutableArray* soundList;
@property (nonatomic, retain) id helperController;
@property (nonatomic, retain) SmsToFriendController *senderToFriend;
//@property (nonatomic, retain) ADBannerView *adView;
@property (nonatomic, retain) GADBannerView *gadView;

//
// Instance methods
//
-(void) loadSounds;
-(void) shareSound;
-(void) sendCompleteWithStatus:(int)status;
-(void) showShareSoundViewController;
-(void) addOrRemoveBannerAd:(BOOL)add;
-(void) gotNotificationToRemoveAds:(NSNotification *)notification;

@end
