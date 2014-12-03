//
//  Config.m
//  OttaMatta
//
//  Created by John Baumbach on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Config.h"
#import "KeychainItemWrapper.h"
#import "GlobalFunctions.h"
#import "JSONKit.h"

@implementation Config

+(NSString *) apiUserName
{
    return @"iosDeviceUser";
}

+(NSString *) apiPW
{
    //
    // This at least breaks up the password so prying eyes with hex editors can't see it plain 
    // as day.
    //
    return [NSString stringWithFormat:@"%@%@%@", pwPasswordPart1, pwPasswordPart2, pwPasswordPart3];
}

+(NSString *) remoteHost
{
    int userServerPreference = [self getUserServerPreference];
    
    //
    // Safety feature: always point to production if we're doing a non-dev build, 
    // regardless of what this setting was last set to.
    // 
#ifndef DEV_VERSION
    userServerPreference = PROD_REMOTE_HOST_IDX;
#endif
    
    switch (userServerPreference) 
    {
        case DEV_REMOTE_HOST_IDX:
            return DEV_REMOTE_HOST;
        default:
            return PROD_REMOTE_HOST;
    }
}

+(NSString *) dataTransferFormat
{
    return @"json";
}

+(NSString *) soundSearchUrlForTerm:(NSString *)term withOrder:(SoundSearchOrder)order includeInappropriate:(BOOL)includeAppr
{
    /* For some reason, adding the UUID and app version makes this call take 30+ seconds to return.  It makes NO sense!
     
    return [NSString stringWithFormat:@"http://%@/services/soundssummary/%@?%@=%@&%@=%d&%@=%d&%@=%@&%@=%@", [self remoteHost], [self dataTransferFormat], 
            qsTerm, term, 
            qsOrder, order, 
            qsIncappr, includeAppr ? 1 : 0,
            qsDeviceId, [Config getUUID],
            qsAppVersion, [GlobalFunctions appPublicVersion] ];
        */

    return [NSString stringWithFormat:@"http://%@/services/soundssummary/%@?%@=%@&%@=%d&%@=%d", [self remoteHost], [self dataTransferFormat], 
            qsTerm, [GlobalFunctions urlEncodedString:term], 
            qsOrder, order, 
            qsIncappr, includeAppr ? 1 : 0 ];

}

+(NSString *) websoundSearchUrlForTerm:(NSString *)term
{
    return [NSString stringWithFormat:@"http://%@/services/websearch/%@?%@=%@", [self remoteHost], [self dataTransferFormat], qsTerm, [GlobalFunctions urlEncodedString:term]];
}

+(NSString *) soundDetailUrlForId:(NSString *)soundId
{
    return [NSString stringWithFormat:@"http://%@/services/sounddata/%@/%@", [self remoteHost], [self dataTransferFormat], soundId];
}

+(NSString *) websoundDetailUrlForTerm:(NSString *)term andId:(NSString *)soundId
{
    return [NSString stringWithFormat:@"http://%@/services/websearchsound/%@?%@=%@&%@=%@", [self remoteHost], [self dataTransferFormat], qsTerm, [GlobalFunctions urlEncodedString:term], qsSoundId, soundId];
}

+(NSString *) webImageSearchUrlForTerm:(NSString *)term
{
    return [NSString stringWithFormat:@"http://%@/services/webimagesearch/%@?%@=%@", [self remoteHost], [self dataTransferFormat], qsTerm, [GlobalFunctions urlEncodedString:term]];
}

+(NSString *) soundIconUrlForId:(NSString *)soundId
{
    return [NSString stringWithFormat:@"http://%@/services/soundicon/%@/%@", [self remoteHost], [self dataTransferFormat], soundId];
}

+(NSString *) rateSoundUrl
{
    return [NSString stringWithFormat:@"http://%@/services/ratesound/%@", [self remoteHost], [self dataTransferFormat]];
}

+(NSString *) uploadSoundUrl
{
    return [NSString stringWithFormat:@"http://%@/services/uploadsound/%@", [self remoteHost], [self dataTransferFormat]];
}

+(NSString *) markInappropriateUrl
{
    return [NSString stringWithFormat:@"http://%@/services/markinappropriate/%@", [self remoteHost], [self dataTransferFormat]];
}

+(NSString *) purchaseSoundUrl
{
    return [NSString stringWithFormat:@"http://%@/services/purchase/%@", [self remoteHost], [self dataTransferFormat]];
}

