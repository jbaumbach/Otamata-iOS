//
//  RecorderViewController.m
//  Otamata
//
//  Created by John Baumbach on 5/19/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "RecorderViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "OttaAppDelegate.h"

@implementation RecorderViewController
@synthesize soundNameTextField;
@synthesize soundDescriptionTextField;
@synthesize soundMeter;
@synthesize secondsLabel;
@synthesize instructionsLabel;
@synthesize btnRecord;
@synthesize btnStop;
@synthesize btnPlay;
@synthesize btnReset;
@synthesize recorder;
@synthesize player;
@synthesize contentView;
@synthesize mainScrollView;
@synthesize userSound;
@synthesize soundIcon;
@synthesize btnSaveSound;
@synthesize recordingStartTime;
@synthesize imageSelection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Record", @"Record");
        self.tabBarItem.title = @"Record";
        self.tabBarItem.image = [UIImage imageNamed:@"record"];

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
    DLog(@"RecordingViewController - viewDidLoad");
    
    instructionsLabel.text = [NSString stringWithFormat:@"You can record up to %d seconds of audio.", MAX_RECORDING_LENGTH_SECS];
    
    if ([soundMeter respondsToSelector:@selector(trackTintColor)])
    {
        soundMeter.trackTintColor = [UIColor colorWithHexString:NAVBAR_TINT];
        soundMeter.progressTintColor = [UIColor colorWithHexString:SPINNER_COLOR];
    }

    [mainScrollView addSubview:contentView];
    [mainScrollView setContentSize:contentView.bounds.size];
    mainScrollView.delegate = self;

    soundDescriptionTextField.delegate = self;
    [soundDescriptionTextField setBackgroundColor:[UIColor colorWithHexString:VERY_LIGHT_GREEN]];

    soundNameTextField.delegate = self;
    [soundNameTextField setBackgroundColor:[UIColor colorWithHexString:VERY_LIGHT_GREEN]];

    [self registerForKeyboardNotifications];
    [self resetAll];
    [self setupRecording];
    soundIcon.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    
}
- (void)viewDidUnload
{
    [self setSoundMeter:nil];
    [self setSecondsLabel:nil];
    [self setBtnRecord:nil];
    [self setBtnStop:nil];
    [self setBtnPlay:nil];
    [self setInstructionsLabel:nil];
    [self setMainScrollView:nil];
    [self setContentView:nil];
    [self setSoundNameTextField:nil];
    [self setSoundDescriptionTextField:nil];
    self.userSound = nil;
    self.imageSelection = nil;
    
    [self setSoundIcon:nil];
    [self setBtnSaveSound:nil];
    [self setBtnReset:nil];
    
    //
    // Just in case - reset app to playback mode so soundplayer works
    // 
    [self setAppToPlaybackMode];
    
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
    
    self.recorder = nil;
    self.recordingStartTime = nil;
    
    [soundMeter release];
    [secondsLabel release];
    [btnRecord release];
    [btnStop release];
    [btnPlay release];
    [instructionsLabel release];
    [mainScrollView release];
    [contentView release];
    [soundNameTextField release];
    [soundDescriptionTextField release];
    [soundIcon release];
    [btnSaveSound release];
    [btnReset release];

    [super dealloc];
}

#pragma mark - User Actions

- (IBAction)recordClicked:(id)sender {
    DLog(@"Start recording");
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    [recorder record];
    self.recordingStartTime = [[[NSDate alloc] init] autorelease];
    
    //
    // Set up a background thread for the metering to keep the main UI responsive
    //
    [NSThread detachNewThreadSelector:@selector(updateMetering) toTarget:self withObject:nil];  
    
    [self setButtonStates];
}

- (IBAction)stopClicked:(id)sender {
    DLog(@"Stop clicked");
    
    [self stopRecording];
}

- (IBAction)playClicked:(id)sender {	
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    DLog(@"Start playing");
    
    [SoundPlayer playSoundFromData:[NSData dataWithContentsOfFile:[self tempSoundDataFName]]];
}

