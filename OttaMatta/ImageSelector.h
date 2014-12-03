//
//  ImageSelector.h
//  Otamata
//
//  Created by John Baumbach on 7/8/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebImagesearchViewController.h"

//
// A convenience class to help you get an image from the user.
//
// 1. You'll need a parent. Right now, only tab bars are supported.  Get
//    yours like so:
//
//   OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
//   ImageSelector *imageSelection = [[ImageSelector alloc] 
//          initWithTabBarController:[delegate tabBarController] 
//          navBarTint:[UIColor colorWithHexString:NAVBAR_TINT] 
//          andParentViewController:self andDelegate:self];
//   [imageSelection showUI];
//
// 2. Implement the protocol, and enjoy those lovely bytes!
//

@protocol ImageSelectorProtocol <NSObject>

@optional
//
// You should implement one or the other.
//
-(void) imageSelectionCompleteWithImage:(UIImage *)result;
-(void) imageSelectionCompleteWithJPEGData:(NSData *)result;

@end

@interface ImageSelector : NSObject
    <UIActionSheetDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    WebImageSearchProtocol>

//
// Instance Members
//
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UIColor *navBarTint;
@property (nonatomic, retain) UIViewController *parent;
@property (nonatomic, retain) id<ImageSelectorProtocol> delegate;
@property (nonatomic, retain) NSString *searchTerm;

//
// Constructors
//
-(id)initWithTabBarController:(UITabBarController *)sourceTabBarController navBarTint:(UIColor *)soundNavBarTint andParentViewController:(UIViewController *)sourceParent andDelegate:(id<ImageSelectorProtocol>)sourceDelegate;

//
// Instance Methods
//
- (void)showUI;

@end
