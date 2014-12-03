//
//  SoundPlayer.m
//  OttaMatta
//
//  Created by John Baumbach on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundPlayer.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import "GlobalFunctions.h"

@implementation SoundPlayer

@synthesize playedSuccessfully;
@synthesize isPlaying;

- (id)initWithDataAndPlay:(NSData *)soundData
{
    self = [super init];
    if (self) {
        _soundData = [soundData retain];
        isPlaying = NO;
        playedSuccessfully = [self playSound];
    }
    return self;
}

/*
-(void) cleanUp
{
    AudioServicesDisposeSystemSoundID(_audioEffect);
}
*/



-(void) dealloc
{
    //[self cleanUp];
    
    [_player release];
    [_soundData release];
    
    [super dealloc];
    
}

/*
//
// Original way to play a sound from the bundle
// 
-(void) playSoundWithName:(NSString *)fName andExtension:(NSString *) ext
{
    [self cleanUp];
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:fName ofType:ext];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &_audioEffect);
        
        DLog(@"Playing sound: %@", fName);
        AudioServicesPlaySystemSound(_audioEffect);
    }
    else
    {
        DLog(@"error, file not found: %@", path);
    }
}
*/


//
// Deprecated - has mem leak.  Used until version 1.2.
//
+(BOOL) playSoundFromData:(NSData *) soundData
{
    BOOL result = false;
    NSError *error;
    
    // 
    // Note: this throws exceptions, prolly a bug in apple code.  See link here:
    // http://stackoverflow.com/questions/6906930/avaudiorecorder-is-broken-on-ios-5
    //
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:soundData error:&error];
    
    if (error)
    {
        //
        // There's a possible leak here, see note below.
        //
        DLog(@"Had error! %@", error.localizedDescription);
    }
    else
    {
        //
        // Note: player volume can never go above device volume.  This can only DECREASE the volume.  Lame.
        //
        // http://stackoverflow.com/questions/3203526/volume-control-using-uislider-iphone
        //
        //player.volume = 1.0;
        result = [player play];
        DLog(@"play result: %d", result);
        
    }
    
    //
    // todo: clean up the leak here?  There's a callback we can use
    //
    // http://www.techotopia.com/index.php/Playing_Audio_on_an_iPhone_using_AVAudioPlayer_%28iOS_4%29#Controlling_and_Monitoring_Playback
    //
    
    return result;
    
}

-(void) stopSound
{
    isPlaying = NO;
    [_player stop];
}

-(BOOL) playSound
{
    BOOL result = false;
    NSError *error;
    
    // 
    // Note: this throws exceptions, prolly a bug in apple code.  See link here:
    // http://stackoverflow.com/questions/6906930/avaudiorecorder-is-broken-on-ios-5
    //
    
    [_player release];
    _player = [[AVAudioPlayer alloc] initWithData:_soundData error:&error];
    _player.delegate = self;
    
    if (error)
    {
        DLog(@"Had error! %@", error.localizedDescription);
    }
    else
    {
        //
        // Note: player volume can never go above device volume.  This can only DECREASE the volume.  Lame.
        //
        // http://stackoverflow.com/questions/3203526/volume-control-using-uislider-iphone
        //
        //player.volume = 1.0;
        isPlaying = YES;
        result = [_player play];
        DLog(@"play result: %d", result);
    }
    
    //
    // todo: clean up the leak here?  There's a callback we can use
    //
    // http://www.techotopia.com/index.php/Playing_Audio_on_an_iPhone_using_AVAudioPlayer_%28iOS_4%29#Controlling_and_Monitoring_Playback
    //
    
    return result;
    
}

#pragma - mark AVAudioPlayerDelegate implemenation

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    DLog(@"Player completed playing with success: %d", flag);
    isPlaying = NO;
}

@end

