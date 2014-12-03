//
//  WebsoundDetailViewController.m
//  Otamata
//
//  Created by John Baumbach on 7/8/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WebsoundDetailViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "SoundDetailViewController.h"
#import "QSStrings.h"
#import "JSONKit.h"
#import "SoundPlayer.h"
#import "OttaAppDelegate.h"
#import "SoundManager.h"
#import "PurchaseViewController.h"

@implementation WebsoundDetailViewController
@synthesize mainScrollView;
@synthesize contentView;
@synthesize soundNameLabel;
@synthesize fileSizeLabel;
@synthesize downloadingLabel;
@synthesize downloadProgress;
@synthesize playButton;
@synthesize sourceWebsiteLabel;
@synthesize soundNameTextField;
@synthesize soundDescriptionTextField;
@synthesize soundIcon;
@synthesize creditsAvailLabel;
@synthesize webSound;
@synthesize localSound;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize searchTerm;
@synthesize imageSelection;
@synthesize player;

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
    
    if ([downloadProgress respondsToSelector:@selector(trackTintColor)])
    {
        downloadProgress.trackTintColor = [UIColor colorWithHexString:NAVBAR_TINT];
        downloadProgress.progressTintColor = [UIColor colorWithHexString:SPINNER_COLOR];
    }
    
    [mainScrollView addSubview:contentView];
    [mainScrollView setContentSize:contentView.bounds.size];
    
    self.title = @"Save Sound";
    
    //
    // todo: implement all of these things
    //
    
    // mainScrollView.delegate = self;
    
    soundDescriptionTextField.delegate = self;
    [soundDescriptionTextField setBackgroundColor:[UIColor colorWithHexString:VERY_LIGHT_GREEN]];

    soundNameTextField.delegate = self;
    [soundNameTextField setBackgroundColor:[UIColor colorWithHexString:VERY_LIGHT_GREEN]];
    
    
    // [self registerForKeyboardNotifications];

    soundIcon.delegate = self;

    _playButtonText = [[NSString stringWithString:playButton.titleLabel.text] retain];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceUrlLinkClicked:)];
    // Note: the UILable must have user interaction enabled, either in code or IB.
    [sourceWebsiteLabel addGestureRecognizer:tapGesture];
    [tapGesture release];

    [sourceWebsiteLabel setTextColor:[UIColor colorWithHexString:SPINNER_COLOR]];
    
    [soundNameLabel setTextColor:[UIColor colorWithHexString:NAVBAR_TINT]];
    
    _playedSound = NO;
    _playedSoundSuccessfully = NO;
    
    [self setScreenFieldsFromSound];
    [self registerForKeyboardNotifications];
    [self startSoundDownload];

}

- (void)viewDidDisappear:(BOOL)animated
{
    DLog(@"Disappearing...");
    [player stopSound];
}

- (void)viewDidUnload
{
    DLog(@"Unloading...");
    
    [self setMainScrollView:nil];
    [self setSoundNameLabel:nil];
    [self setFileSizeLabel:nil];
    [self setDownloadingLabel:nil];
    [self setPlayButton:nil];
    [self setSourceWebsiteLabel:nil];
    [self setSoundNameTextField:nil];
    [self setSoundDescriptionTextField:nil];
    [self setSoundIcon:nil];
    [self setCreditsAvailLabel:nil];
    
    self.webSound = nil;
    self.localSound = nil;
    self.activeDownload = nil;
    self.imageConnection = nil;
    self.searchTerm = nil;
    self.imageSelection = nil;
    
    [self setDownloadProgress:nil];
    
    [_playButtonText release];
    
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
    [mainScrollView release];
    [soundNameLabel release];
    [fileSizeLabel release];
    [downloadingLabel release];
    [playButton release];
    [sourceWebsiteLabel release];
    [soundNameTextField release];
    [soundDescriptionTextField release];
    [soundIcon release];
    [creditsAvailLabel release];
    [downloadProgress release];
    [contentView release];
    
    //
    // Moving this here to perhaps solve odd crashing problem when audio
    // is playing and the user exits the screen
    //
    self.player = nil;

    [super dealloc];
}

#pragma mark - User Actions

