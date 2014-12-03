//
//  SendToFriendController.h
//  Otamata
//
//  Created by John Baumbach on 3/25/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "ShareSoundConfig.h"

@protocol SmsToFriendDelegate <NSObject>

-(void) sendCompleteWithResult:(MessageComposeResult)result;

@end

@interface SmsToFriendController : NSObject
    <MFMessageComposeViewControllerDelegate,
    UIAlertViewDelegate>


@property (nonatomic, retain) UIViewController *parent;
@property (nonatomic, retain) id<SmsToFriendDelegate> delegate;

-(id) initWithParent:(UIViewController *)theParent;

-(void) sendToFriend:(ShareSoundConfig *)theSound;



@end
