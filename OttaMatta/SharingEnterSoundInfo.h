//
//  SharingEnterSoundInfo.h
//  Otamata
//
//  Created by John Baumbach on 5/6/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@protocol SharingEnterSoundInfoDelegate <NSObject>

-(void) userAction:(ModalResult)action withTitle:(NSString *)title andText:(NSString *)text;


@end

@interface SharingEnterSoundInfo : UIViewController
    <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *linkTitle;
@property (retain, nonatomic) IBOutlet UITextView *postText;
@property (retain, nonatomic) IBOutlet UINavigationItem *dialogTitle;
- (IBAction)cancelClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *sendButton;
- (IBAction)sendClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UINavigationBar *mainNavBar;

@property (retain, nonatomic) id<SharingEnterSoundInfoDelegate> delegate;

-(void) facebookIdInvalidatedEvenThoughWereInTheMiddleOfShowingThisDialog:(NSNotification *)notification;

@end
