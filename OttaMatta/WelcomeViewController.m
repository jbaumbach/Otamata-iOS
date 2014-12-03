//
//  WelcomeViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WelcomeViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"

@implementation WelcomeViewController
@synthesize contentView;
@synthesize tablLabel;
@synthesize tapHoldLabel;
@synthesize marketLabel;
@synthesize optionsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    contentView.color = [UIColor whiteColor];
    contentView.backgroundColor = [UIColor clearColor];
    [contentView setCornerRadius:13.0f];
    
    tablLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    tapHoldLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    marketLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    optionsLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setTablLabel:nil];
    [self setTapHoldLabel:nil];
    [self setMarketLabel:nil];
    [self setOptionsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)dealloc {
    [contentView release];
    [tablLabel release];
    [tapHoldLabel release];
    [marketLabel release];
    [optionsLabel release];
    [super dealloc];
}
@end
