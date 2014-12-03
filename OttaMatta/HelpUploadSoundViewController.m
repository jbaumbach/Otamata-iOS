//
//  UploadSoundViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpUploadSoundViewController.h"

#import "GlobalFunctions.h"
#import "Config.h"

@implementation HelpUploadSoundViewController
@synthesize contentView;
@synthesize contentScrollView;
@synthesize websiteLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Upload";
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
    [contentScrollView addSubview:contentView];
    [contentScrollView setContentSize:contentView.bounds.size];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weblinkPressed:)];
    [websiteLink addGestureRecognizer:tapGesture];
    [tapGesture release];
    websiteLink.textColor = [UIColor colorWithHexString:SPINNER_COLOR];

}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setContentScrollView:nil];
    [self setWebsiteLink:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) weblinkPressed:(UIGestureRecognizer *)gestureRecognizer
{
    NSURL *url = [[[NSURL alloc] initWithString:websiteLink.text] autorelease];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)dealloc {
    [contentView release];
    [contentScrollView release];
    [websiteLink release];
    [super dealloc];
}
@end
