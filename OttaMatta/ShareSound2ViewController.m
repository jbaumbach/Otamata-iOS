//
//  ShareSound2ViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/29/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "ShareSound2ViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShareSound2ViewController
@synthesize mainScrollView;
@synthesize mainContent;
@synthesize optionPlainView;
@synthesize optionPlainImage;
@synthesize optionPlainWithLinkView;
@synthesize optionPlainWithLinkImage;
@synthesize optionDetailsView;
@synthesize optionDetailsGraphic;
@synthesize shareConfig;
@synthesize helperController;

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
    
    self.title = @"Style";
    
    self.mainContent.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    self.mainScrollView.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];

    //
    // Todo: refactor this hideous (but yes, working) code into something more elegant
    //
    
    [self.mainScrollView addSubview:self.mainContent];
    self.mainScrollView.contentSize = self.mainContent.bounds.size;
    
    //The setup code (in viewDidLoad in your view controller)

    optionPlainView.backgroundColor = [UIColor clearColor];
    [optionPlainView setCornerRadius:13.0f];
    
    UITapGestureRecognizer *plainSingleFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [optionPlainView addGestureRecognizer:plainSingleFingerTap];

    
    optionPlainWithLinkView.backgroundColor = [UIColor clearColor];
    [optionPlainWithLinkView setCornerRadius:13.0f];

    UITapGestureRecognizer *withLinkSingleFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [optionPlainWithLinkView addGestureRecognizer:withLinkSingleFingerTap];
    
    
    optionDetailsView.backgroundColor = [UIColor clearColor];
    [optionDetailsView setCornerRadius:13.0f];
    
    UITapGestureRecognizer *withDetailsSingleFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [optionDetailsView addGestureRecognizer:withDetailsSingleFingerTap];
    
    [self resetBackgrounds];
    
    if (NO)
    {
        [optionPlainImage.layer setBorderColor: [[UIColor colorWithHexString:SPINNER_COLOR] CGColor]];
        [optionPlainImage.layer setBorderWidth: 2.0];
        
        [optionPlainWithLinkImage.layer setBorderColor: [[UIColor colorWithHexString:SPINNER_COLOR] CGColor]];
        [optionPlainWithLinkImage.layer setBorderWidth: 2.0];
        
        [optionDetailsGraphic.layer setBorderColor: [[UIColor colorWithHexString:SPINNER_COLOR] CGColor]];
        [optionDetailsGraphic.layer setBorderWidth: 2.0];
    }
    
    //
    // We expect a ShareSound object to be set by the calling function - don't init one.
    // 
    
}

-(void) resetBackgrounds
{
    optionPlainView.color = [UIColor whiteColor];
    optionPlainWithLinkView.color = [UIColor whiteColor];
    optionDetailsView.color = [UIColor whiteColor];
}

-(void) resetBackgroundsWithDelay:(float)delay
{
    [GlobalFunctions sleepAndProcessMessages:delay];
    [self resetBackgrounds];
}

- (void)viewDidUnload
{
    [self setMainScrollView:nil];
    [self setOptionPlainView:nil];
    [self setOptionPlainWithLinkView:nil];
    [self setOptionDetailsView:nil];
    [self setOptionPlainImage:nil];
    [self setOptionPlainWithLinkImage:nil];
    [self setOptionDetailsGraphic:nil];
    [self setMainContent:nil];
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
    [optionPlainView release];
    [optionPlainWithLinkView release];
    [optionDetailsView release];
    [optionPlainImage release];
    [optionPlainWithLinkImage release];
    [optionDetailsGraphic release];
    [mainContent release];
    self.shareConfig = nil;
    self.helperController = nil;
    [super dealloc];
}


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {

    //
    // Visually indicate that the user clicked the option
    //
    RoundedCornerView *selectedView = (RoundedCornerView *) recognizer.view;
    selectedView.color = [UIColor colorWithHexString:SPINNER_COLOR];

    //
    // Not sure if this will work
    //
    [GlobalFunctions doEventsAndSleep:0.1];
    
    SoundShareType type;
    
    if ([selectedView isEqual:optionPlainView])
    {
        type = sstNameThatSound;
    }
    else if ([selectedView isEqual:optionPlainWithLinkView])
    {
        type = sstNameSoundWithAnswer;
    }
    else
    {
        type = sstFullSoundDetails;
    }
    
    shareConfig.CurrentType = type;

    DLog(@"About to share sound: %@", shareConfig.currentSound);
    
    //
    // Set up our helper controller, which does all the heavy lifting
    //
    self.helperController = [[[ShareSoundHelperController alloc] init] autorelease];
    helperController.shareConfig = self.shareConfig;
    helperController.parentController = self;
    helperController.delegate = self;
    [helperController doShare];

    //
    // Clear the visual selection indicator after a brief delay
    //
    [self resetBackgroundsWithDelay:0.2];

}

#pragma mark - ShareSoundDelegate implementation

-(void) shareCompleteWithResult:(int)result
{
    DLog(@"Got a response from the controller: %d", result);
    
    [self resetBackgrounds];
    
    //
    // Clear both of the share screens (we know we're on controller 2 of 2 now)
    //
    NSArray *allViewControllers = self.navigationController.viewControllers;
    NSInteger n = [allViewControllers count];
    [self.navigationController popToViewController:[allViewControllers objectAtIndex:(n-3)] animated:NO];
    
}
@end
