//
//  TestOtamata.m
//  TestOtamata
//
//  Created by John Baumbach on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestSoundFunctions.h"
#include <sys/xattr.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import "MarkInappropriateOperation.h"
#import "SoundManager.h"

@implementation TestSoundFunctions

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _testSound = [[Sound alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    [_testSound release];

    [super tearDown];
}

-(void)test_Sound_Create
{
    STAssertNotNil(_testSound, @"Test sound not created successfully");
}

-(void)test_Sound_DeploymentSoundIdInt_Invalid
{
    _testSound.soundId = @"1";
    int deploymentSoundId = [_testSound deploymentSoundIdInt];
    
    STAssertEquals(deploymentSoundId, -1, @"Non-deployment sound should return -1");
    
}

-(void)test_Sound_UserSoundIdInt_Invalid
{
    _testSound.soundId = @"1";
    int userSoundId = [_testSound userSoundIdInt];
    
    STAssertEquals(userSoundId, -1, @"Non-user sound should return -1");
    
}

-(void)test_Sound_IsDeploymentSound_Valid
{
    NSString *soundId = @"1";
    _testSound.soundId = [Sound convertedDeloymentSoundIdForId:soundId];
    
    STAssertTrue([_testSound isDeploymentSound], @"Didn't properly recognize a deployment sound");
}

-(void)test_Sound_IsUserSound_Valid
{
    NSString *soundId = @"1";
    _testSound.soundId = [Sound convertedUserSoundIdForId:soundId];
    
    STAssertTrue([_testSound isUserSound], @"Didn't properly recognize a user sound");
}

-(void)test_Sound_IsServerSound_Valid
{
    NSMutableDictionary *initialData = [[[NSMutableDictionary alloc] init] autorelease];
    
    [initialData setValue:@"1" forKey:@"soundid"];
    [initialData setValue:@"Test" forKey:@"name"];
    [initialData setValue:sscPreview forKey:@"status"];
    
    Sound *testSound = [[[Sound alloc] initWithDictionary:initialData] autorelease];
    
    
    STAssertTrue([testSound originatedOnServer], @"Didn't properly recognize a server sound");
}

-(void)test_Sound_IsServerSound_InValid_IsDeployment
{
    NSMutableDictionary *initialData = [[[NSMutableDictionary alloc] init] autorelease];
    
    [initialData setValue:[Sound convertedDeloymentSoundIdForId:@"1"] forKey:@"soundid"];
    [initialData setValue:@"Test" forKey:@"name"];
    [initialData setValue:sscPreview forKey:@"status"];
    
    Sound *testSound = [[[Sound alloc] initWithDictionary:initialData] autorelease];
    
    
    STAssertFalse([testSound originatedOnServer], @"Didn't properly recognize a deployment sound");
}

-(void)test_Sound_IsServerSound_InValid_IsUser
{
    NSMutableDictionary *initialData = [[[NSMutableDictionary alloc] init] autorelease];
    
    [initialData setValue:[Sound convertedUserSoundIdForId:@"1"] forKey:@"soundid"];
    [initialData setValue:@"Test" forKey:@"name"];
    [initialData setValue:sscPreview forKey:@"status"];
    
    Sound *testSound = [[[Sound alloc] initWithDictionary:initialData] autorelease];
    
    
    STAssertFalse([testSound originatedOnServer], @"Didn't properly recognize a user sound");
}



-(void)test_Sound_ConvertedDeloymentSoundIdForId
{
    NSString *soundId = @"1";
    NSString *resultStr = [Sound convertedDeloymentSoundIdForId:soundId];
    NSString *shouldBeStr = [NSString stringWithFormat:@"%@%@%@", DEPLOYMENT_SOUND_PREFIX, DEPLOYMENT_SOUND_DELIM, soundId];
    
    STAssertEqualObjects(resultStr, shouldBeStr, @"Sound id not constructed properly");
}

-(void)test_Sound_DeploymentSoundIdInt_Valid
{
    NSString *soundId = @"1";

    _testSound.soundId = [Sound convertedDeloymentSoundIdForId:soundId];
    
    int deploymentSoundId = [_testSound deploymentSoundIdInt];
    
    STAssertEquals(deploymentSoundId, 1, @"Can't get deployment sound id");
    
}

-(void)test_Sound_ConvertedUserSoundIdForId
{
    NSString *soundId = @"1";
    NSString *resultStr = [Sound convertedUserSoundIdForId:soundId];
    NSString *shouldBeStr = [NSString stringWithFormat:@"%@%@%@", USER_SOUND_PREFIX, USER_SOUND_DELIM, soundId];
    
    STAssertEqualObjects(resultStr, shouldBeStr, @"Sound id not constructed properly");
}

-(void)test_Sound_UserSoundIdInt_Valid
{
    NSString *soundId = @"1";
    
    _testSound.soundId = [Sound convertedUserSoundIdForId:soundId];
    
    int userSoundId = [_testSound userSoundIdInt];
    
    STAssertEquals(userSoundId, 1, @"Can't get user sound id");
    
}

-(void)test_Sound_getServerSoundId_forDeploymentSound
{
    _testSound.soundId = [Sound convertedDeloymentSoundIdForId:@"1"];
    
    NSString *serverSoundId = [_testSound getServerSoundId];
    
    STAssertEqualObjects(serverSoundId, @"53", @"Slow clap should be 53, but is '%@'", serverSoundId);
    
    _testSound.soundId = [Sound convertedDeloymentSoundIdForId:@"6"];
    
    serverSoundId = [_testSound getServerSoundId];
    
    STAssertEqualObjects(serverSoundId, @"54", @"Wah wah should be 54, but is '%@'", serverSoundId);
    
}

-(void)test_Sound_getServerSoundId_forServerSound
{
    _testSound.soundId = @"1";
    
    NSString *serverSoundId = [_testSound getServerSoundId];
    
    STAssertEqualObjects(serverSoundId, _testSound.soundId, @"Server sound id should be '%@', but is '%@'", _testSound.soundId, serverSoundId);
    
}


-(void)test_Sound_setServerSoundId_forUserSound
{
    NSString *soundId = @"1";
    int expectedServerSoundId = 10;
    
    _testSound.soundId = [Sound convertedUserSoundIdForId:soundId];
    _testSound.serverSndId = expectedServerSoundId;
    
    NSString *serverSoundId = [_testSound getServerSoundId];
    NSString *expectedResult = [NSString stringWithFormat:@"%d", expectedServerSoundId];
    
    STAssertEqualObjects(serverSoundId, expectedResult, @"User sound id not correct");
}

-(void)test_Sound_getServerSoundId_forUserSound
{
    NSString *soundId = @"1";
    
    _testSound.soundId = [Sound convertedUserSoundIdForId:soundId];
    
    NSString *serverSoundId = [_testSound getServerSoundId];
    
    STAssertEqualObjects(serverSoundId, @"-1", @"User sound id should be '-1' by default, but is '%@'", serverSoundId);
}

-(void)test_Sound_isOnServer_Success
{
    NSString *soundId = @"1";
    int expectedServerSoundId = 10;
    
    _testSound.soundId = [Sound convertedUserSoundIdForId:soundId];
    _testSound.serverSndId = expectedServerSoundId;
    
    STAssertTrue([_testSound isOnServer], @"Sound is on server, but it thinks it's not.  It's dumb");
}

-(void)test_Sound_isOnServer_Fail
{
    NSString *soundId = @"1";
    
    _testSound.soundId = [Sound convertedUserSoundIdForId:soundId];
    
    STAssertFalse([_testSound isOnServer], @"Sound is not on server, but it thinks it is.  It's dumb");
}

-(void)test_Sound_canUploadToServer
{
    STAssertFalse([_testSound canUploadToServer], @"Empty sound should not be uploadable.");
    
    _testSound.soundId = [Sound convertedUserSoundIdForId:@"1"];
    STAssertFalse([_testSound canUploadToServer], @"Empty user sound should not be uploadable");
}

//
// todo: refactor so this is testable
//
-(void)test_Sound_canPurchase_AlreadyActive
{
    //NSString *reason = nil;
    
    _testSound.status = sscActive;
    //BOOL res =  [SoundManager canPurchase:_testSound withReasonIfNo:&reason];
    
    // STAssertNotNil(reason, @"A description should be returned");
    
}

-(void)test_Sound_hasIconData
{
    STAssertFalse(_testSound.hasIconData, @"Empty icon should have no icon");
    
    const char dummyBytes[] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05 };
    NSData *myData = [[[NSData alloc] initWithBytes:dummyBytes length:6] autorelease];
    _testSound.imageData = myData;
    
    STAssertTrue(_testSound.hasIconData, @"Sound with icon data should say so");
}

