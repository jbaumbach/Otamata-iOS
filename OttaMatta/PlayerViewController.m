//
//  OttaFirstViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerViewController.h"
#import <MediaPlayer/MPMusicPlayerController.h>

@implementation PlayerViewController

#import "SoundPlayer.h"
#import "SoundManager.h"
#import "OttaAppDelegate.h"
#import "RateSoundViewController.h"
#import "MarkInappropriateOperation.h"
#import "OtamataFunctions.h"
#import "ShareSoundViewController.h"
#import "ShareSound1ViewController.h"
#import "ShareSoundConfig.h"
#import "Appirater.h"
#import "UploadSoundOperation.h"

@synthesize soundIconContainer;
@synthesize soundList;
@synthesize helperController;
@synthesize senderToFriend;
//@synthesize adView;
@synthesize gadView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Otamata", @"Otamata");
        self.tabBarItem.title = @"Play";
        self.tabBarItem.image = [UIImage imageNamed:@"playicon"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //
    // Configure ad stuff
    //
    if (![Config getRemoveAds])
    {
        [self addOrRemoveBannerAd:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotificationToRemoveAds:) name:gmiRemoveAllAds object:nil];

    
    soundIconContainer.delegate = self;
}

- (void)viewDidUnload
{
    [self setSoundIconContainer:nil];
    self.helperController = nil;
    [_currentSound release];
    self.senderToFriend = nil;
    //self.adView = nil;
    self.gadView.delegate = nil;
    self.gadView = nil;
    
    //
    // Remove us as observer, or app crashes when this object is dealloc'd.
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.soundList = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadSounds];
    
    //self.navigationitem
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL result = (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
    
    //
    // todo: read this link about device info: http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIDevice_Class/Reference/UIDevice.html
    //
    //
    /* causes double-draw on regular init for some reason.  We need a "didAutorotate" or something.
    if (result)
    {
        [soundIconContainer drawView];
    }
     */
    
    return result;
}

- (void)dealloc {
    [soundIconContainer release];
    [super dealloc];
}

#pragma mark - Instance methods

-(void) addOrRemoveBannerAd:(BOOL)add
{
    //
    // Add ads to the player screen
    //
    CGRect iconViewFrame = [soundIconContainer frame];
    
    CGSize bannerAdSize = [OtamataFunctions bannerAdSize];
    
    if (add)
    {
        self.gadView = [OtamataFunctions addBannerAdToView:self.view andViewController:self withSize:bannerAdSize];
        
        iconViewFrame.size.height -= bannerAdSize.height;
        
        [soundIconContainer setFrame:iconViewFrame];
    }
    else 
    {
        if (self.gadView == nil)
        {
            DLog(@"Ummmm... shouldn't be calling this without an adview!");
        }
        else
        {
            iconViewFrame.size.height += bannerAdSize.height;
            
            [soundIconContainer setFrame:iconViewFrame];
            
            [self.gadView removeFromSuperview];
            self.gadView.delegate = nil;
            self.gadView = nil;
            
        }
    }

    //
    // I'm not sure calling [drawView] directly is right, but 
    // [setNeedsDisplay] is being totally ignored.
    // todo: figure out.
    //
    [soundIconContainer drawView];
}

//
// Process the notification that we returned from FB auth
//
-(void) gotNotificationToRemoveAds:(NSNotification *)notification
{
    DLog(@"Got notification msg: %@", notification);
    [self addOrRemoveBannerAd:NO];
}

-(void) loadSounds
{
    self.soundList = [SoundManager getLocalSounds];
    soundIconContainer.itemList = self.soundList;
}

-(void) userSelectedDeleteSound:(Sound *)sound
{
    //
    // Bring up alert box about moving sound to trash.  The delegate callback handles the delete.
    //
    NSString *message = [NSString stringWithFormat:@"Really move \"%@\" to trash?", sound.name];
    
    UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Move to Trash" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    [box setTag:abtDeleteSoundBox];
    _currentSound = sound;
    
    [box show];
} 

-(void) userSelectedRateSound:(Sound *)sound
{
    //
    // Bring up rating dialog
    //
    RateSoundViewController *controller = [[[RateSoundViewController alloc] init] autorelease];
    controller.theSound = sound;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) userSelectedChangeIconForSound:(Sound *)sound
{
    //
    // Todo: bring up icon selection dialog
    //
}

//
// Bring up the share sound view controller.  
//
-(void) showShareSoundViewController
{
    UIViewController *theController;
    ShareSoundConfig *shareConfig = [[[ShareSoundConfig alloc] init] autorelease];
    shareConfig.currentSound = _currentSound;
    
    ShareSound1ViewController *controller = [[[ShareSound1ViewController alloc] init] autorelease];
    controller.shareConfig = shareConfig;
    theController = controller;
    
    [self.navigationController pushViewController:theController animated:YES];
}

