//
//  OtamataSingleton.m
//  OttaMatta
//
//  Created by John Baumbach on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SynthesizeSingleton.h"

#import "OtamataSingleton.h"

@implementation OtamataSingleton

@synthesize origUserVolume;
@synthesize store;

-(void) dealloc
{
    [super dealloc];
    self.store = nil;
}

//
// Cool way to implement a singleton
//
// http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html
//
SYNTHESIZE_SINGLETON_FOR_CLASS(OtamataSingleton);

@end
