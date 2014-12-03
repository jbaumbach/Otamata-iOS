//
//  WelcomePg1ViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/22/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomePageViewController.h"
#import "RoundedCornerView.h"

@interface WelcomePg1ViewController : WelcomePageViewController
    <SoundIconViewProtocol>
{
    CGRect _targetLocationOfAnimatedLabel;
}


@property (retain, nonatomic) IBOutlet RoundedCornerView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *tabLabel;

@property (retain, nonatomic) IBOutlet SoundIconView *sampleSound;

@property (retain, nonatomic) IBOutlet UILabel *afterPlayMessage;

-(CGRect) recordOriginalLocationAndMoveOffscreen:(UIView *)targetView;
-(void) animateBackOnscreen:(UIView *)targetView;

@end