- (IBAction)playClicked:(id)sender {
    if (webSound.soundData != nil)
    {
        if (!player.isPlaying)
        {
            _playedSound = YES;
            
            self.player = [[[SoundPlayer alloc] initWithDataAndPlay:webSound.soundData] autorelease];
            BOOL res = self.player.playedSuccessfully;
            
            if (!res)
            {
                [downloadingLabel setHidden:NO];
                [downloadingLabel setText:@"Sorry, the device can't play this sound."];
            }
            else
            {
                _playedSoundSuccessfully = YES;
            }
        }
        else
        {
            [self.player stopSound];
        }
    }
    else
    {
    }

}

- (IBAction)chooseIconClicked:(id)sender {
    
    OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.imageSelection = [[[ImageSelector alloc] 
                                     initWithTabBarController:[delegate tabBarController] 
                                     navBarTint:[UIColor colorWithHexString:NAVBAR_TINT] 
                                     andParentViewController:self andDelegate:self] autorelease];
    imageSelection.searchTerm = searchTerm;
    [imageSelection showUI];
    
}

- (IBAction)saveClicked:(id)sender {
    DLog(@"Save sound - can we do it?");
    
    NSString *messageIfFail;
    
    if (![self validateFormFields:&messageIfFail])
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops, can't save!" message:messageIfFail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
    }
    else if (![soundIcon.theSound hasIconData])
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No icon?" message:@"Are you sure you wish to save the sound without choosing an icon?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
        alert.tag = wsdvcSaveWithoutIcon;
        [alert show];
    }
    else
    {
        [self saveSoundAndExit];
    }
    
}

- (IBAction)getCreditsButton:(id)sender {
}

-(void) sourceUrlLinkClicked:(UIGestureRecognizer *)gestureRecognizer
{
    DLog(@"Want to go to url: %@", webSound.sourceUrl);
    
    NSURL *url = [[[NSURL alloc] initWithString:webSound.sourceUrl] autorelease];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Instance Methods

-(void) saveSoundAndExit
{
    //
    // Save that bad boy
    //
    [SoundManager saveNewUserSound:localSound name:soundNameTextField.text description:soundDescriptionTextField.text data:webSound.soundData icon:[soundIcon.theSound getIconData] origination:socWebDownload filename:webSound.fileName];
    
    //
    // Switch to player tab after saving.  The users's icon will be there.
    //
    OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate tabBarController].selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) startSoundDownload
{
    //
    // At this point, the server sound COULD be one of the user's sounds.  They are independent
    // entities.  However, we don't want to try to make them the same object on the disk
    // since the server object should be updatable by # of downloads, ratings, etc.
    //
    // The downside to this approach is that the device d/ls the icon and sound data again
    // from the server.
    //
    
    if (![webSound hasSoundData])
    {
        [downloadProgress setProgress:0.0f];
        [downloadProgress setHidden:NO];
        
        //
        // This code is direct from the Apple docs.  It starts the d/l.  The callbacks
        // grab the data.
        //
        NSString *url = [Config websoundDetailUrlForTerm:webSound.term andId:webSound.soundId];
        DLog(@"Getting data with url: %@", url);
        
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
        self.imageConnection = conn;
        [conn release];
        
        [playButton setTitle:btlTextLoading forState:UIControlStateNormal];
        [playButton setTitle:btlTextLoading forState:UIControlStateSelected];
        [downloadingLabel setText:@"Downloading..."];
    }
}

-(void) soundDownloadComplete:(BOOL)success
{
    [downloadProgress setHidden:YES];
    
    /* Optional with some layouts:
    //
    // Resize the status label to take advantage of more real estate
    //
    CGRect currentFrame = downloadingLabel.frame;
    
    downloadingLabel.frame = CGRectMake(currentFrame.origin.x, 
                                        currentFrame.origin.y, 
                                        280, 
                                        currentFrame.size.height);  
     */
    
    
    if (success)
    {
        //[SoundManager serializeSound:sound];
        [playButton setHidden:NO];
        [playButton setTitle:_playButtonText forState:UIControlStateNormal];
        [playButton setTitle:_playButtonText forState:UIControlStateSelected];
    }
    else
    {
        [playButton setHidden:YES];
        [downloadingLabel setText:@"Oops, unable to download!"];
    }
    
    [self setDownloadStatusLabel];
}

