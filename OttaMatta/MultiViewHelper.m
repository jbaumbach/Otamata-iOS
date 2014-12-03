//
//  MultiViewHelper.m
//  Otamata
//
//  Created by John Baumbach on 8/13/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "MultiViewHelper.h"
#import "GlobalFunctions.h"

@implementation MultiViewHelper

@synthesize pages;
@synthesize parentView;
@synthesize defaultKey;

#pragma mark - View Lifecycle

-(id)initWithParent:(UIView *)parent andInitialView:(int)key
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.parentView = parent;
        self.defaultKey = key;
        self.pages = [[[NSMutableDictionary alloc] init] autorelease];
    }
    return self;
    
}

-(void)dealloc
{
    self.pages = nil;
    self.parentView = nil;
    
    [self dealloc];
}

#pragma mark - Instance Methods

-(void) setViewStatus:(int)pageKey
{
    for (NSNumber *key in pages) 
    {
        UIView *page = [pages objectForKey:key];
        
        DLog(@"Hiding page: %@", key);
        [page setHidden:YES];
    }
    
    UIView *pageToMakeVisible = (UIView *)[pages objectForKey:[NSNumber numberWithInt:pageKey]];
    [pageToMakeVisible setHidden:NO];
    
}

-(void) addPage:(UIView *)view withKey:(int)key
{
    CGRect mainViewRect = parentView.frame;
    
    view.frame = CGRectMake(0, 
                            mainViewRect.size.height - view.frame.size.height, 
                            view.frame.size.width, 
                            view.frame.size.height);  
    
    [parentView addSubview:view];
    
    [pages setObject:view forKey:[NSNumber numberWithInt:key]];
    [view setHidden:(key != defaultKey)];
    
}

@end