- (IBAction)chooseIconClicked:(id)sender {
    
    OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.imageSelection = [[[ImageSelector alloc] 
                                     initWithTabBarController:[delegate tabBarController] 
                                     navBarTint:[UIColor colorWithHexString:NAVBAR_TINT] 
                                     andParentViewController:self andDelegate:self] autorelease];
    [imageSelection showUI];

}

- (IBAction)resetClicked:(id)sender {
    [self resetAll];
}

- (IBAction)saveSoundClicked:(id)sender {
    DLog(@"Save sound - can we do it?");
    
    NSString *messageIfFail;
    
    if (![self validateFormFields:&messageIfFail])
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops, can't save!" message:messageIfFail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
    }
    else
    {
        //
        // Save that bad boy
        //
        //NSMutableArray *allCurrentSounds = [SoundManager getLocalSounds];
        //int nextAvailUserId = [SoundManager nextUserSoundIntIdFromSounds:allCurrentSounds];
        
        //userSound.soundId = [Sound convertedUserSoundIdForId:[NSString stringWithFormat:@"%d", nextAvailUserId]];
        
        //userSound.name = soundNameTextField.text;
        //userSound.soundDescription = soundDescriptionTextField.text;
        
        
        NSError *err;
        NSData *soundData = [NSData dataWithContentsOfFile:[self tempSoundDataFName] options: 0 error:&err];
        
        if (!soundData)
        {
            DLog(@"audio data error: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops, can't save!" message:err.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
        }
        else
        {
            //userSound.size =  userSound.soundData.length;
            //userSound.imageData = [soundIcon.theSound getIconData];
            //userSound.hasIcon = [soundIcon.theSound hasIconData];
            //userSound.status = sscActive;
         
            //[SoundManager serializeSound:userSound];

            [SoundManager saveNewUserSound:userSound name:soundNameTextField.text description:soundDescriptionTextField.text data:soundData icon:[soundIcon.theSound getIconData] origination:socNotSet filename:[SoundManager dummyFilename:sfWav]];
             

            //
            // Reset everything for next time
            //
            [self resetAll];
            
            //
            // Switch to player tab after saving.  The users's icon will be there.
            //
            OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate tabBarController].selectedIndex = 0;
            [self.mainScrollView setContentOffset:CGPointZero animated:NO];
        }
    }
}

#pragma mark - Helper Functions

//
// Determine if the sound can be saved or not.  Assumes there's a valid recording.
//
// todo: make a class to generic-ize this.
//
-(BOOL) validateFormFields:(NSString **)messageIfFail
{
    *messageIfFail = @"";
    
    if ([soundNameTextField.text length] < MIN_SOUNDNAME_LENGTH)
    {
        *messageIfFail = [NSString stringWithFormat:@"Please enter a sound name of at least 5 characters."];
    }
    //
    // These max values should match the max lengths in the stored proc [sp_Sound_Insert]
    //
    else if ([soundNameTextField.text length] > MAX_SOUNDNAME_LENGTH)
    {
        *messageIfFail = [NSString stringWithFormat:@"Please enter a sound name less than or equal to 25 characters."];
    }
    else if ([soundDescriptionTextField.text length] < MIN_SOUNDDESC_LENGTH)
    {
        *messageIfFail = [NSString stringWithFormat:@"Please enter a sound description of at least 5 characters."];
    }
    else if ([soundDescriptionTextField.text length] > MAX_SOUNDDESC_LENGTH)
    {
        *messageIfFail = [NSString stringWithFormat:@"Please enter a sound description less than or equal to 140 characters."];
    }
    
    return [*messageIfFail length] == 0;
    
}

-(void) hideKeyboard
{
    [soundNameTextField resignFirstResponder];
    [soundDescriptionTextField resignFirstResponder];
}

