//
//  WelcomePg3ViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/24/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WelcomePg3ViewController.h"
#import "GlobalFunctions.h"

@implementation WelcomePg3ViewController
@synthesize contentView;

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
    
    [self setupPageWithView:contentView];

}

- (void)viewDidUnload
{
    [self setContentView:nil];
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
    [contentView release];
    [super dealloc];
}
- (IBAction)closeClicked:(id)sender {
    DLog(@"Close clicked!!");
    
    [self.dismissableController dismissModalViewControllerAnimated:YES];
    
    // [self dismissModalViewControllerAnimated:YES];
    
}
@end
