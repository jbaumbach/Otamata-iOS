//
//  Sound.m
//  OttaMatta
//
//  Created by John Baumbach on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Sound.h"

#import "GlobalFunctions.h"
#import "Config.h"

@implementation Sound

@synthesize soundId;
@synthesize name;
@synthesize soundDescription;
@synthesize uploadedBy;
@synthesize filename;
@synthesize md5hash;
@synthesize downloads;
@synthesize averageRating;
@synthesize size;
@synthesize soundData;
@synthesize imageData;
@synthesize status;
@synthesize programVersion;
@synthesize soundAbuseCount;
@synthesize displayOrder;
@synthesize uploadDate;
@synthesize iconSrcType;
@synthesize iconAppDefaultId;
@synthesize iconUserChosenUri;
@synthesize hasIcon;
@synthesize serverSndId;
@synthesize soundOriginationCode;

-(id)init
{
    //
    // Default constructor, initialize stuff here
    //
    if (self = [super init]) {
        self.serverSndId = -1;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)dictionary
{
    //
    // Deserialize from the passed data.  This dictionary was typically read from a serialized file.
    //
    if (self = [super init]) {
        //
        // 2012/04/21 JB: Convert any NSInteger sound ids to NSString
        //
        self.soundId = [NSString stringWithFormat:@"%@", [dictionary decodeObjectForKey:@"soundid"]];
        
        self.name = [dictionary decodeObjectForKey:@"name"];
        self.soundDescription = [dictionary decodeObjectForKey:@"description"];
        self.uploadedBy = [dictionary decodeObjectForKey:@"uploadedby"];
        self.filename = [dictionary decodeObjectForKey:@"filename"];
        self.md5hash = [dictionary decodeObjectForKey:@"md5hash"];
        self.downloads = [dictionary decodeIntForKey:@"downloads"];
        self.averageRating = [dictionary decodeFloatForKey:@"averagerating"];
        self.size = [dictionary decodeInt64ForKey:@"size"];
        self.soundData = [dictionary decodeObjectForKey:@"soundData"];
        self.imageData = [dictionary decodeObjectForKey:@"imagethumb"];
        self.status = [dictionary decodeIntForKey:@"status"];
        self.programVersion = [dictionary decodeIntForKey:@"programVersion"];
        self.soundAbuseCount = [dictionary decodeIntForKey:@"soundAbuseCount"];
        self.displayOrder = [dictionary decodeIntForKey:@"displayOrder"];
        self.uploadDate = [dictionary decodeObjectForKey:@"uploadDate"];
        
        self.iconSrcType = [dictionary decodeIntForKey:@"iconSrcType"];
        self.iconAppDefaultId = [dictionary decodeIntForKey:@"iconAppDefaultId"];
        self.iconUserChosenUri = [dictionary decodeObjectForKey:@"iconUserChosenUri"];
        self.hasIcon = [dictionary decodeIntForKey:@"hasIcon"];
        self.serverSndId = [dictionary decodeIntForKey:@"serverSndId"];
        self.soundOriginationCode = [dictionary decodeIntForKey:@"soundOriginationCode"];
    }
    
    return self;
}

+(NSString *) getValFromDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    NSString *val = [dictionary objectForKey:key];
    NSString *result = nil;
    
    if (val != nil)
    {
        //DLog(@"Success finding key '%@' in dictionary, result was: %@", key, val);
        
        //
        // 2012/04/21 JB: adding conversion of val to a string here
        //
        // was: result = val;       
        
        result = [NSString stringWithFormat:@"%@", val];
    }
    else
    {
        DLog(@"Failure finding key '%@' in dictionary", key);
    }
    
    return result;
    
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    //
    // Load object from a dictionary of values (typically loaded from JSON data).  Some of these will be null
    // since they come from the app.  They are included for completeness.
    //
    if (self = [super init]) {
         
        self.soundId = [Sound getValFromDictionary:dictionary forKey:@"soundid"];
        self.name = [Sound getValFromDictionary:dictionary forKey:@"name"];
        self.soundDescription = [Sound getValFromDictionary:dictionary forKey:@"description"];
        self.uploadedBy = [Sound getValFromDictionary:dictionary forKey:@"uploadedby"];
        self.filename = [Sound getValFromDictionary:dictionary forKey:@"filename"];
        self.md5hash = [dictionary objectForKey:@"md5hash"];
        self.downloads = [[dictionary objectForKey:@"downloads"] intValue];
        self.averageRating = [[dictionary objectForKey:@"averagerating"] floatValue];
        self.size = [[dictionary objectForKey:@"size"] longValue];
        self.soundData = [dictionary objectForKey:@"soundData"];
        self.imageData = [dictionary objectForKey:@"imagethumb"];
        self.status = (SoundStatusCode)[dictionary objectForKey:@"status"];
        self.programVersion = [[dictionary objectForKey:@"programVersion"] intValue];
        self.soundAbuseCount = [[dictionary objectForKey:@"soundAbuseCount"] intValue];
        self.displayOrder = [[dictionary objectForKey:@"displayOrder"] intValue];
        self.uploadDate = [NSDate parseRFC3339Date:[dictionary objectForKey:@"uploadDate"]];
        
        self.iconSrcType = (IconSourceType)[dictionary objectForKey:@"iconSrcType"];
        self.iconAppDefaultId = [[dictionary objectForKey:@"iconAppDefaultId"] intValue];
        self.iconUserChosenUri = [dictionary objectForKey:@"iconUserChosenUri"];
        self.hasIcon = [[dictionary objectForKey:@"hasicon"] intValue];
        self.serverSndId = [[dictionary objectForKey:@"serverSndId"] intValue];
        self.soundOriginationCode = [[dictionary objectForKey:@"soundOriginationCode"] intValue];
    }
    
    return self;
}

