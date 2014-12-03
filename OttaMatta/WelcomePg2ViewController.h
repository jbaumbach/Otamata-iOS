//
//  WelcomePg2ViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/22/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomePageViewController.h"

@interface WelcomePg2ViewController : WelcomePageViewController
    <SoundIconViewProtocol,
    UIActionSheetDelegate>
{
    CGRect _targetLocationOfAnimatedLabel;
}

@property (retain, nonatomic) IBOutlet SoundIconView *currentSoundIcon;
@property (retain, nonatomic) IBOutlet RoundedCornerView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *tapHoldLabel;
@property (retain, nonatomic) IBOutlet UILabel *lastLabelEm;
@property (retain, nonatomic) IBOutlet UIView *successMsgView;

-(CGRect) recordOriginalLocationAndMoveOffscreen:(UIView *)targetView;
-(void) animateBackOnscreen:(UIView *)targetView;

@end
