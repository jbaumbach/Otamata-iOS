//
//  SendingDialogViewItems.m
//  OttaMatta
//
//  Created by John Baumbach on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendingDialogViewItems.h"

@implementation SendingDialogViewItems
@synthesize spinnerView;
@synthesize progressView;
@synthesize statusDetailLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Drawing code
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0f];
    [[UIColor blackColor] setFill];
    [path fill];
}

- (void)dealloc {
    [spinnerView release];
    [progressView release];
    [statusDetailLabel release];
    [super dealloc];
}
@end