-(void) setScreenFieldsFromSound
{
    [soundNameLabel setText:webSound.fileName];
    
    NSString* commaString = [GlobalFunctions formatWithCommas:webSound.size];
    [fileSizeLabel setText:[NSString stringWithFormat:@"%@ bytes", commaString]];

    
    [self updateCreditsAvailableLabel];
    [sourceWebsiteLabel setText:webSound.sourceUrl];
    [soundDescriptionTextField setText:webSound.term];
    
    [self setDownloadStatusLabel];
    
    //
    // We're only getting an empty sound here so that the icon has a place
    // to get/put data.
    //
    self.localSound = [SoundManager getEmptySound];
    soundIcon.theSound = self.localSound;

}

-(void) setDownloadStatusLabel
{
    if ([webSound hasSoundData])
    {
        if (webSound.size > kMax_SoundFileLength)
        {
            [downloadingLabel setHidden:NO];
            downloadingLabel.text = @"You can save this sound, but it's too large to share.";
        }
        else
        {
            downloadingLabel.text = @"";
        }
    }
    else
    {
        [downloadingLabel setHidden:NO];
    }
}

-(void) updateCreditsAvailableLabel
{
    _userCredits = [Config getUserCredits];
    
    if (_userCredits == kUnlimitedCredits)
    {
        [creditsAvailLabel setText:@"Unlimited"];
    }
    else
    {
        [creditsAvailLabel setText:[NSString stringWithFormat:@"%d", _userCredits]];
    }
}

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
    else if (!_playedSound)
    {
        *messageIfFail = [NSString stringWithFormat:@"Please play the sound first to make sure it's ok!"];
    }
    else if (!_playedSoundSuccessfully)
    {
        *messageIfFail = [NSString stringWithFormat:@"It looks like this sound is invalid. Try playing it from the original webpage.  If it is valid, please let us know!"];
    }
    
    return [*messageIfFail length] == 0;
    
}


#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    int dlLength = [activeDownload length];
    int dataLength = [data length];
    int lengthReceived = dlLength + dataLength;
    int totalLength = webSound.size;
    float prog = MIN(((float)lengthReceived / (float)totalLength), 1.0f);
    
    DLog(@"Got some data!  We're at %f pct!", 100.0f * prog);
    [downloadProgress setProgress:prog];
    
    //
    // This odd statement apparently sleeps a bit, allowing the UI to update.
    //
    float delaySecs = [Config getUserServerPreference] == 1 ? 0.05 : 0.05;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delaySecs]];
    
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Failed with error! %@", error.localizedDescription);
    
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [self soundDownloadComplete:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Download complete!");
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    NSDictionary *dataResults = [jsonString objectFromJSONString];
    
    webSound.md5hash = [dataResults objectForKey:@"md5hash"];
    NSString *soundData64 = [dataResults objectForKey:@"datasixtyfour"];
    
    NSData *decodedSoundData = [QSStrings decodeBase64WithString:soundData64];
    NSString *decodedDataMd5 = [decodedSoundData md5];
    BOOL downloadSuccess = [decodedDataMd5 isEqualToString:webSound.md5hash];
    
    DLog(@"Found MD5 hash of: %@, expected %@, is same? %d", decodedDataMd5, webSound.md5hash, downloadSuccess);
    
    if (downloadSuccess)
    {
        DLog(@"Got the sound data!!!");
        webSound.soundData = decodedSoundData;
    }
    
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [self soundDownloadComplete:downloadSuccess];
    
    
}
-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //return YES to say that we have the necessary credentials to access the requested resource
    DLog(@"Can we authenticate?");
    
    return YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    DLog(@"Received authentication request!");
    NSURLCredential *credential = [NSURLCredential credentialWithUser:[Config apiUserName] password:[Config apiPW] persistence:NSURLCredentialPersistenceForSession];
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
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

-(void) hideKeyboard
{
    [soundNameTextField resignFirstResponder];
    [soundDescriptionTextField resignFirstResponder];
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
    //DLog(@"Got an image selection result: %@", result);
    
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

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    DLog(@"Dismissed with index: %d", buttonIndex);
    
    if (alertView.tag == wsdvcSaveWithoutIcon)
    {
        if (buttonIndex == 1)
        {
            //
            // Yes, user wants to save anyway
            //
            [self saveSoundAndExit];
        }
    }
    else
    {
        [NSException raise:@"Unknown alert view" format:@"Has index: %d", alertView.tag];
    }
}

@end
