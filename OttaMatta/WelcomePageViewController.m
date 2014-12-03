//
//  WelcomePageViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/23/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WelcomePageViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "Sound.h"
#import "SoundPlayer.h"

@implementation WelcomePageViewController

@synthesize dismissableController;

-(void) setupPageWithView:(RoundedCornerView *)contentView
{
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    contentView.color = [UIColor whiteColor];
    contentView.backgroundColor = [UIColor clearColor];
    
    //
    // The height of the white container view.  We wanna make sure they all match.
    //
    float viewHeight = 409.0;  // height
    CGRect viewFrame = contentView.frame;
    viewFrame.size.height = viewHeight;
    contentView.frame = viewFrame;
    
    [contentView setCornerRadius:13.0f];
    
    

}

- (void) longPressedForSound:(Sound *)sound
{
}


- (void)dealloc {
    [super dealloc];
    self.dismissableController = nil;
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
