//
//  ShareSound.m
//  Otamata
//
//  Created by John Baumbach on 4/30/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "ShareSoundConfig.h"
#import "GlobalFunctions.h"
#import "Config.h"

@implementation ShareSoundConfig
@synthesize shareMethods;
@synthesize shareMethodIcons;
@synthesize CurrentType;
@synthesize CurrentMethod;
@synthesize currentSound;

-(id) init
{
    self = [super init];
    
    if (self) {
        // Custom initialization
        
        //
        // The order here must be the same as the "SoundShareMethod" enum in the header
        //
        self.shareMethods = [[[NSArray alloc] initWithObjects:
                             @"Text message",
                             @"Email",
                             @"Twitter", 
                             @"Facebook",
                             @"Copy to clipboard",
                             @"Preview in Safari",
                             nil] autorelease];
        
        //
        // The order here must be the same as the "SoundShareMethod" enum in the header
        //
        self.shareMethodIcons = [[[NSArray alloc] initWithObjects:
                              @"sms-icon.png",
                              @"email-icon.png",
                              @"twitter-icon.png", 
                              @"facebook-icon.png",
                              @"url-icon.png",
                              @"safari-icon.png",
                              nil] autorelease];
    }
    return self;
    
}

-(void) dealloc
{
    self.shareMethods = nil;
    self.currentSound = nil;
}


@end
