//
//  WelcomePageViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/23/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedCornerView.h"
#import "SoundIconView.h"

@interface WelcomePageViewController : UIViewController

-(void) setupPageWithView:(RoundedCornerView *)contentView;

@property (nonatomic, retain) UIViewController *dismissableController;

@end
