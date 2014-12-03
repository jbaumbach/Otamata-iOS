#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GlobalFunctions.h"

/*
 Modified: 2011/12/10 by John Baumbach
 
 A more sophisticated button than the standard UIButton, with no background graphics required.
 
 Based on tutorial here:
 
 http://www.cimgf.com/2010/01/28/fun-with-uibuttons-and-core-animation-layers/
 
 and modified with some help here:
 
 http://arstechnica.com/apple/guides/2009/02/iphone-development-accessing-uicolor-components.ars
 
 */

@interface ColorfulButton : UIButton 
{
    UIColor *_highColor;
    UIColor *_lowColor;
    
    CAGradientLayer *gradientLayer;
    float _cornerRadius;
}

@property (nonatomic, retain) UIColor *highColor;
@property (nonatomic, retain) UIColor *lowColor;
@property (nonatomic, retain) CAGradientLayer *gradientLayer;
@property (nonatomic) float cornerRadius;

- (void)setHighColor:(UIColor*)color;
- (void)setLowColor:(UIColor*)color;


@end

