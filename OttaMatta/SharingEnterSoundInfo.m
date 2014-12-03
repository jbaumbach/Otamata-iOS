//
//  SharingEnterSoundInfo.m
//  Otamata
//
//  Created by John Baumbach on 5/6/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SharingEnterSoundInfo.h"
#import "GlobalFunctions.h"
#import "Config.h"

@implementation SharingEnterSoundInfo
@synthesize sendButton;
@synthesize dialogTitle;
@synthesize linkTitle;
@synthesize postText;
@synthesize mainNavBar;
@synthesize delegate;

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
    
    [dialogTitle setTitle:@"Facebook"];
    [sendButton setTitle:@"Post"];
    [mainNavBar setTintColor:[UIColor colorWithHexString:NAVBAR_TINT]];
    
    [linkTitle setText:@"Sound Clip"];
    [linkTitle setBackgroundColor:[UIColor colorWithHexString:TABLEVIEW_BG_COLOR]];
    linkTitle.clipsToBounds = YES;
    linkTitle.layer.cornerRadius = 6.0f;
    
    //
    // The UITextView only supports a background color when the borderstyle is non-rounded.
    // Yes, that's weird.  But more wierd is that the padding goes away too when you go 
    // non-rounded.  So, the text is smashed up against the left side.  This adds a dummy
    // view into the text box to simulate padding.  Sigh.
    //
    UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)] autorelease];
    linkTitle.leftView = paddingView;
    linkTitle.leftViewMode = UITextFieldViewModeAlways;


    
    [postText setText:@"Check out this sound."];
    [postText setBackgroundColor:[UIColor colorWithHexString:TABLEVIEW_BG_COLOR]];
    postText.clipsToBounds = YES;
    postText.layer.cornerRadius = 6.0f;

    //
    // Sometimes we're notified a bit late that FB isn't valid anymore.  We should quit at this point.
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookIdInvalidatedEvenThoughWereInTheMiddleOfShowingThisDialog:) name:gmiFacebookIdInvalidated object:nil];
}

- (void)viewDidUnload
{
    [self setLinkTitle:nil];
    [self setPostText:nil];
    [self setDialogTitle:nil];
    [self setSendButton:nil];
    [self setMainNavBar:nil];
    self.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    [linkTitle release];
    [postText release];
    [dialogTitle release];
    [sendButton release];
    [mainNavBar release];
    
    [super dealloc];
}

-(void) buttonClicked:(ModalResult)action
{
    if ([delegate respondsToSelector:@selector(userAction:withTitle:andText:)])
    {
        [delegate userAction:action withTitle:[linkTitle text] andText:[postText text]];
    }
    else
    {
        DLog(@"Well, no delegate defined, I guess we'll just keep hanging out here forever.");
    }
}

-(void) facebookIdInvalidatedEvenThoughWereInTheMiddleOfShowingThisDialog:(NSNotification *)notification
{
    DLog(@"Yup, FB invalid now.  Show an alert here and let's get outta here.");
    
    UIAlertView *popup = [[[UIAlertView alloc] initWithTitle:@"Facebook Authorization" message:@"It looks like the Otamata access token has exipred.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [popup show];
}

- (IBAction)cancelClicked:(id)sender {
    DLog(@"cancelClicked");
    
    [self buttonClicked:mrCancel];
}

- (IBAction)sendClicked:(id)sender {
    DLog(@"sendClicked");
    
    [self buttonClicked:mrOK];
}

#pragma mark - UIActionSheet delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Let's simulate a cancel click");
    
    [self buttonClicked:mrCancel];
}
@end
