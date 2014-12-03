//
//  ShareSoundHelperController.h
//  Otamata
//
//  Created by John Baumbach on 5/2/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmsToFriendController.h"
#import "ShareSoundConfig.h"
#import "SendEmailController.h"
#import "FBConnect.h"
#import "OtamataSingleton.h"
#import "SharingEnterSoundInfo.h"

//
// This helper controller knows how to send the sound contained in ShareSoundConfig
// by all the different methods and showing the display type.
//

@protocol ShareSoundProtocol <NSObject>

-(void) shareCompleteWithResult:(int)result;

@end

@interface ShareSoundHelperController : NSObject
    <SmsToFriendDelegate,
    SendEmailProtocol,
    FBSessionDelegate,
    FBRequestDelegate,
    SharingEnterSoundInfoDelegate>
{
    BOOL _isShowingProgressSpinner;
}

@property (nonatomic, retain) id<ShareSoundProtocol> delegate;
@property (nonatomic, retain) SmsToFriendController *smsToFriendController;
@property (nonatomic, retain) ShareSoundConfig *shareConfig;
@property (nonatomic, retain) SendEmailController *emailer;
@property (nonatomic, retain) Facebook *facebook;

//
// This must be set to the parent UIViewController when calling the SMS function.
// This way the SMS screen (modal) can be dismissed properly.
//
@property (nonatomic, retain) UIViewController *parentController;

-(NSString *) urlForCurrentSound;
-(void) shareCompleteWithResult:(int)result;
-(void) returnedFromFacebookAuth:(NSNotification *)notification;

-(void) showProgressSpinner;
-(void) dismissProgressSpinner;

-(void) doShare;

-(void) shareViaSMS;
-(void) shareViaEmail;
-(void) shareViaTwitter;
-(void) shareViaFacebook;
-(void) shareViaSafari;

-(void) postToFacebookWithUI;
-(void) invalidateFacebookAuthorization;


@end
