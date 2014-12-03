//
//  SoundDetailViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundDetailViewController.h"

#import "RoundedCornerView.h"
#import "JSONKit.h"
#import "QSUtilities.h"
#import "GlobalFunctions.h"
#import "SoundManager.h"
#import "Config.h"
#import "SoundPlayer.h"
#import "PurchaseSoundOperation.h"
#import "StoreController.h"
#import "PurchaseViewController.h"

@implementation SoundDetailViewController
@synthesize soundNameLabel;
@synthesize soundDescLabel;
@synthesize fileSizeLabel;
@synthesize uploadByLabel;
@synthesize creditsAvailDescLabel;
//@synthesize costLabel;
@synthesize creditsAvailLabel;
@synthesize soundIcon;
@synthesize downloadProgress;
@synthesize playButton;
@synthesize getCreditsButton;
@synthesize sound;
@synthesize helperController;
@synthesize activeDownload;
@synthesize imageConnection;
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
    
    _playButtonText = [[NSString stringWithString:playButton.titleLabel.text] retain];
    
    [self setScreenFieldsFromSound];
    soundIcon.theSound = sound;
    soundIcon.delegate = self;
    
    [self startSoundDownload];
    //BOOL result = [SoundManager getSoundDataForSound:sound];
    //[self soundDownloadComplete:result];
    
    self.title = @"Download";
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [self updateCreditsAvailableLabel];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.player stopSound];
}

- (void)viewDidUnload
{
    [self setSoundNameLabel:nil];
    [self setSoundDescLabel:nil];
    [self setFileSizeLabel:nil];
    [self setUploadByLabel:nil];
    //[self setCostLabel:nil];
    [self setCreditsAvailLabel:nil];
    [self setSoundIcon:nil];
    [self setDownloadProgress:nil];
    self.helperController = nil;
    
    [self setPlayButton:nil];
    
    [_playButtonText release];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.sound = nil;
    
    [self setCreditsAvailDescLabel:nil];
    [self setGetCreditsButton:nil];
    
    
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [soundNameLabel release];
    [soundDescLabel release];
    [fileSizeLabel release];
    [uploadByLabel release];
    //[costLabel release];
    [creditsAvailLabel release];
    [soundIcon release];
    [downloadProgress release];
    [playButton release];
    [creditsAvailDescLabel release];
    [getCreditsButton release];

    //
    // Moving this here to perhaps solve odd crashing problem when audio
    // is playing and the user exits the screen
    //
    self.player = nil;
    
    [super dealloc];
}

#pragma mark - User Actions