+(NSString *) recordPurchaseUrl
{
    return [NSString stringWithFormat:@"http://%@/services/recordpurchase/%@", [self remoteHost], [self dataTransferFormat]];
}

+(NSString *) websiteHomepageUrl
{
    return [NSString stringWithFormat:@"http://%@", [self remoteHost]];
}

+(NSString *) websiteTermsAndConditionsUrl
{
    return [NSString stringWithFormat:@"http://%@/termsandconditions", [self remoteHost]];
}

+(NSString *) encryptedSoundId:(NSString *)soundId playerVersion:(SoundPlayerVersion)version displayType:(SoundShareType)displayType
{
    NSString *result = nil;
    
    if (version == spvVersion1)
    {
        if (![soundId isNumeric])
        {
            [NSException raise:@"Invalid sound id" format:@"The value %@ is invalid as a server sound id - not numeric", soundId];
        }
        
        /*
         /player/([sound number digit as letter][random letter])*[player version as letter (a=0, b=2, etc.)][random letter][display type as letter]
         
         Example
         
         player version = 1
         display type = 0
         sound number = 23
         
         /player/b6cPbWa
         */
        
        NSString *encryptedSoundId = [NSString stringWithFormat:@""];
        
        int lowerCaseaInAscii = 97;
        int upperCaseAInAscii = 65;
        int soundIdLen = soundId.length;
        
        srandomdev();
        
        for (int i = 0; i < soundIdLen; i++)
        {
            int digit = [soundId characterAtIndex:i] - '0';
            
            encryptedSoundId = [NSString stringWithFormat:@"%@%c%c", encryptedSoundId, lowerCaseaInAscii + digit, random() % 26 + upperCaseAInAscii];
        }
        
        encryptedSoundId = [NSString stringWithFormat:@"%@%c%c%c", encryptedSoundId, lowerCaseaInAscii + version, random() % 26 + upperCaseAInAscii, lowerCaseaInAscii + displayType];
     
        result = encryptedSoundId;
    }
    else
    {
        [NSException raise:@"Invalid sound player version" format:@"The value %d is invalid.", version];
    }

    return result;
}

//
// Build a url to the otamata sound player.
//
+(NSString *) soundPlayerIconUrl:(NSString *)soundId playerVersion:(SoundPlayerVersion)version displayType:(SoundShareType)displayType
{
    return [NSString stringWithFormat:@"http://%@/handlers/getsoundicon.ashx?soundid=%@", [self remoteHost], [self encryptedSoundId:soundId playerVersion:version displayType:displayType]];
}


//
// Build a url to the otamata sound player.
//
+(NSString *) soundPlayerUrl:(NSString *)soundId playerVersion:(SoundPlayerVersion)version displayType:(SoundShareType)displayType
{
    return [NSString stringWithFormat:@"http://%@/player/%@", [self remoteHost], [self encryptedSoundId:soundId playerVersion:version displayType:displayType]];
}

+(NSString *) genericSoundUrl
{
    return [NSString stringWithFormat:@"http://%@/%@", [self remoteHost], GENERIC_SOUND_IMG_RND];
}

+(NSSet *) productList
{
    return [NSSet setWithObjects:
            [GlobalFunctions appProductId:kRemoveAllAds],
            nil];
}

#pragma mark - Overly verbose user value functions

//
// Todo: refactor this code to use some common functions
//
+(void) setUserValue:(id)value forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    [userDefaults synchronize];
}

+(BOOL) getInappropriateContent
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults stringForKey:udInappropriateContent];
    if (result == nil)
    {
        result = @"0";
    }
    return [result boolValue];
}

+(void) setInappropriateContent:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:udInappropriateContent];
    [userDefaults synchronize];
}

+(BOOL) getVolumeShouldBeFull
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults stringForKey:udVolumeToFull];
    if (result == nil)
    {
        result = @"0";
    }
    return [result boolValue];
}

+(void) setVolumeShouldBeFull:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:udVolumeToFull];
    [userDefaults synchronize];
}


//
// Defaults to 0 (production).  1 is development
//
+(NSInteger) getUserServerPreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger result = [userDefaults integerForKey:udServerPreference];
    return result;
    
}

+(void) setUserServerPreference:(NSInteger)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:udServerPreference];
    [userDefaults synchronize];
}

