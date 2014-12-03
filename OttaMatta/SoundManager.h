//
//  SoundManager.h
//  OttaMatta
//
//  Created by John Baumbach on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sound.h"
#import "SendingDialogView.h"

@interface SoundManager : NSObject

+(BOOL) isSoundFile:(NSString *)filename;

+(NSString *) fullLocalFilenameFromFilename:(NSString *)filename;
+(Sound *) getLocalSoundFromId:(NSString *)soundId;
+(Sound *) getLocalSoundFromFilename:(NSString *)fileName;

+(NSMutableArray *) getLocalSounds;
+(NSMutableArray *) getLocalSoundsOfStatuses:(NSArray *)soundStatusCodes;
+(NSMutableArray *) getLocalSoundsOfStatus:(SoundStatusCode)statusCode;
+(BOOL) serializeSound:(Sound *)sound;
+(void) moveSoundToTrash:(Sound *)sound;
+(id) markSoundAsInappropriate:(Sound *)sound fromView:(UIView *)parentView withSendDialogViewCompleteDelegate:(id<SendDialogViewComplete>)delegate;
+(void) setLocalSoundStatus:(Sound *)sound toStatus:(SoundStatusCode)status;
+(void) userHasRatedSound:(Sound *)sound;
+(void) setSoundAsDeploymentVersion:(Sound *)sound;
+(void) deployDefaultSounds;
+(int) nextUserSoundIntIdFromSounds:(NSMutableArray *)soundList;
+(BOOL) serverSoundIsAlreadyLocal:(Sound *)serverSound;
+(BOOL) soundHaveServerId:(Sound *)serverSound inList:(NSMutableArray *)soundsToCheck;
+(BOOL) canPurchase:(Sound *)serverSound withReasonIfNo:(NSString **)reason;
+(Sound *) getEmptySound;
+(BOOL) saveNewUserSound:(Sound *)userSound name:(NSString *)name description:(NSString *)desc data:(NSData *)soundData icon:(NSData *)iconData origination:(SoundOriginationCode)orgCode filename:(NSString *)filename;
+(NSString *)dummyFilename:(SoundFormat)format;
@end
