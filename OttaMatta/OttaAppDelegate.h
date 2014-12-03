//
//  OttaAppDelegate.h
//  OttaMatta
//
//  Created by John Baumbach on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OttaAppDelegate : UIResponder 
    <UIApplicationDelegate, 
    UITabBarControllerDelegate>

//
// Instance properties
//
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

//
// Instance methods
//
-(void) setUpUUID;
-(void) setUpMuteSwitchOverride;
-(void) showWelcomeScreen;
-(void) setUpVolume;
-(void) restoreOriginalVolume;
- (BOOL) continueWithFacebookFromUrl:(NSURL *)url;

@end