+(NSInteger) getUserCredits
{
    NSString * result;
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kcUserCredits accessGroup:nil];
    result = (NSString *)[keychain objectForKey:(id)kSecAttrComment];
    [keychain release];
    
    if (result == nil)
    {
        result = @"10";
    }
    return [result integerValue];
}

+(void) setUserCredits:(NSInteger)value
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kcUserCredits accessGroup:nil];
    [keychain setObject:[NSString stringWithFormat:@"%d", value] forKey:(id)kSecAttrComment];
    [keychain release];

}

+(NSString *) getKeychainSharedString
{
    NSString * result;
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kcUUID accessGroup:nil];
    result = (NSString *)[keychain objectForKey:(id)kSecAttrDescription];
    [keychain release];
    return result;
}

+(void) setKeychainSharedString:(NSString *)value
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kcUUID accessGroup:nil];
    [keychain setObject:value forKey:(id)kSecAttrDescription];
    [keychain release];
}

+(NSString *) getSecureKey:(NSString *)key
{
    NSString *sharedString = [self getKeychainSharedString];
    NSDictionary *allVals = [sharedString objectFromJSONString];
    return [allVals objectForKey:key]; 
}

+(void) setSecureKey:(NSString *)key toValue:(NSString *)value
{
    NSString *sharedString = [self getKeychainSharedString];
    NSMutableDictionary *allVals = [sharedString mutableObjectFromJSONString];
    if (allVals == nil)
    {
        allVals = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    [allVals setObject:value forKey:key];
    NSString *newStringToSet = [allVals JSONString];
    [self setKeychainSharedString:newStringToSet];
}

+(void) clearAllSecureKeys
{
#ifdef DEV_VERSION
    DLog(@"** warning!!! clearing all secure keys.  This should only be done in dev! **");
    [self setKeychainSharedString:@""];
#else
    DLog(@"Not clearing keys!  Not dev version!");
#endif
}

+(BOOL) getEnableWebsearchDownloads
{
    NSString *res = [self getSecureKey:kcEnableWebsearchDls];
    
    int keyval = 0;
    
    if (res != nil)
    {
        keyval = [res intValue];
    }
    
    return keyval == 1;
}

+(void) setEnableWebsearchDownloads:(BOOL)value
{
    [self setSecureKey:kcEnableWebsearchDls toValue:(value ? @"1" : @"0")];
}

+(BOOL) getRemoveAds
{
    NSString *res = [self getSecureKey:kcRemoveAds];
    return [res intValue] == 1;
}

+(void) setRemoveAds:(BOOL)value
{
    [self setSecureKey:kcRemoveAds toValue:(value ? @"1" : @"0")];
}

+(float) getUserVolume
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults stringForKey:uiUserVolume];
    if (result == nil)
    {
        result = @"0.75";
    }
    return [result floatValue];
}
+(void) setUserVolume:(float)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:value forKey:uiUserVolume];
    [userDefaults synchronize];
}

+(NSString *) getUUIDKChain
{
    NSString * result;
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kcUUID accessGroup:nil];
    result = (NSString *)[keychain objectForKey:(id)kSecAttrAccount];
    [keychain release];
    
    return result;
}

+(void) setUUIDKChain:(NSString *)uuid
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kcUUID accessGroup:nil];
    [keychain setObject:uuid forKey:(id)kSecAttrAccount];
    [keychain release];
}

+(NSString *) getUUID
{
    /* We're not storing the UUID in the user defaults, it's too easy to
     hack
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:udUUID];
     */
    
    return [self getUUIDKChain];
}

+(void) setUUID:(NSString *)uuid
{
    /*
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:uuid forKey:udUUID];
    [userDefaults synchronize];
     */
    
    [self setUUIDKChain:uuid];
}

+(BOOL) getIsFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults stringForKey:udIsFirstRun];
    if (result == nil)
    {
        result = @"1";
    }
    return [result intValue] == 1;
}

+(void) setIsFirstRun:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSString stringWithFormat:@"%d", value ? 1 : 0] forKey:udIsFirstRun];
    [userDefaults synchronize];
}

+(NSString *) getUserName
{
    return [GlobalFunctions getUserDefault:udUserName];
}

+(void) setUserName:(NSString *)userName
{
    [GlobalFunctions setUserDefault:udUserName toValue:userName];
}
@end
