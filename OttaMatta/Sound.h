//
//  Sound.h
//  OttaMatta
//
//  Created by John Baumbach on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 How to add new properties to this class
 ---------------------------------------
 
 1. Add the property to the declaration area below.
 2. Add synthesize statement to the .m
 3. Add the decode statement to the initWithCoder function.
 4. Add the dictionary statement to the initWithDictionary function.
 5. If it's an object, add it to the dealloc function.
 6. Add the encoding support in the encodeWithCoder function.
 7. Increment the program version below if it's a breaking change.

 Program Version History
 -----------------------
 
 1  12/1/2011   Had properties soundId through displayOrder
 2  1/8/2011    Added uploadDate field
 
 */


#define PROGRAM_VERSION  2


#define DEPLOYMENT_SOUND_PREFIX @"deploy"
#define DEPLOYMENT_SOUND_DELIM  @"-"
#define USER_SOUND_PREFIX       @"user"
#define USER_SOUND_DELIM        @"-"


//
// Hard-coded int values because these values are persisted in the data file
// and can't change.
//
typedef enum 
{
    sscPreview = 0,
    sscActive = 1,
    sscHidden = 2
}
SoundStatusCode;

typedef enum
{
    istLocalData,
    istAppDefault,
    istUserChosen
}
IconSourceType;

//
// todo: clean up some technical debt by setting this for all sounds onload,
// and refactoring all the various methods to use it (and unit test it all).
// Do not add codes for types already in production without doing so.  Only
// add new ones moving forward.  All others should be "NotSet".
//
typedef enum
{
    socNotSet = 0,
    socWebDownload = 1
} 
SoundOriginationCode;

//
// Useful for telling the server what type of sound it is
//
typedef enum 
{
    sfWav = 0,
    sfMp3 = 1
}
SoundFormat;

@interface Sound : NSObject <NSCoding>
{
}

#pragma mark - Properties

//
// 2012/04/21 JB: note - the server considers the soundId an int.  When d/l'd from the
// server, the JSON will have it as an int and it'll get serialized to disk as an NSInteger.
// NSString will appear to work in most cases, but be careful.  We need it to be a string
// because the deploy sounds have "deploy" as a prefix to the id.  That prolly wasn't
// the best idea.  I should have used a "deploy" status or something.
//
@property (nonatomic, retain) NSString *soundId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *soundDescription;
@property (nonatomic, retain) NSString *uploadedBy;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *md5hash;
@property int downloads;
@property float averageRating;
@property long size;
@property (nonatomic, retain) NSData *soundData;
@property (nonatomic, retain) NSData *imageData;
@property SoundStatusCode status;
@property int programVersion;
@property int soundAbuseCount;
@property int displayOrder;
@property (nonatomic, retain) NSDate *uploadDate;
@property IconSourceType iconSrcType;
@property int iconAppDefaultId;
@property (nonatomic, retain) NSString *iconUserChosenUri;
@property int hasIcon;
@property int serverSndId;
@property SoundOriginationCode soundOriginationCode;

#pragma mark - Methods

-(NSString *)localFileName;
-(NSString *)localSerializedDataFileName;
-(BOOL) shouldDownloadIcon;
-(NSData *) getIconData;

-(BOOL) hasSoundData;
-(BOOL) hasIconData;
-(BOOL) isDeploymentSound;
-(BOOL) isUserSound;
-(BOOL) originatedOnServer;
-(int) deploymentSoundIdInt;
-(int) userSoundIdInt;
-(NSString *) getServerSoundId;

-(BOOL) isOnServer;
-(BOOL) canUploadToServer;
-(BOOL) canShareSound:(out NSString **)messageIfFail;

-(int)numericIdFromSoundIdWithPrefix:(NSString *)prefix andDelim:(NSString *)delimiter;
+(NSString *) convertedDeloymentSoundIdForId:(NSString *)soundId;
+(NSString *) convertedUserSoundIdForId:(NSString *)soundId;
+(NSString *) getValFromDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;

#pragma mark - Constructors 

-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithDictionary:(NSDictionary *)dictionary;

#pragma mark - Static Methods

+(NSString *)localSerializedDataFileName:(NSString *)soundId;
+(NSString *)otamataSerializedFileExtension;


@end