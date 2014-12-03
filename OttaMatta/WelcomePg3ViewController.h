//
//  WelcomePg3ViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/24/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomePageViewController.h"

@interface WelcomePg3ViewController : WelcomePageViewController
@property (retain, nonatomic) IBOutlet RoundedCornerView *contentView;

- (IBAction)closeClicked:(id)sender;

@end
