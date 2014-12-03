//
//  WelcomeViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RoundedCornerView.h"

@interface WelcomeViewController : UIViewController
- (IBAction)closeButtonClicked:(id)sender;

@property (retain, nonatomic) IBOutlet RoundedCornerView *contentView;

@property (retain, nonatomic) IBOutlet UILabel *tablLabel;
@property (retain, nonatomic) IBOutlet UILabel *tapHoldLabel;
@property (retain, nonatomic) IBOutlet UILabel *marketLabel;
@property (retain, nonatomic) IBOutlet UILabel *optionsLabel;
@end
