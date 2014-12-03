//
//  WebImagesearchViewController.h
//  Otamata
//
//  Created by John Baumbach on 7/14/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCropperViewController.h"

@protocol WebImageSearchProtocol <NSObject>

-(void) userDidSelectImage:(BOOL)result withImage:(UIImage *)image;

@end

@interface WebImagesearchViewController : UIViewController
    <PhotoCropperDelegate,
    UISearchBarDelegate,
    UIScrollViewDelegate>
{
    int _currentKeyboardKey;
}

//
// UI Elements
//
//@property (retain, nonatomic) IBOutlet UINavigationBar *mainNav;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UISearchBar *theSearchBar;

//
// User Actions
// 
- (IBAction)cancelClicked:(id)sender;
-(void) userClickedImage:(UIGestureRecognizer *)gestureRecognizer;

//
// Instance Members
//
@property (nonatomic, retain) NSString *term;
@property (nonatomic, retain) NSDictionary *images;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) id<WebImageSearchProtocol> delegate;
@property (nonatomic, retain) UIColor *navTintColor;
@property (nonatomic, retain) UIScrollView *imageScroller;
@property (nonatomic, retain) UIView *containerView;

//
// Instance Methods
//
-(void) startImageSearch;
-(void) soundDownloadComplete:(BOOL)success;
-(void) loadImageAsync:(UIImageView *)imageView withUrl:(NSString *)url;
-(void) setScroller;
@end

//
// Helper classes
//
@interface WebsearchImageView : UIImageView 
@property (nonatomic, retain) NSDictionary *sourceImageInfo;
@end