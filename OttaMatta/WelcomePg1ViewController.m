//
//  WelcomePg1ViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/22/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WelcomePg1ViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "SoundManager.h"
#import "SoundPlayer.h"

@implementation WelcomePg1ViewController
@synthesize sampleSound;
@synthesize afterPlayMessage;
@synthesize contentView;
@synthesize tabLabel;

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
    
    tabLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    /*
    tapHoldLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    marketLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    optionsLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
     */
    
    NSString *welcomeSoundFileName = [NSString stringWithFormat:@"%@.%@", WELCOME_SOUND_PG1_FILE, [Sound otamataSerializedFileExtension]];
    //[sampleSound setTheSound:[SoundManager getLocalSoundFromFilename:welcomeSoundFileName]];
    
    Sound *welcomeSound = [SoundManager getLocalSoundFromFilename:welcomeSoundFileName];
    
    _targetLocationOfAnimatedLabel = [self recordOriginalLocationAndMoveOffscreen:afterPlayMessage];
    
    [afterPlayMessage setText:@""];
    
    sampleSound.theSound = welcomeSound;
    sampleSound.delegate = self;
    
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setTabLabel:nil];
    [self setSampleSound:nil];
    [self setAfterPlayMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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

- (void) pressedForSound:(Sound *)sound
{
    [SoundPlayer playSoundFromData:sound.soundData];
    
    [afterPlayMessage setText:@"Very good!  If the volume is too low, set it higher on the \"Options\" screen."];
    
    [self animateBackOnscreen:afterPlayMessage];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [contentView release];
    [tabLabel release];
    [sampleSound release];
    [afterPlayMessage release];
    [super dealloc];
}
@end