-(void) dealloc
{
    //
    // Set to nil all objects
    //
    self.soundId = nil;
    self.name = nil;
    self.soundDescription = nil;
    self.uploadedBy = nil;
    self.filename = nil;
    self.md5hash = nil;
    self.soundData = nil;
    self.imageData = nil;
    self.uploadDate = nil;
    
    self.iconUserChosenUri = nil;
    
    [super dealloc];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"(loc id: %@, svr: %d) '%@', '%@' (%ld bytes)", soundId, serverSndId, name, soundDescription, size];
}

//
// The original sound filename, converted to soundid.originalextension.
//
-(NSString *)localFileName
{
    return [NSString stringWithFormat:@"%@.%@", soundId, [filename pathExtension]];
}

-(NSString *)localSerializedDataFileName
{
    return [Sound localSerializedDataFileName:soundId];
}

+(NSString *)otamataSerializedFileExtension
{
    return @"otamata";
}

+(NSString *)localSerializedDataFileName:(NSString *)soundId
{
    return [NSString stringWithFormat:@"%@.%@", soundId, [Sound otamataSerializedFileExtension]];
}

-(BOOL) shouldDownloadIcon
{
    return self.iconSrcType == istLocalData && self.hasIcon && ![self.imageData isKindOfClass:[NSData class]];
}

-(NSData *) getIconData
{
    NSData *result = nil;
    NSString *defaultImageName = nil;
    
    switch (self.iconSrcType) {
            
        case istAppDefault:
            // get data for the image
            defaultImageName = [NSString stringWithFormat:@"default-icon%d", self.iconAppDefaultId];
            
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:defaultImageName ofType:@"png"];
            result = [NSData dataWithContentsOfFile:imagePath];
            break;
            
        case istLocalData:
            // return data for image
            result = self.imageData;
            break;
            
        case istUserChosen:
            // todo: get data for the uri
            break;
            
        default:
            DLog(@"Oops, unknown icon data source type");
            
            break;
    }
    
    return result;
}

-(BOOL) hasSoundData
{
    return [self.soundData isKindOfClass:[NSData class]];
}

-(BOOL) hasIconData
{
    return [self.imageData isKindOfClass:[NSData class]];
}


-(BOOL) isDeploymentSound
{
    return [self deploymentSoundIdInt] >= 0;
}

-(BOOL) isUserSound
{
    return [self userSoundIdInt] >= 0;
}

-(BOOL) originatedOnServer
{
    return [[self soundId] isNumeric];
}

-(int)numericIdFromSoundIdWithPrefix:(NSString *)prefix andDelim:(NSString *)delimiter
{
    int result = -1;
    
    NSString *currentSoundId = [NSString stringWithFormat:@"%@", self.soundId];
    
    NSArray *components = [currentSoundId componentsSeparatedByString:delimiter];
    if ([components count] == 2 && [(NSString *)[components objectAtIndex:0] isEqualToString:prefix])
    {
        result = [[components objectAtIndex:1] intValue];
    }
    
    return result;
}

//
// Return the local sound id if this is a deployment sound, otherwise -1
//
-(int) deploymentSoundIdInt
{
    return [self numericIdFromSoundIdWithPrefix:DEPLOYMENT_SOUND_PREFIX andDelim:DEPLOYMENT_SOUND_DELIM];
}

//
// Return the local sound id if this is a user sound, otherwise -1
//
-(int) userSoundIdInt
{
    return [self numericIdFromSoundIdWithPrefix:USER_SOUND_PREFIX andDelim:USER_SOUND_DELIM];
}