- (IBAction)playClicked:(id)sender {
    if (sound.soundData != nil)
    {
        if (![player isPlaying])
        {
            self.player = [[[SoundPlayer alloc] initWithDataAndPlay:sound.soundData] autorelease];
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

- (IBAction)purchaseClicked:(id)sender 
{
    DLog(@"Current sound status: %d", sound.status);
    NSString *reason = nil;
    
    if (![SoundManager canPurchase:sound withReasonIfNo:&reason]) 
    {
        //
        // Already purchased or the user created this sound
        //
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Thanks, but..." message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [box show];
    }
    /* This doesn't make sense anymore: this is a server sound which may also be a user sound, which is hidden.  So this won't work.
     The solution is to refactor the "canPurchase" function to return the descriptive message about hidden objects.
    else if (sound.status == sscHidden)
    {
        //
        // Purchased and hidden
        //
        // todo: allow the user to go directly there
        //
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Thanks, but..." message:@"This sound is in your trash and can be restored from there (see the Options screen)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [box show];
    }
     */
    else if (_userCredits >= 1) // todo: [sound cost]
    {
        //
        // Mark sound as purchased
        //
        PurchaseSoundOperation *view = [[PurchaseSoundOperation alloc] initWithFrame:self.view.frame];
        [self.view addSubview:view];
        view.delegate = self;
        view.key = vwdPurchase;
        
        [view purchaseSound:sound];
    }
    else
    {
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Time to Reload" message:@"Oops, not enough credits available!  Would you like to view purchase options?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
        [box show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //
    // Purchase option is only box at this time.  If there's more, use the tag property.
    //
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self getCreditsButtonClicked:nil];
    }
}

- (IBAction)getCreditsButtonClicked:(id)sender {
    
    //
    // Let's purchase some sounds
    //
    if ([StoreController purchasingEnabled])
    {
        PurchaseViewController *controller = [[[PurchaseViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    else
    {
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Purchase Error" message:@"Oops, purchasing is disabled on this device.  Check device settings and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [box show];
    }
}

- (IBAction)inappropriateClicked:(id)sender {
    self.helperController = [SoundManager markSoundAsInappropriate:sound fromView:self.view withSendDialogViewCompleteDelegate:self];
}

#pragma mark - SendDialogViewComplete implementation

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status
{
    //
    // The only sending done without a key is with the "inappropriate" controller
    //
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status forKey:(NSString *)key
{
    //
    // The purchase attempt is complete
    //
    if ([key isEqualToString:vwdPurchase])
    {
        if (status == sdvSuccess)
        {
            //
            // Purchase request completed
            //
            sound.status = sscActive;
            [SoundManager serializeSound:sound];

            if (_userCredits != kUnlimitedCredits)
            {
                _userCredits--; // todo: subtract the actual sound credits
            }
            
            [Config setUserCredits:_userCredits];
            [self updateCreditsAvailableLabel];
            
            UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Thank You" message:@"The download is complete." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [box show];
        }
        else
        {
            UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"The download did not successfully complete.  Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [box show];
            
        }
    }
    else
    {
        //
        // Not sure what this would be
        //
        DLog(@"SoundDetailViewController: Unsupported key specified in sendCompleteWithStatus: %@", key);
    }
}

#pragma mark - Instance Methods

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
    
    if (![sound hasSoundData])
    {
        [downloadProgress setProgress:0.0f];
        [downloadProgress setHidden:NO];
        
        //
        // This code is direct from the Apple docs.  It starts the d/l.  The callbacks
        // grab the data.
        //
        NSString *url = [Config soundDetailUrlForId:sound.soundId]; 
        
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
        self.imageConnection = conn;
        [conn release];
        
        [playButton setTitle:btlTextLoading forState:UIControlStateNormal];
        [playButton setTitle:btlTextLoading forState:UIControlStateSelected];
    }
}

-(void) soundDownloadComplete:(BOOL)success
{
    [downloadProgress setHidden:YES];

    if (success)
    {
        [SoundManager serializeSound:sound];

        [playButton setTitle:_playButtonText forState:UIControlStateNormal];
        [playButton setTitle:_playButtonText forState:UIControlStateSelected];
    }
}

-(void) setScreenFieldsFromSound
{
    [soundNameLabel setText:sound.name];
    [soundDescLabel setText:sound.soundDescription];
    soundDescLabel.textColor = [UIColor colorWithHexString:TABBAR_TINT]; //[UIColor whiteColor];
    
    [fileSizeLabel setText:[NSString stringWithFormat:@"%d", sound.size]];
    [uploadByLabel setText:sound.uploadedBy];

    [self updateCreditsAvailableLabel];
}

-(void) updateCreditsAvailableLabel
{
    _userCredits = [Config getUserCredits];
    BOOL unlimited = _userCredits == kUnlimitedCredits;
    
    creditsAvailDescLabel.hidden = unlimited;
    creditsAvailLabel.hidden = unlimited;
    getCreditsButton.hidden = unlimited;
    
    if (!unlimited)
    {
        [creditsAvailLabel setText:[NSString stringWithFormat:@"%d", _userCredits]];
    }
}

#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    int dlLength = [activeDownload length];
    int dataLength = [data length];
    int lengthReceived = dlLength + dataLength;
    int totalLength = sound.size;
    float prog = MIN(((float)lengthReceived / (float)totalLength), 1.0f);
    
    DLog(@"Got some data!  We're at %f pct!", 100.0f * prog);
    [downloadProgress setProgress:prog];
    
    //
    // This odd statement apparently sleeps a bit, allowing the UI to update.
    //
    float delaySecs = [Config getUserServerPreference] == 1 ? 0.95 : 0.1;
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
    
    sound.md5hash = [dataResults objectForKey:@"md5hash"];
    NSString *soundData64 = [dataResults objectForKey:@"datasixtyfour"];
    
    NSData *decodedSoundData = [QSStrings decodeBase64WithString:soundData64];
    NSString *decodedDataMd5 = [decodedSoundData md5];
    BOOL downloadSuccess = [decodedDataMd5 isEqualToString:sound.md5hash];
    
    DLog(@"Found MD5 hash of: %@, expected %@, is same? %d", decodedDataMd5, sound.md5hash, downloadSuccess);
    
    if (downloadSuccess)
    {
        DLog(@"Got the sound data!!!");
        sound.soundData = decodedSoundData;
    }

    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    //[searchResultsTable reloadData];
    
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

#pragma mark - SoundIconViewProtocol implementation

-(void)pressedForSound:(Sound *)sound
{
    [self playClicked:nil];
}

@end
