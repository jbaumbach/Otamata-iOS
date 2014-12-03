//
//  ShareSound.h
//  Otamata
//
//  Created by John Baumbach on 4/30/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sound.h"
#import "Config.h"

//
// The order here must be the same as the array in the initer
//
typedef enum
{
    ssmSmsMessage,
    ssmEmail,
    ssmTweet,
    ssmFacebook,
    ssmPlainUrl,
    ssmSafariPreview
} SoundShareMethod;


@interface ShareSoundConfig : NSObject
{

}

@property (nonatomic, retain) NSArray *shareMethods;
@property (nonatomic, retain) NSArray *shareMethodIcons;
@property (nonatomic, retain) Sound *currentSound;

@property SoundShareType CurrentType;
@property SoundShareMethod CurrentMethod;


@end
