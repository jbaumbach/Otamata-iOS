//
//  RateSoundViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RateSoundViewController.h"

#import "RateSoundOperation.h"
#import "GlobalFunctions.h"
#import "SoundManager.h"

@implementation RateSoundViewController

@synthesize ratingView;
@synthesize reviewTextView;
@synthesize theSound;

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
    
    ratingView.notSelectedImage = [UIImage imageNamed:NOTSELECTEDIMAGE];
    ratingView.halfSelectedImage = [UIImage imageNamed:HALFSELECTEDIMAGE];
    ratingView.fullSelectedImage = [UIImage imageNamed:FULLSELECTEDIMAGE];
    ratingView.rating = 0;  //currentSound.averageRating;
    ratingView.editable = YES;
    ratingView.maxRating = 5;
    ratingView.delegate = self;

    self.title = @"Rate Sound";
    
    UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = sendButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    reviewTextView.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    
}

- (void)viewDidUnload
{
    [self setRatingView:nil];
    [self setReviewTextView:nil];
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
    [ratingView release];
    [reviewTextView release];
    [super dealloc];
}

#pragma mark - Instance Methods

-(void) barButtonItemPressed:(UIBarButtonItem *)button
{
    //
    // Send user rating to server
    //
    [reviewTextView resignFirstResponder];
    RateSoundOperation *view = [[RateSoundOperation alloc] initWithFrame:self.view.frame];
    [self.view addSubview:view];
    view.delegate = self;
    [view rateSound:theSound withRating:[[NSNumber numberWithFloat:ratingView.rating] intValue] userText:[reviewTextView text]];
    
}

#pragma mark - RateView Protocol

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating;
{
    DLog(@"Rating did change, to %f", rating);
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

#pragma mark - SendDialogViewComplete

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status
{
    if (status == sdvSuccess)
    {
        [SoundManager userHasRatedSound:theSound];
    }
    else
    {
        //
        // Show dialog box saying there was an error?
        //
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
