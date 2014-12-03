//
//  RateSoundViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sound.h"
#import "RateView.h"
#import "SendingDialogView.h"

@interface RateSoundViewController : UIViewController
    <RateViewDelegate,
    SendDialogViewComplete>
{
}
@property (retain, nonatomic) IBOutlet RateView *ratingView;
@property (retain, nonatomic) IBOutlet UITextView *reviewTextView;

@property (nonatomic, retain) Sound *theSound;

-(void) barButtonItemPressed:(UIBarButtonItem *)button;

@end
