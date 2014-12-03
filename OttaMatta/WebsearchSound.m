//
//  WebsearchSound.m
//  Otamata
//
//  Created by John Baumbach on 7/7/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WebsearchSound.h"

@implementation WebsearchSound

@synthesize fileName;
@synthesize soundId;
@synthesize soundData;
@synthesize size;
@synthesize term;
@synthesize sourceUrl;
@synthesize md5hash;

-(void) dealloc
{
    //
    // Set to nil all objects
    //
    self.fileName = nil;
    self.soundId = nil;
    self.soundData = nil;
    self.term = nil;
    self.sourceUrl = nil;
    self.md5hash = nil;
    
    [super dealloc];
}

+(NSString *)otamataWebsoundSerializedFileExtension
{
    return @"otamataws";
}

-(BOOL) hasSoundData
{
    return [self.soundData isKindOfClass:[NSData class]];
}


@end