//
// Share the sound, bringing up appropriate dialogs
//
-(void) shareSound
{
    NSString *cantSendMsg;
    
    if (![_currentSound canShareSound:&cantSendMsg])
    {
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Sorry" message:cantSendMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [box show];
    }
    else
    {
        [self showShareSoundViewController];
    }     

}

#pragma mark - SendDialogViewComplete protocol

-(void) sendCompleteWithStatus:(int)status
{
    //
    // User marked sound as inappropriate. Ask to move to trash.
    //
    [self userSelectedDeleteSound:_currentSound];
}

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status forKey:(NSString *)key andObject:(id)object
{
    //
    // Something got done.  Let's find out what it was!  Oh boy!
    //
    if ([key isEqualToString:sdkUpload])
    {
        //
        // We got done uploading a sound.  
        //
        if (status == sdvSuccess && [object isKindOfClass:[Sound class]])
        {
            //
            // Upload success!
            //
            _currentSound.serverSndId = [((Sound *)object).soundId intValue];
            [SoundManager serializeSound:_currentSound];
            
            [self shareSound];
        }
        else
        {
            //
            // Bombed out - what to do?  Dialog box?
            //
            UIAlertView *errorBox = [[[UIAlertView alloc] initWithTitle:@"Oops, can't upload!" message:@"The upload wasn't successful for some reason.  Please try again later (when your data connection improves?)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [errorBox show];
        }
    }
    else
    {
        DLog(@"Weird, unknown send dialog was closed: %@", key);
    }
}

#pragma mark - AlertViewDelete protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) 
    {
        case abtDeleteSoundBox:
            DLog(@"Delete sound box was clicked with index: %d", buttonIndex);
            
            if (buttonIndex == 1)
            {
                //
                // Move to trash
                //
                [SoundManager moveSoundToTrash:_currentSound];
                [self loadSounds];
            }
            break;
            

        default:
            DLog(@"Bad programming! Unknown alert view box was clicked.");
            break;
    }
}

#pragma mark - IconViewContainer protocol

-(UIView *) iconViewForItem:(NSObject *)item withFrame:(CGRect)frame
{
    SoundIconView *result = [[SoundIconView alloc] initWithFrame:frame];
    result.theSound = (Sound *)item;
    [result setIconCornerRadius:3.0f];
    
    result.delegate = self;
    
    return [result autorelease];
}

#pragma mark - Action Sheet protocol

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self userSelectedDeleteSound:_currentSound];
    }
    else if ([buttonTitle isEqualToString:sacRateSound])
    {
        [self userSelectedRateSound:_currentSound];
    }
    else if ([buttonTitle isEqualToString:sacInappropriate])
    {
        self.helperController = [SoundManager markSoundAsInappropriate:_currentSound fromView:self.view withSendDialogViewCompleteDelegate:self];
    }
    else if ([buttonTitle isEqualToString:sacSetAsDeployment])
    {
        DLog(@"Set as deployment");
        [SoundManager setSoundAsDeploymentVersion:_currentSound];
    }
    else if ([buttonTitle isEqualToString:sacChangeIcon])
    {
        [self userSelectedChangeIconForSound:_currentSound];
    }
    else if ([buttonTitle isEqualToString:sacSendToFriend])
    {
        if ([_currentSound isOnServer])
        {
            [self shareSound];
        }
        else
        {
            if ([_currentSound canUploadToServer])
            {
                UploadSoundViewController *controller = [[[UploadSoundViewController alloc] init] autorelease];
                controller.sound = _currentSound;
                controller.delegate = self;
                
                //
                // Enable visible to all users by default if this was a web download
                //
                if (_currentSound.soundOriginationCode == socWebDownload)
                {
                    controller.enableAllUsersDefaultIsOn = YES;
                }
                
                [self.navigationController presentModalViewController:controller animated:YES];
            }
            else
            {
                //
                // Todo if large files can be present on the device: more descriptive error message here
                //
                UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"The selected sound cannot be shared at this time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                [box show];
            }
        }
    }
    else if ([buttonTitle isEqualToString:sacTurnAdsOff])
    {
        [self addOrRemoveBannerAd:(self.gadView == nil)];
    }
    else
    {
        DLog(@"Cancel index selected: %d", buttonIndex);
    }
}

#pragma mark - SoundIconView protocol

