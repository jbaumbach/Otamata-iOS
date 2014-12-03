//
//  PhotoCropperViewController.m
//  Otamata
//
//  Created by John Baumbach on 7/15/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "PhotoCropperViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalFunctions.h"


@interface PhotoCropperViewController (Private)
- (void) loadPhoto;
@end

@implementation PhotoCropperViewController

@synthesize borderView;
@synthesize scrollView; 
@synthesize photo;
@synthesize imageView;
@synthesize delegate;
@synthesize minZoomScale;
@synthesize maxZoomScale;


- (id) initWithPhoto:(UIImage *)aPhoto
            delegate:(id<PhotoCropperDelegate>)aDelegate
{
    if (!(self = [super initWithNibName:@"PhotoCropperViewController" bundle:nil])) {
        return self;
    }

    self.photo = aPhoto;
    self.delegate = aDelegate;
    self.minZoomScale = 0.5f;
    self.maxZoomScale = 3.0f;

    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.photo = nil;
        self.delegate = nil;
    }
    return self;
}

- (void) dealloc
{
    self.scrollView = nil;
    self.photo = nil;
    self.imageView = nil;
    self.borderView = nil;
    
    [super dealloc];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.scrollView.backgroundColor = [UIColor blackColor];
    borderView.layer.borderColor = [[UIColor grayColor] CGColor];
    [borderView.layer setBorderWidth: 2.0];


    
    [self.scrollView setMinimumZoomScale:self.minZoomScale];
    [self.scrollView setMaximumZoomScale:self.maxZoomScale];

    if (self.photo != nil) {
        [self loadPhoto];
    }
}

- (void) viewDidUnload
{
    [self setBorderView:nil];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark - UIScrollViewDelegate Methods

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


#pragma mark - Private Methods

- (void) loadPhoto
{
    if (self.photo == nil) {
        return;
    }

    CGFloat w = self.photo.size.width;
    CGFloat h = self.photo.size.height;
    
    //
    // Scale the image a bit on load so it fills the width or height (whichever is biggest)
    //
    CGFloat bw = borderView.frame.size.width;
    CGFloat bh = borderView.frame.size.height;
    
    float widthRatio = w / bw;
    float heightRatio = h / bh;
    
    _initialScaleRatio = MAX(widthRatio, heightRatio);
    DLog(@"Initial scale: %f", _initialScaleRatio);
    
    CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, roundf(w / _initialScaleRatio), roundf(h / _initialScaleRatio));

    self.scrollView.contentSize = imageViewFrame.size;

    UIImageView *iv = [[UIImageView alloc] initWithFrame:imageViewFrame];
    iv.image = self.photo;
    [self.scrollView addSubview:iv];
    self.imageView = iv;
    
    _captureAreaRatioWidth = self.borderView.frame.size.width / self.imageView.frame.size.width;
    _captureAreaRatioHeight = self.borderView.frame.size.height / self.imageView.frame.size.height;

    
    [iv release];
}

-(CGRect) getCroppingRect
{
    CGFloat ox = self.scrollView.contentOffset.x;
    CGFloat oy = self.scrollView.contentOffset.y;
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat containerRatio = self.imageView.frame.size.height / self.photo.size.height;
    
    DLog(@"Scroll stuff: ox= %f    oy= %f   zs= %f", ox, oy, zoomScale);
    DLog(@"orig pic:      w= %f     h= %f", self.photo.size.width, self.photo.size.height);
    DLog(@"cont pic:      w= %f     h= %f   zs= %f", self.imageView.frame.size.width, self.imageView.frame.size.height, containerRatio);
    DLog(@"Cap area:      w= %f,    h= %f", _captureAreaRatioWidth, _captureAreaRatioHeight);
   
    
    float rox = _initialScaleRatio * ox / zoomScale;
    float roy = _initialScaleRatio * oy / zoomScale;

    float rw = MIN(self.photo.size.width, self.photo.size.width * _captureAreaRatioWidth / zoomScale);
    float rh = MIN(self.photo.size.height, self.photo.size.height * _captureAreaRatioHeight / zoomScale);
    DLog(@"predicted new:ox= %f    oy= %f   w= %f   h= %f", rox, roy, rw, rh);
    
    return CGRectMake(rox, roy, rw, rh);
}

- (UIImage *) croppedPhoto
{
    CGRect cropRect = [self getCroppingRect];
    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.photo CGImage], cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return result;
}

- (IBAction) saveAndClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropperDidFinish:)]) {
        [self.delegate photoCropperDidFinish:[self croppedPhoto]];
    }
}

- (IBAction) cancelAndClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropperDidFinish:)]) {
        [self.delegate photoCropperDidFinish:nil];
    }
}

- (IBAction)chooseClicked:(id)sender {
    [self saveAndClose:nil];
}

- (IBAction)cancelClicked:(id)sender {
    [self cancelAndClose:nil];
    // debugging: comment out above, and use this: [self getCroppingRect];
}
@end
