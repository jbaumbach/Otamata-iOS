//
//  SoundPlayer.h
//  OttaMatta
//
//  Created by John Baumbach on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlayer : NSObject
    <AVAudioPlayerDelegate>
{
    // SystemSoundID _audioEffect;
    AVAudioPlayer *_player;
    NSData *_soundData;
    //BOOL _isPlaying;
}

//-(void) playSoundWithName:(NSString *)fName andExtension:(NSString *) ext;
+(BOOL) playSoundFromData:(NSData *) soundData;

//
// Recommended play methods
//
- (id)initWithDataAndPlay:(NSData *)soundData;
- (BOOL) playSound;
- (void) stopSound;

//
// Instance properties
//
@property BOOL playedSuccessfully;
@property BOOL isPlaying;

@end