- (void) longPressedForSound:(Sound *)sound
{
    //
    // Sound Action Sheet - update constants when changing stuff
    //
    NSString *title = [NSString stringWithFormat:@"\"%@\" Actions", [sound name]];
    
    NSMutableArray *buttons = [[[NSMutableArray alloc] init] autorelease];
                                
    // 2012-06-13 JB: old line: initWithObjects:sacRateSound, sacInappropriate, sacSendToFriend, nil] autorelease];

    //
    // Stuff user can only do if the sound is NOT theirs
    //
    if ([sound originatedOnServer])
    {
        [buttons addObject:sacRateSound];
        [buttons addObject:sacInappropriate];
    }
                                
    //
    // User can always do this
    //
    [buttons addObject:sacSendToFriend];
                            
    //
    // If we are a dev user and want to save this sound locally
    //
#ifdef DEV_VERSION
    if ([Config getUserServerPreference] == 1)
    {
        [buttons addObject:sacSetAsDeployment];
        [buttons addObject:sacTurnAdsOff];
    }
#endif
    
    /*
    //
    // This was a valiant effort, and seems like it should work, but always an exception.
    // 
    int buffSize = sizeof(NSString *) * ([buttons count] + 1);
    char *argList = (char *)malloc(buffSize);
    memset(argList,'\0',buffSize);

    //DLog(@"Size of NSString * = %u", sizeof(NSString *));
    
    [buttons getObjects:(id *)argList];
    //argList[sizeof(NSString *) * [buttons count]] = nil;    // 0x0000000;
    
    
    UIActionSheet *soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" otherButtonTitles:(NSString *)argList, nil];
     */

    //
    // Ugh, this is some crappy looking code here.
    //
    UIActionSheet *soundActionSheet = nil;
    
    if ([buttons count] == 1)
    {
        soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" 
                                              otherButtonTitles:[buttons objectAtIndex:0], 
                            nil];
    }
    else if ([buttons count] == 2)
    {
        soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" 
                            otherButtonTitles:[buttons objectAtIndex:0], 
                            [buttons objectAtIndex:1],
                            nil];
    }
    else if ([buttons count] == 3)
    {
        soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" 
                            otherButtonTitles:[buttons objectAtIndex:0], 
                            [buttons objectAtIndex:1], 
                            [buttons objectAtIndex:2], 
                            nil];
    } 
    else if ([buttons count] == 4)
    {
        soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" 
                            otherButtonTitles:[buttons objectAtIndex:0], 
                            [buttons objectAtIndex:1], 
                            [buttons objectAtIndex:2], 
                            [buttons objectAtIndex:3], 
                            nil];
    } 
    else if ([buttons count] == 5)
    {
        soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" 
                                              otherButtonTitles:[buttons objectAtIndex:0], 
                            [buttons objectAtIndex:1], 
                            [buttons objectAtIndex:2], 
                            [buttons objectAtIndex:3], 
                            [buttons objectAtIndex:4], 
                            nil];
    } 
    else if ([buttons count] == 6)
    {
        soundActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Move to Trash" 
                                              otherButtonTitles:[buttons objectAtIndex:0], 
                            [buttons objectAtIndex:1], 
                            [buttons objectAtIndex:2], 
                            [buttons objectAtIndex:3], 
                            [buttons objectAtIndex:4], 
                            [buttons objectAtIndex:5], 
                            nil];
    } 
    else
    {
        DLog(@"Unsupported number of buttons: %d", [buttons count]);
    }
    
    
    OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBar *tabBar = [[delegate tabBarController] tabBar];
    
    _currentSound = sound;
    [soundActionSheet showFromTabBar:tabBar];
    [soundActionSheet release];
}

- (void) pressedForSound:(Sound *)sound
{
    DLog(@"Sound name %@ and id %i", sound.name, [sound deploymentSoundIdInt]);
    
    [SoundPlayer playSoundFromData:sound.soundData];
    
    //
    // Record that the user played a sound for the rate-me reminder thingy.  Can show the box here!
    //
    [Appirater userDidSignificantEvent:YES];

}

#pragma mark - Upload Sound Protocol

-(void) userAction:(ModalResult)action withUserName:(NSString *)userName andSharingPreference:(BOOL)allUsers
{
    DLog(@"Got upload result %d, username = %@, sharing? %d", action, userName, allUsers);
    
    BOOL shouldContinue = action == mrOK;
    
    //
    // Dismiss with animation if we're not going to continue, otherwise hide the dialog quick
    //
    [self.navigationController dismissModalViewControllerAnimated:!shouldContinue];
    
    [GlobalFunctions sleepAndProcessMessages:0.1];
    
    if (shouldContinue)
    {
        //
        // Upload that sound!
        //
        _currentSound.uploadedBy = userName;
        UploadSoundOperation *view = [[UploadSoundOperation alloc] initWithFrame:self.view.frame];
        [self.view addSubview:view];
        view.delegate = self;
        view.key = sdkUpload;
        [view uploadSound:_currentSound isBrowsable:allUsers];
    }
    
}

#pragma mark - ADBannerViewDelegate implementation
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    DLog(@"Banner view didn't get an ad! msg: %@", error.description);
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave

{
    
    DLog(@"Banner view is beginning an ad action");
    
    //BOOL shouldExecuteAction = [self allowActionToRun]; // your application implements this method
    
    if (!willLeave)     // && shouldExecuteAction)
        
    {
        
        // insert code here to suspend any services that might conflict with the advertisement
        
    }
    
    return YES;     // shouldExecuteAction;
    
}
@end
