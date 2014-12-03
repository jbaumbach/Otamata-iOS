//
//  TermsAndConditionsViewController.m
//  Otamata
//
//  Created by John Baumbach on 6/21/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "TermsAndConditionsViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"

@implementation TermsAndConditionsViewController
@synthesize mainWebView;
@synthesize navItemTitle;
@synthesize actualNavBar;

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
    
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[Config websiteTermsAndConditionsUrl]]]];
    
    [navItemTitle setTitle:@"Terms & Conditions"];
    [actualNavBar setTintColor:[UIColor colorWithHexString:NAVBAR_TINT]];

}

- (void)viewDidUnload
{
    [self setMainWebView:nil];
    [self setNavItemTitle:nil];
    [self setActualNavBar:nil];
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
    [mainWebView release];
    [navItemTitle release];
    [actualNavBar release];
    [super dealloc];
}
- (IBAction)doneClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
