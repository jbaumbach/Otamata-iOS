//
//  PhotoCropperViewController.h
//  Otamata
//
//  Created by John Baumbach on 7/15/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//
//  Based on a nice template from here:
//
//  https://github.com/ardalahmet/SSPhotoCropperViewController
//

#import <UIKit/UIKit.h>

//
// Protocol you should implement
// 
@protocol PhotoCropperDelegate <NSObject>

- (void) photoCropperDidFinish:(UIImage *)photo;

@end

@interface PhotoCropperViewController: UIViewController<UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIImage *photo;
    UIImageView *imageView;

    id<PhotoCropperDelegate> delegate;
    CGFloat minZoomScale;
    CGFloat maxZoomScale;
    
    CGFloat _captureAreaRatioWidth;
    CGFloat _captureAreaRatioHeight;
    
    CGFloat _initialScaleRatio;
}

//
// UI Elements
// 
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIView *borderView;


//
// Instance properties
//
@property (nonatomic, assign) id<PhotoCropperDelegate> delegate;
@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;

//
// Constructors
//
- (id) initWithPhoto:(UIImage *)aPhoto
            delegate:(id<PhotoCropperDelegate>)aDelegate;

//
// User Actions
//
- (IBAction)chooseClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end

