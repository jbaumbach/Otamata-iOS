//
//  WelcomePg2ViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/22/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WelcomePg2ViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "SoundManager.h"
#import "SoundPlayer.h"
#import "PlayerViewController.h"

@implementation WelcomePg2ViewController
@synthesize currentSoundIcon;
@synthesize contentView;
@synthesize tapHoldLabel;
@synthesize lastLabelEm;
@synthesize successMsgView;

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
    
    tapHoldLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    lastLabelEm.textColor = [UIColor colorWithHexString:SPINNER_COLOR];

    //[self setHiddenAfterLongPressedText:YES];
    
    _targetLocationOfAnimatedLabel = [self recordOriginalLocationAndMoveOffscreen:successMsgView];

    NSString *welcomeSoundFileName = [NSString stringWithFormat:@"%@.%@", WELCOME_SOUND_PG2_FILE, [Sound otamataSerializedFileExtension]];
    
    Sound *welcomeSound = [SoundManager getLocalSoundFromFilename:welcomeSoundFileName];
    
    currentSoundIcon.theSound = welcomeSound;
    currentSoundIcon.delegate = self;

}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setTapHoldLabel:nil];
    [self setCurrentSoundIcon:nil];
    [self setLastLabelEm:nil];
    [self setSuccessMsgView:nil];
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
    [tapHoldLabel release];
    [currentSoundIcon release];
    [lastLabelEm release];
    [successMsgView release];
    [super dealloc];
}

#pragma mark - Instance methods

-(CGRect) recordOriginalLocationAndMoveOffscreen:(UIView *)targetView 
{
    CGRect result = targetView.frame;
    
    int bottomOfView = self.view.frame.size.height;
    
    CGRect offscreenLocation = CGRectMake(result.origin.x, bottomOfView, result.size.width, result.size.height);
    targetView.frame = offscreenLocation;
    
    return result;
}

-(void) animateBackOnscreen:(UIView *)targetView
{
    [UIView beginAnimations:@"LabelSlide" context:nil];
    targetView.frame = _targetLocationOfAnimatedLabel;
    [UIView commitAnimations];
    
}

#pragma - User Actions

- (void) longPressedForSound:(Sound *)sound
{

    UIActionSheet *soundActionSheet = [[UIActionSheet alloc] initWithTitle:@"** These are only training actions!  Press any button to continue. **" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" otherButtonTitles:sacRateSound, sacInappropriate, sacSendToFriend, nil];
    
    [soundActionSheet showInView:self.view.superview];
    [soundActionSheet release];
}

#pragma mark - Action Sheet protocol

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"clicked action button: %d", buttonIndex);
    [self animateBackOnscreen:successMsgView];

}

@end
