//
//  RateView.h
//  CustomView
//
//  Created by Ray Wenderlich on 7/30/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RateView;

@protocol RateViewDelegate
- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating;
@end

@interface RateView : UIView {
    UIImage *_notSelectedImage;
    UIImage *_halfSelectedImage;
    UIImage *_fullSelectedImage;
    float _rating;
    BOOL _editable;
    NSMutableArray *_imageViews;
    int _maxRating;
    int _midMargin;
    int _leftMargin;
    CGSize _minImageSize;
    id <RateViewDelegate> _delegate;
}

@property (nonatomic, retain) UIImage *notSelectedImage;
@property (nonatomic, retain) UIImage *halfSelectedImage;
@property (nonatomic, retain) UIImage *fullSelectedImage;
@property (nonatomic) float rating;
@property  BOOL editable;
@property (nonatomic) int maxRating;
@property (assign) id <RateViewDelegate> delegate;
@property  int leftMargin;

@end