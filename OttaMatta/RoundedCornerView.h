//
//  RoundedCornerView.h
//  Moola
//
//  Created by John Baumbach on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


//
// As of this writing, you must have these in the parent
// container's DidLoad function.
//
// Todo: fix
//
//  optionPlainView.color = [UIColor whiteColor];
//  optionPlainView.backgroundColor = [UIColor clearColor];
//  [optionPlainView setCornerRadius:13.0f];
//

@interface RoundedCornerView : UIView
{
    UIColor *_color;
    float _cornerRadius;
}


// Helper constructors
- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color;
- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color andCornerRadius:(float)radius;

@property (nonatomic, retain) UIColor *color;

-(void) setCornerRadius:(float)newRadius;

@end