//
// Get the server's sound id.  Returns "-1" if none.
//
-(NSString *) getServerSoundId
{
    //
    // Future refactoring: make this a property of the sound object, not a method.
    // This will accomodate user-recorded and non-shared sounds
    //
    NSString *result;
    
    if ([self isDeploymentSound])
    {
        /*
         1 = Slow clap      = 53
         2 = Crickets       = 51
         3 = Falling bomb   = 49
         4 = Cat scream     = 50
         5 = Denied         = 52
         6 = Wah wah        = 54
         */
        int deploymentSoundId = [self deploymentSoundIdInt];
        NSArray *deploymentToServerIdMapping = [NSArray arrayWithObjects:@"53", @"51", @"49", @"50", @"52", @"54", nil];

        if (deploymentSoundId > deploymentToServerIdMapping.count)
        {
            [NSException raise:@"Extra deployment sound not implemented!" format:@"Expected %d but had %d.  Did you accidentally add a deployment sound?", deploymentToServerIdMapping.count, deploymentSoundId];
        }
        
        result = [deploymentToServerIdMapping objectAtIndex:deploymentSoundId - 1];
    }
    else if ([self isUserSound])
    {
        result = [NSString stringWithFormat:@"%d", self.serverSndId];
    }
    else
    {
        result = self.soundId;
    }
    
    return result;
}

-(BOOL) isOnServer
{
    int serverSoundId = [[self getServerSoundId] intValue];
    return serverSoundId > 0;
}

-(BOOL) canUploadToServer
{
    return ![self isOnServer] 
        && [self hasSoundData] 
        && [self isUserSound] 
        && (!self.soundOriginationCode == socWebDownload || 
            [self.soundData length] <= kMax_SoundFileLength);   
}

//
// Determine if the sound can be shared or not. 
//
-(BOOL) canShareSound:(NSString **)messageIfFail
{
    BOOL result = NO;
    
    if ([self isUserSound])
    {
        if (![self isOnServer])
        {
            //
            // Note: this should not happen normally.  The app should upload the sound before
            // calling this method, or explain to the user why it can't be uploaded. 
            //
            *messageIfFail = @"This sound is not present on the server.";
        }
        else
        {
            result = YES;
        }
    }
    else
    {
        result = YES;
    }
    
    return result;
}

//
// This returns a deployment soundId for the passed id, suitable for writing files during initial startup
//
+(NSString *) convertedDeloymentSoundIdForId:(NSString *)soundId
{
    return [NSString stringWithFormat:@"%@%@%@", DEPLOYMENT_SOUND_PREFIX, DEPLOYMENT_SOUND_DELIM, soundId];
}

+(NSString *) convertedUserSoundIdForId:(NSString *)soundId
{
    return [NSString stringWithFormat:@"%@%@%@", USER_SOUND_PREFIX, USER_SOUND_DELIM, soundId];
}

#pragma mark - Serialization

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //
    // Take all the properties and put them into the passed encode.  This is done right before
    // writing the encoded data to a storage medium (like a disk file).
    //
    [aCoder encodeObject:soundId forKey:@"soundid"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:soundDescription forKey:@"description"];
    [aCoder encodeObject:md5hash forKey:@"md5hash"];    
    [aCoder encodeObject:soundData forKey:@"soundData"];
    [aCoder encodeObject:imageData forKey:@"imagethumb"];
    [aCoder encodeInt:status forKey:@"status"];
    [aCoder encodeObject:uploadedBy forKey:@"uploadedby"];
    [aCoder encodeObject:filename forKey:@"filename"];
    [aCoder encodeInt:downloads forKey:@"downloads"];
    [aCoder encodeFloat:averageRating forKey:@"averagerating"];
    [aCoder encodeInt64:size forKey:@"size"];
    [aCoder encodeInt:programVersion forKey:@"programVersion"];
    [aCoder encodeInt:soundAbuseCount forKey:@"soundAbuseCount"];
    [aCoder encodeInt:displayOrder forKey:@"displayOrder"];
    [aCoder encodeObject:uploadDate forKey:@"uploadDate"];
    
    [aCoder encodeInt:iconSrcType forKey:@"iconSrcType"];
    [aCoder encodeInt:iconAppDefaultId forKey:@"iconAppDefaultId"];
    [aCoder encodeObject:iconUserChosenUri forKey:@"iconUserChosenUri"];
    [aCoder encodeInt:hasIcon forKey:@"hasIcon"];
    [aCoder encodeInt:serverSndId forKey:@"serverSndId"];
    [aCoder encodeInt:soundOriginationCode forKey:@"soundOriginationCode"];
}



@end
