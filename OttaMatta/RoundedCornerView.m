//
//  RoundedCornerView.m
//  Moola
//
//  Created by John Baumbach on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RoundedCornerView.h"

@implementation RoundedCornerView

@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _color = [UIColor redColor];
        _cornerRadius = 5.0f;
        
        //
        // This must be in the init for some reason.  Setting it in "drawRect" is too late, and the line
        // is ignored.
        //
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _color = color;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color andCornerRadius:(float)radius
{
    self = [self initWithFrame:frame andColor:color];
    if (self) {
        // Initialization code
        _cornerRadius = radius;
    }
    return self;
}

//
// Property override so that we can refresh the display
//
-(void) setCornerRadius:(float)newRadius
{
    _cornerRadius = newRadius;
    [self setNeedsDisplay];
}

//
// Property override so that we can refresh the display
//
-(void) setColor:(UIColor *)color
{
    [_color release];
    _color = [color retain];
    [self setNeedsDisplay];
}

-(void)dealloc
{
    self.color = nil;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_cornerRadius];
    [_color setFill];
    [path fill];
}

@end
