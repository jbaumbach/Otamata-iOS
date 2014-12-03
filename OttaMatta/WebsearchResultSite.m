//
//  WebsearchResultSite.m
//  Otamata
//
//  Created by John Baumbach on 7/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WebsearchResultSite.h"

@implementation WebsearchResultSite
@synthesize siteName;
@synthesize sounds;

-(void) dealloc
{
    self.siteName = nil;
    self.sounds = nil;
    
    [super dealloc];
}
@end
