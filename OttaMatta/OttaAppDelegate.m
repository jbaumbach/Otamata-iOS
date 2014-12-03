//
//  OttaAppDelegate.m
//  OttaMatta
//
//  Created by John Baumbach on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OttaAppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
#import "PlayerViewController.h"
#import "MarketViewController.h"
#import "OptionsViewController.h"
#import "GlobalFunctions.h"
#import "Config.h"
#import "SoundManager.h"
#import "WelcomeScrollViewController.h"
#import "OtamataSingleton.h"
#import "OtamataPurchaseManager.h"
#import "ShareSoundHelperController.h"
#import "Appirater.h"
#import "RecorderViewController.h"
#import "WebsearchViewController.h"
#import "TapForTap.h"

@implementation OttaAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

#pragma mark - Instance methods

//
// If the user doesn't have a UUID yet, generate one and save to NSUserDefaults
//
-(void) setUpUUID
{
    NSString *userUUID = [Config getUUID];
    
    if ([userUUID length] == 0)
    {
        DLog(@"No UUID created yet.");
        
        CFUUIDRef newUUIDref = CFUUIDCreate(nil);
        CFStringRef newUUIDStr = CFUUIDCreateString(nil, newUUIDref);
        
        DLog(@"Created new UUID, writing: %@", newUUIDStr);
        
        // Created new UUID, such as: 8C207175-2817-4DD6-9C14-95062BC12277
        
        [Config setUUID:(NSString *)newUUIDStr];
        
        CFRelease(newUUIDref);
        CFRelease(newUUIDStr);
    }
    else
    {
        DLog(@"Normal startup - found UUID: %@", userUUID);
    }
}

//
// Turn on sounds regardless of the silent mode switch
//
//  http://developer.apple.com/library/IOs/#documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Configuration/Configuration.html
//
-(void) setUpMuteSwitchOverride
{
    if (YES)
    {
        NSError *setCategoryError = nil;
        
        AVAudioSession *avSession = [AVAudioSession sharedInstance];

        [avSession
         setCategory: AVAudioSessionCategoryPlayback 
         error: &setCategoryError];
        
        if (setCategoryError) 
        {
            DLog(@"Error setting category: %@", setCategoryError.description);
        }
        
        [avSession setActive:YES error:nil];
    }
    
}

-(void) showWelcomeScreen
{
    if ([Config getIsFirstRun])
    {
        //
        // Delay a bit before showing the screen, it looks a lil bit better.
        //
        [GlobalFunctions sleepAndProcessMessages:0.4];
        
        WelcomeScrollViewController *welcomeController = [[[WelcomeScrollViewController alloc] init] autorelease];
        [self.window.rootViewController presentModalViewController:welcomeController animated:YES];

        [Config setIsFirstRun:NO];
    }
}

-(void) setUpVolume
{
    OtamataSingleton *sharedStuff = [OtamataSingleton sharedOtamataSingleton];
    sharedStuff.origUserVolume = [GlobalFunctions getCurrentMediaVolume];
    DLog(@"Recorded original volume: %f", sharedStuff.origUserVolume);
    
    if ([Config getVolumeShouldBeFull])
    {
        [GlobalFunctions setCurrentMediaVolume:[Config getUserVolume]];
    }
}

-(void) restoreOriginalVolume
{
    if ([Config getVolumeShouldBeFull])
    {
        OtamataSingleton *sharedStuff = [OtamataSingleton sharedOtamataSingleton];
        [GlobalFunctions setCurrentMediaVolume:sharedStuff.origUserVolume];
        DLog(@"Restored original volume: %f", sharedStuff.origUserVolume);
    }
}

-(void) debugOutputUserSettings
{
    //
    // Display the values of the various secure keys
    //
    //[Config getEnableWebsearchDownloads
    DLog(@"-- Otamata secure values --");
    DLog(@"UUID:            %@", [Config getUUID]);
    DLog(@"User Credits:    %d", [Config getUserCredits]);
    DLog(@"EnableWebsearch: %d", [Config getEnableWebsearchDownloads]);
    DLog(@"RemoveAds:       %d", [Config getRemoveAds]);
    
}

//
// This function processes the Facebook callback and continues sharing where the user left off.  The
// callback provides us with authorization to post to the user's graph (or not).  When our controller is launched
// the Facebook info is processed with the controller as the delegate.  The controller handles the next steps.
//
- (BOOL) continueWithFacebookFromUrl:(NSURL *)url
{
    //
    // We are assuming the same viewcontrollers that launched the FB auth call are still
    // loaded in this app.  This will call functions in the ShareSoundHelperController 
    // that save the tokens and stuff from the url
    // 
    [[NSNotificationCenter defaultCenter] postNotificationName:gmiReturnFromFBAuthorization object:url];
    
    return YES;
}

