//
//  SoundManager.m
//  OttaMatta
//
//  Created by John Baumbach on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

#import "Config.h"
#import "JSONKit.h"
#import "QSUtilities.h"
#import "GlobalFunctions.h"
#import "MarkInappropriateController.h"

@implementation SoundManager

+(BOOL) isSoundFile:(NSString *)filename
{
    NSString *ext = [[filename pathExtension] lowercaseString];
    return [ext isEqualToString:[Sound otamataSerializedFileExtension]];
}

+(NSString *) fullLocalFilenameFromFilename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
}

+(Sound *) getLocalSoundFromId:(NSString *)soundId
{
    return [self getLocalSoundFromFilename:[Sound localSerializedDataFileName:soundId]];
}

+(Sound *) getLocalSoundFromFilename:(NSString *)fileName
{
    NSString *fullLocalFilename = [self fullLocalFilenameFromFilename:fileName];
    Sound *result = nil;

    if ([GlobalFunctions fileExists:fullLocalFilename])
    {
        NSFileManager *filemgr =[NSFileManager defaultManager];
        NSData *encodedObject = [filemgr contentsAtPath:fullLocalFilename];
        
        result = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

        if (result.programVersion < PROGRAM_VERSION)
        {
            //
            // Todo: upgrade the local sound with new fields.
            //
        }
    }
    
    return result;
}

+(NSMutableArray *) getLocalSounds
{
    return [self getLocalSoundsOfStatus:sscActive];
}

+(NSMutableArray *) getLocalSoundsOfStatuses:(NSArray *)soundStatusCodes
{
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSNumber *statusCode in soundStatusCodes)
    {
        [result addObjectsFromArray:[self getLocalSoundsOfStatus:[statusCode intValue]]];
    }
    
    return result;
}

+(NSMutableArray *) getLocalSoundsOfStatus:(SoundStatusCode)statusCode
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];  

    NSFileManager *filemgr =[NSFileManager defaultManager];
    
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < [filelist count]; i++)
    {
        NSString *filename = [filelist objectAtIndex: i];
        //DLog(@"Found file: %@", filename);
        
        if ([self isSoundFile:filename])
        {
            Sound *theSound = [self getLocalSoundFromFilename:filename];
            
            if (theSound.status == statusCode)
            {
                [result addObject:theSound];
                //DLog(@"Added sound to list: %@", theSound);
            }
            else
            {
                //DLog(@"Not adding sound! %@", theSound);
            }
        }
    }
    
    //[filemgr release];

    return result;
}

+(BOOL) serializeSound:(Sound *)sound
{
    BOOL result;
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    
    NSString *serializedDataPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, sound.localSerializedDataFileName];
    
    DLog(@"Prolly gonna write to this file: %@", serializedDataPath);
    
    //
    // Check if file exists, and if so, delete it.
    //
    if ([GlobalFunctions fileExists:serializedDataPath])
    {
        BOOL res = [[NSFileManager defaultManager] removeItemAtPath:serializedDataPath error:&error];
        
        DLog(@"Found file at '%@', result of removal: %d", serializedDataPath, res);
    }
    
    DLog(@"Serializing object: %@", sound);
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:sound];

    DLog(@"Writing file %@ of size %ld", serializedDataPath, sound.size);
    result = [encodedObject writeToFile:serializedDataPath atomically:NO];
     
    return result;
    
}

+(void) moveSoundToTrash:(Sound *)sound
{
    [self setLocalSoundStatus:sound toStatus:sscHidden];
}

+(void) setLocalSoundStatus:(Sound *)sound toStatus:(SoundStatusCode)status
{
    sound.status = status;
    [self serializeSound:sound];
}

+(id) markSoundAsInappropriate:(Sound *)sound fromView:(UIView *)parentView withSendDialogViewCompleteDelegate:(id<SendDialogViewComplete>)delegate;
{
    MarkInappropriateController *controller = [[[MarkInappropriateController alloc] initWithSound:sound andView:parentView withDelegate:delegate] autorelease];
    [controller markSoundAsInappropriate];
    return controller;
}

+(void) userHasRatedSound:(Sound *)sound
{
    //
    // Todo: record locally that user has rated the sound, so can't rate it again
    //
}

//
// Populate any default sounds that we need to
//
+(void) deployDefaultSounds
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (int i = 1; i <= NUMBER_OF_DEPLOYMENT_SOUNDS; i++)
    {
        //
        // See if target file exists
        //
        NSString *targetSoundId = [Sound convertedDeloymentSoundIdForId:[NSString stringWithFormat:@"%d", i]];
        
        NSString *fullLocalFileName = [self fullLocalFilenameFromFilename:[Sound localSerializedDataFileName:targetSoundId]];
        
        if (![fileManager fileExistsAtPath:fullLocalFileName])
        {
            DLog(@"Gonna deploy a file to: %@", fullLocalFileName);
            
            NSString *defaultStorePath = [[NSBundle mainBundle] 
                                          pathForResource:[Sound convertedDeloymentSoundIdForId:[NSString stringWithFormat:@"%d", i]] ofType:[Sound otamataSerializedFileExtension]];
            if (defaultStorePath) 
            {
                [fileManager copyItemAtPath:defaultStorePath toPath:fullLocalFileName error:NULL];
                
                //
                // Set the "do not backup" attribute so Apple won't complain about too many files in the /docs directory
                //
                [GlobalFunctions addSkipBackupAttributeToItemAtFilePath:fullLocalFileName];
            }
        }
        else
        {
            // DLog(@"Already have file: %@", fullLocalFileName);
        }
    }
}