-(void)test_SoundManager_nextUserSoundIntIdFromSounds
{
    NSMutableArray *soundList = [[NSMutableArray alloc] init];
    
    int res = [SoundManager nextUserSoundIntIdFromSounds:soundList];
    
    STAssertTrue(res > 0, @"First sound id should be 1");
    
    Sound *localSound = [[[Sound alloc] init] autorelease];
    [soundList addObject:localSound];
    
    res = [SoundManager nextUserSoundIntIdFromSounds:soundList];
    
    STAssertTrue(res == 1, @"Non-user sound shouldn't count as an id");
    
    Sound *localSound2 = [[[Sound alloc] init] autorelease];
    localSound2.soundId = [Sound convertedUserSoundIdForId:@"1"];
    [soundList addObject:localSound2];
    
    res = [SoundManager nextUserSoundIntIdFromSounds:soundList];
    
    STAssertTrue(res == 2, @"Single user sound at id 1 should return 2 (returned %d)", res);
    
    [soundList release];
}


-(void)test_SoundManager_serverSoundIsAlreadyLocal
{
    BOOL res = [SoundManager serverSoundIsAlreadyLocal:nil];
    
    STAssertFalse(res, @"Should be false if nil");
}

-(void)test_SoundManager_soundHaveServerId_inList
{
    //
    // Build a list of sounds
    //
    NSMutableArray *localSoundList = [[[NSMutableArray alloc] init] autorelease];
    
    Sound *localSound = [[[Sound alloc] init] autorelease];
    
    //
    // Create a local sound of id 1, shared, so have server id of 10
    // 
    localSound.soundId = [Sound convertedUserSoundIdForId:@"1"];
    localSound.serverSndId = 10;
    [localSoundList addObject:localSound];

    //
    // A server sound we're going to test
    //
    _testSound.soundId = @"9";
    BOOL res = [SoundManager soundHaveServerId:_testSound inList:localSoundList];
    
    STAssertFalse(res, @"Should be false for sound not on server");

    _testSound.soundId = @"10";

    res = [SoundManager soundHaveServerId:_testSound inList:localSoundList];

    STAssertTrue(res, @"Local sounds should already be on the server");
}

-(void)test_SoundManager_dummyFilename
{
    NSString *res = [SoundManager dummyFilename:sfWav];
    STAssertEqualObjects(res, @"usersound.wav", @"wav version");
    
    res = [SoundManager dummyFilename:sfMp3];
    STAssertEqualObjects(res, @"usersound.mp3", @"mp3 version");
    
    STAssertThrows([SoundManager dummyFilename:99], @"invalid version");
    
}
@end