-(void) stopRecording
{
    DLog(@"Stop recording");
    
    [recorder stop];
    NSError *err;
    NSData *audioData = [NSData dataWithContentsOfFile:[self tempSoundDataFName] options: 0 error:&err];
    if(!audioData)
        DLog(@"audio data error: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    DLog(@"Done - total sound length in bytes: %d", audioData.length);
    
    _haveSoundToPlay = YES;
    
    [self setButtonStates];
    [self setAppToPlaybackMode];
}


-(int) putInBounds:(int)value min:(int)min max:(int)max
{
    int result = value;
    
    result = MIN(result, max);
    result = MAX(result, min);
    
    return result;
}

-(void) updateProgressBar:(NSNumber *)value
{
    soundMeter.progress = [value floatValue];
}

//
// Note: this loop is started on a background thread to allow the main UI to 
// remain responsive.  It will perform selectors
// on the main thread to update various UI controls.
//
-(void) updateMetering
{
    //
    // Not 100% sure how this pool works, but if you don't declare it here
    // you get a boatload of mem leaks as the loop runs.
    //
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    
    /*
     The current peak power, in decibels, for the sound being recorded. A return value of 0 dB indicates full scale, or maximum power; a return value of -160 dB indicates minimum power (that is, near silence).
     
     If the signal provided to the audio recorder exceeds ±full scale, then the return value may exceed 0 (that is, it may enter the positive range).
     
     */
    
    while (recorder.isRecording)
    {
        int curentRecordingSecs = recorder.currentTime;
        
        if (curentRecordingSecs < MAX_RECORDING_LENGTH_SECS) {
            
            [recorder updateMeters];
            
            //
            // Average power value responds better than max power
            //
            float averagePower = [recorder averagePowerForChannel:0];
            
            //
            // Decrease the divisor to increase the responsiveness
            //
            int translatedValueAve = (averagePower / 6 + 11);
            
            translatedValueAve = [self putInBounds:translatedValueAve min:0 max:10];
            
            [self performSelectorOnMainThread:@selector(updateProgressBar:) withObject:[NSNumber numberWithFloat: ((float) translatedValueAve) / 10.0] waitUntilDone:NO];
            

            NSTimeInterval recordingLength = ABS([recordingStartTime timeIntervalSinceNow]);
            
            [self performSelectorOnMainThread:@selector(setUISeconds:) withObject:[NSNumber numberWithDouble:recordingLength] waitUntilDone:NO];
        
            //
            // We don't need to go crazy with the looping here, sleep a bit
            //
            [NSThread sleepForTimeInterval:0.07f];
        }
        else
        {
            DLog(@"Time limit reached: %d seconds", MAX_RECORDING_LENGTH_SECS);
            
            [self stopRecording];
            [self setUISeconds:[NSNumber numberWithDouble:MAX_RECORDING_LENGTH_SECS]];
            [self updateProgressBar:0];
        }
        
    }

    DLog(@"Not recording!");
    [self updateProgressBar:0];
    
    [pool release];
}


-(NSString *) tempSoundDataFName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    
    return [NSString stringWithFormat:@"%@/userlocalsound.wav", documentsDirectory];
}

-(void) setUISeconds:(NSNumber *)seconds
{
    if (seconds == 0)
    {
        secondsLabel.text = @"Ready";
    }
    else
    {
        secondsLabel.text = [NSString stringWithFormat:@"Recording length: 0:%05.2f", [seconds doubleValue]];
    }
}

-(void) setButtonStates
{
    DLog(@"Setting button states");
    
    btnRecord.enabled = !recorder.isRecording;
    btnStop.enabled = recorder.isRecording;
    btnPlay.enabled = (_haveSoundToPlay && !recorder.isRecording);
    
    //
    // Enable the save button at this time.  We still may not be able to save, but we'll get
    // a msg explaining why at least.  I think that's a better UX than a mysteriously
    // disabled button.
    //
    btnSaveSound.enabled = (_haveSoundToPlay && !recorder.isRecording);

}

