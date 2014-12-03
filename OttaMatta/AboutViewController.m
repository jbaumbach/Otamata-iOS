//
//  AboutViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "Config.h"
#import "SendEmailController.h"

@implementation AboutViewController
@synthesize lblVer;
@synthesize emailButton;
@synthesize mainScrollView;
@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"About";
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
    [mainScrollView addSubview:contentView];
    [mainScrollView setContentSize:contentView.bounds.size];
    
    //Don't call: emailButton.titleLabel.text = [NSString stringWithFormat:@"Email: %@", EMAIL_GENERAL];  The text display area doesn't expand.
    
    [self.emailButton setTitle:EMAIL_GENERAL forState:UIControlStateNormal];
    [self.emailButton setTitle:EMAIL_GENERAL forState:UIControlStateSelected];

    lblVer.text = [NSString stringWithFormat:@"%@ (%@)", [GlobalFunctions appPublicVersion], [GlobalFunctions appBuild]];

}

- (void)viewDidUnload
{
    [self setMainScrollView:nil];
    [self setContentView:nil];
    [self setEmailButton:nil];
    [self setLblVer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mainScrollView release];
    [contentView release];
    [emailButton release];
    [lblVer release];
    [super dealloc];
}


- (IBAction)emailButtonClicked:(id)sender {
    SendEmailController *emailer = [[SendEmailController alloc] initWithParent:self];
    [emailer sendContactUsEmail];
    //
    // Note: do NOT release or autorelease the emailer object here or you'll get a zombie.
    //
    // todo: make the emailer a member variable and release it when unloading the view.
    //
    // OK to ignore "Analyze" warnings about potential mem leaks here.
    //
}

- (IBAction)websiteButtonClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Config websiteHomepageUrl]]];
}

@end