//
// Used during dev only.  Take a sound file from the server and save it as a deployment sound.
//
+(void) setSoundAsDeploymentVersion:(Sound *)sound
{
    if (sound.isDeploymentSound)
    {
        //
        // Alert box for the user - no workie
        //
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No Workie" message:[NSString stringWithFormat:@"Sound \"%@\" is already a deployment file.", sound.soundId] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        
        [alert show];
    }
    else
    {
        //
        // Save the current local file name so that we can delete it later.
        //
        NSString *currentFileName = [self fullLocalFilenameFromFilename:[sound localSerializedDataFileName]];
        int nextIndex = 0;
        
        for (Sound *aSound in [SoundManager getLocalSounds])
        {
            if (aSound.isDeploymentSound)
            {
                nextIndex = MAX(nextIndex, aSound.deploymentSoundIdInt);
            }
        }
        
        nextIndex++;
        
        NSString *newSoundId = [Sound convertedDeloymentSoundIdForId:[NSString stringWithFormat:@"%d", nextIndex]];
        
        sound.soundId = newSoundId;
        [self serializeSound:sound];
        
        DLog(@"Created deployment sound: %@", [self fullLocalFilenameFromFilename:[Sound localSerializedDataFileName:newSoundId]]);
        
        NSError *error;
        NSFileManager *filemgr =[NSFileManager defaultManager];

        DLog(@"Gonna delete: %@", currentFileName);
        
        BOOL res = [filemgr removeItemAtPath:currentFileName error:&error];
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Finished" message:[NSString stringWithFormat:@"Result was: %d.  Be sure to mark this as disabled in the DB.", res] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
        
        DLog(@"Remove sound attempt, result was: %d", res);
    }    
}

//
// Return the next available numeric id for a user sound, 1-based
//
+(int) nextUserSoundIntIdFromSounds:(NSMutableArray *)soundList
{
    int nextIndex = 0;
    for (Sound *aSound in soundList)
    {
        if (aSound.isUserSound)
        {
            nextIndex = MAX(nextIndex, aSound.userSoundIdInt);
        }
    }
    
    nextIndex++;

    return nextIndex;
}

//
// Get all the local sounds (on system either active or hidden) and see if the id (server id) matches.  This is 
// useful for determining if a user-created sound matches a sound we just found on the server.
//
+(BOOL) serverSoundIsAlreadyLocal:(Sound *)serverSound
{
    return [self soundHaveServerId:serverSound inList:
            [SoundManager getLocalSoundsOfStatuses:[NSArray arrayWithObjects:
                                                    [NSNumber numberWithInt:sscActive],
                                                    [NSNumber numberWithInt:sscHidden],
                                                    nil]
             ]];
}

//
// See if the id (server id) matches the server id of any of the sounds in the passed list
//
+(BOOL) soundHaveServerId:(Sound *)serverSound inList:(NSMutableArray *)soundsToCheck
{
    BOOL result = NO;
    
    for (Sound *aSound in soundsToCheck)
    {
        if ([[aSound getServerSoundId] isEqualToString:serverSound.soundId])
        {
            result = YES;
            break;
        }
    }

    return result;
}

+(BOOL) canPurchase:(Sound *)serverSound withReasonIfNo:(NSString **)reason
{
    BOOL result = NO;    
    
    //
    // Todo: refactor code to determine if sound is hidden or active, and return 
    // a better reason description.  Perhaps even the hidden sound object so it can be
    // restored easily.
    //
    if ([SoundManager serverSoundIsAlreadyLocal:serverSound])
    {
        *reason = @"The sound is already on your device.";
    }
    else
    {
        result = YES;
    }
    
    return result;
}

+(Sound *)getEmptySound
{
    Sound *result = [[[Sound alloc] init] autorelease];
    
    //
    // Set the "1" built-in sound as the default icon
    //
    result.iconSrcType = istAppDefault;
    result.iconAppDefaultId = 1;
    
    return result;
}

+(NSString *)dummyFilename:(SoundFormat)format
{
    NSString *result;
    
    switch (format) {
        case sfMp3:
            result = @"usersound.mp3";
            break;
            
        case sfWav:
            result = @"usersound.wav";
            break;
            
        default:
            [NSException raise:@"Can't make filename" format:@"Unknown format: %d", format];
            break;
    }
    
    return result;
}

//
// Save the passed sound and fields to the system.  The sound id is filled in with
// the new id.
//
+(BOOL) saveNewUserSound:(Sound *)userSound name:(NSString *)name description:(NSString *)desc data:(NSData *)soundData icon:(NSData *)iconData origination:(SoundOriginationCode)orgCode filename:(NSString *)filename
{
    //
    // Save that bad boy
    //
    NSMutableArray *allCurrentSounds = [SoundManager getLocalSounds];
    int nextAvailUserId = [SoundManager nextUserSoundIntIdFromSounds:allCurrentSounds];
    
    userSound.soundId = [Sound convertedUserSoundIdForId:[NSString stringWithFormat:@"%d", nextAvailUserId]];
    userSound.name = name;
    userSound.soundDescription = desc;
    userSound.filename = filename;
    userSound.soundData = soundData;
    
    userSound.size =  userSound.soundData.length;
    userSound.imageData = iconData;
    userSound.hasIcon = [userSound hasIconData];
    userSound.status = sscActive;
    userSound.soundOriginationCode = orgCode;
    
    [SoundManager serializeSound:userSound];
    
    return YES;
}

@end