//
// Record the sound.  Note, iOS can't record MP3s because of patent stuff.  So,
// we gotta record a WAV.  TBD: should we allow longer sounds, and compress them
// on the server?
//
-(void) setupRecording 
{
    NSString *soundFilePath = [self tempSoundDataFName];
    
    DLog(@"setupRecording: Local Sound File : %@", soundFilePath);
    
    NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc] init] autorelease];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    
    // 
    // Typical values: 
    // http://en.wikipedia.org/wiki/Sampling_rate#Audio
    //
    // 11025.0  // Pretty good
    // 16000.0  // Really good
    //
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey]; 
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    //
    // Setting this to "8" shrinks the file, but massive background static-type noise
    //
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    NSError *err = nil;
    
    DLog(@"setupRecording: About to set AVAudioSession active...");

    [[AVAudioSession sharedInstance] setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }

    err = nil;
    NSURL *soundFilePathUrl = [NSURL fileURLWithPath:soundFilePath];
    
    DLog(@"setupRecording: About to init the AVAudioRecorder...");

    self.recorder = [[[AVAudioRecorder alloc]
                initWithURL:soundFilePathUrl
                settings:recordSetting
                error:&err] autorelease];
    
    if (err)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: @"Warning"
                                                        message: [err localizedDescription]
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] autorelease];
        [alert show];
        NSLog(@"error: %@", [err localizedDescription]);
        
    } else {
        [recorder setDelegate:self];
        
        DLog(@"setupRecording: About to prepareToRecord...");
        

        [recorder prepareToRecord];
        
        BOOL audioHWAvailable = [[AVAudioSession sharedInstance]inputIsAvailable ];
        if (!audioHWAvailable) {
            UIAlertView *cantRecordAlert =
            [[[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: @"Audio input hardware not available"
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil] autorelease];
            [cantRecordAlert show]; 
            return;
        }
        
        recorder.meteringEnabled = YES;
        _haveSoundToPlay = NO;
        [recorder updateMeters];

    }

    DLog(@"setupRecording: Setup complete - ready to record");
    
}

-(void) resetAll
{
    [self updateProgressBar:0];
    [self setUISeconds:0];
    
    /* refactored 7/16/2012 JB
    self.userSound = [[[Sound alloc] init] autorelease];
    _haveSoundToPlay = NO;
    
    //
    // Set the "1" built-in sound as the default icon
    //
    self.userSound.iconSrcType = istAppDefault;
    self.userSound.iconAppDefaultId = 1;
    soundIcon.theSound = self.userSound;
    */
    
    self.userSound = [SoundManager getEmptySound];
    _haveSoundToPlay = NO;
    soundIcon.theSound = self.userSound;
    
    soundNameTextField.text = @"";
    soundDescriptionTextField.text = @"";
    
    [self setButtonStates];

}

//
// If the shared instance is left in record mode, then no playback can happen.
//
-(void) setAppToPlaybackMode
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}


#pragma mark - Stuff to help text boxes avoid keyboards

//
// This is actual code from Apple with some mods I found on StackOverflow.
//
// How to set this up:
//
// 1. Make sure you inherit from UITextFieldDelegate.
// 2. Call "registerForKeyboardNotifications" in viewDidLoad.
// 3. Set all the text fields to have self as the delgate.
// 4. Add "UIControl *_activeField;" as an instance variable.
//

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}



// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    mainScrollView.contentInset = contentInsets;
    mainScrollView.scrollIndicatorInsets = contentInsets;
    
    //
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    //
    // This part has some mods from Stack Overflow
    //
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = _activeField.frame.origin;
    origin.y -= mainScrollView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y-(aRect.size.height)); 
        [mainScrollView setContentOffset:scrollPoint animated:YES];
    }
    
}



// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    mainScrollView.contentInset = contentInsets;
    mainScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

#pragma mark - Text Field Delegate

//
// Happens when keyboard "Return" key is clicked
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"Text field should return?");
    
    if (textField == soundNameTextField)
    {
        [soundNameTextField resignFirstResponder];
        [soundDescriptionTextField becomeFirstResponder];
    }
    else if (textField == soundDescriptionTextField)
    {
        [soundDescriptionTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - ImageSelectorProtocol implementation

-(void) imageSelectionCompleteWithJPEGData:(NSData *)result
{
    // DLog(@"Got an image selection result: %@", result);
    
    if (result != nil)
    {
        [soundIcon setIconWithData:result];
    }
}


#pragma mark - SoundIconViewProtocol

-(void) pressedForSound:(Sound *)sound
{
    [self chooseIconClicked:nil];
}

@end