-(void) checkinWithTapForTap
{
    if (![Config getRemoveAds])
    {
#ifdef TAP4TAP_ENABLE
        //
        // Check-in runs async already, no need to put it in an async block.
        //
        [TapForTap setDefaultAppId:TAP4TAP_APP_ID];
        [TapForTap checkIn];
#endif
    }
}

-(void) setUserDefaults
{
    //
    // For version 1.4, the users get unlimited downloads.  This can/will change in 
    // subsequent versions, but all users up till then will get grandfathered in.
    //
    [Config setUserCredits:kUnlimitedCredits];    
    

    //
    // debug only - Generally keep this commented out.  Sets user credits to 30
    //
#ifdef DEV_VERSION
    //
    // Debugging only - set some manual values.  Remove this code when tested.
    //
    //[Config setRemoveAds:YES];
    //[Config setEnableWebsearchDownloads:YES];
    //[Config clearAllSecureKeys];
    
    // [Config setUserCredits:30];
#endif

}

#pragma mark - Application lifecycle

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    // Initing before loading views.
    //
    [self setUserDefaults];
    [self checkinWithTapForTap];
    [self setUpUUID];
    [SoundManager deployDefaultSounds];
    [self setUpMuteSwitchOverride];
    [self setUpVolume];
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //
    // Main Screen - PlayerViewController
    //
    UIViewController *viewController1 = [[[PlayerViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nav1 = [[[UINavigationController alloc] initWithRootViewController:viewController1] autorelease];
    nav1.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];
    
    // 
    // MarketViewController
    //
    UIViewController *viewController2 = [[[MarketViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nav2 = [[[UINavigationController alloc] initWithRootViewController:viewController2] autorelease];
    nav2.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];

    //
    // Search - WebsearchViewController
    //
    UIViewController *searchViewController = [[[WebsearchViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *searchNav = [[[UINavigationController alloc] initWithRootViewController:searchViewController] autorelease];
    searchNav.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];
    
    // 
    // RecorderViewController
    //
    UIViewController *viewController3 = [[[RecorderViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nav3 = [[[UINavigationController alloc] initWithRootViewController:viewController3] autorelease];
    nav3.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];
    
    // 
    // OptionsViewController
    //
    UIViewController *viewController4 = [[[OptionsViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nav4 = [[[UINavigationController alloc] initWithRootViewController:viewController4] autorelease];
    nav4.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];

    
    //
    // Add all top level navs/view controllers to the main tab bar controller
    // 
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:nav1, nav2, searchNav, nav3, nav4, nil];
    
    //
    // Set up the tab bar color (iOS 5+ only)
    // 
    if ([self.tabBarController.tabBar respondsToSelector:@selector(setTintColor:)])
    {
        [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:TABBAR_TINT]];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithHexString:SORTSEGMENT_TINT]];
    }
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    //
    // More application initing
    //
    [self showWelcomeScreen];

    //
    // Apple likes your app to process store transactions at all times.  Let's make it so.
    //
    StoreController *store = [[StoreController alloc] init];
    [OtamataSingleton sharedOtamataSingleton].store = store;
    OtamataPurchaseManager *pm = [[[OtamataPurchaseManager alloc] init] autorelease];
    store.purchaseDelegate = pm;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:store];

    //
    // Record that the app was launched for the rate nagger thingy.  Don't show box here tho.
    //
    [Appirater appLaunched:NO];
    
#ifdef DEV_VERSION
    [self debugOutputUserSettings];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    //
    // Note: this successfully restores the orginal volume, but some apps (iPod)
    // when entering foreground will read the value before it's reset.  So, the iPod
    // will play at the correct volume but the slider shows the wrong volume.
    //
    // This isn't a problem if this is set in "applicationWillResignActive", but when
    // it's there the volume is reset when the user brings up task manager.  That is
    // even more common, so it's the greater of two evils.  
    //
    [self restoreOriginalVolume];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */

    //
    // Interesting note: in "applicationDidBecomeActive", this changes the volume but does NOT show the normal device volume change overlay
    //
    [self setUpVolume];
    
    //
    // Record that the app was re-launched for the rate nagger thingy.  Don't show box here tho.
    //
    [Appirater appEnteredForeground:NO];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

//
// Someone deep-linked into my app
//
// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    DLog(@"handleOpenURL: %@", url);

    return [self continueWithFacebookFromUrl:url];
}

//
// Someone deep-linked into my app
//
// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DLog(@"openURL: %@, %@", url, sourceApplication);
    
    return [self continueWithFacebookFromUrl:url];

}


@end
