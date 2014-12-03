//
//  TestConfig.m
//  Otamata
//
//  Created by John Baumbach on 6/10/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "TestConfig.h"
#import "Config.h"

@implementation TestConfig

// All code under test must be linked into the Unit Test bundle
- (void)test_Config_encrytpedSoundId
{
    /*
        Example
        
        player version = 1
        dispay type = 0
        sound number = 23
        
        /player/c6dPbWa
    */
    
    SoundPlayerVersion playerVer = spvVersion1;
    SoundShareType shareType = sstFullSoundDetails;
    NSString *soundId = @"23";
    
    NSString *res = [Config encryptedSoundId:soundId playerVersion:playerVer displayType:shareType];
    
    
    STAssertTrue([res characterAtIndex:4] == 'b', @"SoundPlayerVersion failed");
    
    STAssertTrue([res characterAtIndex:6] == 'a', @"SoundShareType failed");
    
    STAssertTrue([res characterAtIndex:0] == 'c', @"Sound digit 1 failed");
    
    STAssertTrue([res characterAtIndex:2] == 'd', @"Sound digit 2 failed");
    
    soundId = @"user-1";
    
    STAssertThrows([Config encryptedSoundId:soundId playerVersion:playerVer displayType:shareType], @"Invalid sound id accepted");
    
    
    
    
}

@end
