//
//  ImageSelector.m
//  Otamata
//
//  Created by John Baumbach on 7/8/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "ImageSelector.h"
#import "GlobalFunctions.h"
#import "Config.h"

@implementation ImageSelector
@synthesize tabBarController;
@synthesize navBarTint;
@synthesize parent;
@synthesize delegate;
@synthesize searchTerm;

//
// Get tab bar controller like so:
//  OttaAppDelegate *delegate = (OttaAppDelegate *)[[UIApplication sharedApplication] delegate];
//  [delegate tabBarController]
//

-(id)initWithTabBarController:(UITabBarController *)sourceTabBarController navBarTint:(UIColor *)soundNavBarTint andParentViewController:(UIViewController *)sourceParent andDelegate:(id<ImageSelectorProtocol>)sourceDelegate;
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.tabBarController = sourceTabBarController;
        self.navBarTint = soundNavBarTint;
        self.parent = sourceParent;
        self.delegate = sourceDelegate;
    }
    return self;

}

-(void)dealloc
{
    self.tabBarController = nil;
    self.navBarTint = nil;
    self.parent = nil;
    self.delegate = nil;
    self.searchTerm = nil;
    
    [super dealloc];
}


- (void)showUI
{
    //
    // Ask user where to get pictures
    //
	UIActionSheet *popupQuery = [[UIActionSheet alloc] 
                                 initWithTitle:@"Select Icon" 
                                 delegate:self 
                                 cancelButtonTitle:@"Cancel" 
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Choose from photos", 
                                 @"Take a picture", 
                                 @"Search the web",
                                 nil];
    
    UITabBar *tabBar = [tabBarController tabBar];
    
    [popupQuery showFromTabBar:tabBar];
    [popupQuery release];
}


#pragma mark - Image Picker delegate

//
// This happens when the button is clicked
//
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    UIImagePickerControllerSourceType sourceType;
    BOOL haveImage = NO;
    BOOL searchWeb = NO;
    
    NSString *errMsg = @"";
    
    if (buttonIndex == 0) {
        //
        // Choose from photos
        //
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        haveImage = YES;
	} else if (buttonIndex == 1) {
		//
        // Take a picture with camera
        //
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            sourceType = UIImagePickerControllerSourceTypeCamera;
            haveImage = YES;
        }
        else
        {
            errMsg = @"Sorry, looks like no camera available.";
        }        
    } else if (buttonIndex == 2) {
        searchWeb = YES;
    }
    
    if (haveImage)
    {
        
        // Set up the image picker controller and add it to the view
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.navigationBar.tintColor = navBarTint;
        imagePickerController.sourceType = sourceType;
        [parent presentModalViewController:imagePickerController animated:YES];
        [imagePickerController release];
        
    }
    else if (searchWeb)
    {
        WebImagesearchViewController *searchController = [[WebImagesearchViewController alloc] init];
        searchController.delegate = self;
        searchController.navTintColor = navBarTint;
        searchController.term = searchTerm;

        [parent presentModalViewController:searchController animated:YES];
        [searchController release];
    }
    else 
    {
        if ([errMsg length] > 0)
        {
            UIAlertView *msg = [[[UIAlertView alloc] initWithTitle:@"Oops" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [msg show];
        }
    }
}

-(UIImage *) getScaledImage:(UIImage *)sourceImage
{
    //
    // Max picture size we're allowing
    //
    CGSize newSize = CGSizeMake(150.0, 150.0);
    
    return [GlobalFunctions convertImage:sourceImage scaledToSize:newSize];
}

-(void) exitDialogWithImage:(UIImage *)newImage
{
    if ([delegate respondsToSelector:@selector(imageSelectionCompleteWithImage:)])
    {
        [delegate imageSelectionCompleteWithImage:newImage];
    }
    
    //
    // Set jpeg compression to 45.  Seems reasonable.
    //
    if ([delegate respondsToSelector:@selector(imageSelectionCompleteWithJPEGData:)])
    {
        [delegate imageSelectionCompleteWithJPEGData:UIImageJPEGRepresentation(newImage, 0.45)];
    }
}

//
// This happens when a user finished picking an image.
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissModalViewControllerAnimated:NO];
    
    UIImage *selectedIcon = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    // todo: replace below call
    
    //
    // Max picture size we're allowing
    //
    CGSize newSize = CGSizeMake(150.0, 150.0);
    
    UIImage *newImage = [GlobalFunctions convertImage:selectedIcon scaledToSize:newSize];
    
    
    
    // todo: replace below call
    
    if ([delegate respondsToSelector:@selector(imageSelectionCompleteWithImage:)])
    {
        [delegate imageSelectionCompleteWithImage:newImage];
    }
    
    //
    // Set jpeg compression to 45.  Seems reasonable.
    //
    if ([delegate respondsToSelector:@selector(imageSelectionCompleteWithJPEGData:)])
    {
        [delegate imageSelectionCompleteWithJPEGData:UIImageJPEGRepresentation(newImage, 0.45)];
    }
    
}

//
// This happens when the user cancelled the image picker.
//
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    [picker dismissModalViewControllerAnimated:YES];

    //
    // todo: replace below call with common func above
    
    if ([delegate respondsToSelector:@selector(imageSelectionCompleteWithImage:)])
    {
        [delegate imageSelectionCompleteWithImage:nil];
    }
    
    if ([delegate respondsToSelector:@selector(imageSelectionCompleteWithJPEGData:)])
    {
        [delegate imageSelectionCompleteWithJPEGData:nil];
    }
}

#pragma mark - WebImageSearchProtocal implementation

-(void) userDidSelectImage:(BOOL)result withImage:(UIImage *)image
{
    DLog(@"userSelectedImage!");
    
    if (result)
    {
        UIImage *scaledImage = [self getScaledImage:image];
        [parent dismissModalViewControllerAnimated:YES];
        [self exitDialogWithImage:scaledImage];
    }
    else
    {
        [parent dismissModalViewControllerAnimated:YES];
    }
}

@end
