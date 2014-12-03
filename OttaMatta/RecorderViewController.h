//
//  RecorderViewController.h
//  Otamata
//
//  Created by John Baumbach on 5/19/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundPlayer.h"
#import "SoundManager.h"
#import "SoundIconView.h"
#import "ColorfulButton.h"
#import "ImageSelector.h"

#define MAX_RECORDING_LENGTH_SECS   7


/*
 
 How to implement level meter:
 
 http://stackoverflow.com/questions/1508456/iphone-show-audio-record-feedback-using-avaudiorecorder
 
 
 How to set up AV thingy:
 
 http://stackoverflow.com/questions/9985683/ios-recording-audio-with-avaudiorecorder-fail-with-no-error
 
 */



@interface RecorderViewController : UIViewController
    <AVAudioRecorderDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate,
    UIActionSheetDelegate,
    UINavigationControllerDelegate,
    ImageSelectorProtocol,
    SoundIconViewProtocol>
{
    bool _haveSoundToPlay;
    
    UIControl *_activeField;
}

//
// UI Elements
//
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIProgressView *soundMeter;
@property (retain, nonatomic) IBOutlet UILabel *secondsLabel;
@property (retain, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (retain, nonatomic) IBOutlet UIButton *btnRecord;
@property (retain, nonatomic) IBOutlet UIButton *btnStop;
@property (retain, nonatomic) IBOutlet UIButton *btnPlay;
@property (retain, nonatomic) IBOutlet ColorfulButton *btnReset;
@property (retain, nonatomic) IBOutlet UITextField *soundNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *soundDescriptionTextField;
@property (retain, nonatomic) IBOutlet SoundIconView *soundIcon;
@property (retain, nonatomic) IBOutlet ColorfulButton *btnSaveSound;

//
// Instance properties
//
@property (retain, nonatomic) Sound *userSound;
@property (retain, nonatomic) AVAudioRecorder *recorder;
@property (retain, nonatomic) SoundPlayer *player;
@property (retain, nonatomic) NSDate *recordingStartTime;
@property (nonatomic, retain) ImageSelector *imageSelection;

//
// User actions
//
- (IBAction)recordClicked:(id)sender;
- (IBAction)stopClicked:(id)sender;
- (IBAction)playClicked:(id)sender;
- (IBAction)chooseIconClicked:(id)sender;
- (IBAction)resetClicked:(id)sender;
- (IBAction)saveSoundClicked:(id)sender;

//
// Instance methods
//
-(BOOL) validateFormFields:(NSString **)messageIfFail;
-(NSString *) tempSoundDataFName;
-(void) setupRecording;
-(void) updateMetering;
-(void) stopRecording;
-(void) setUISeconds:(NSNumber *)seconds;
-(void) resetAll;
-(void) setAppToPlaybackMode;
-(void) setButtonStates;
-(void) updateProgressBar:(NSNumber *)value;
- (void)registerForKeyboardNotifications;


@end
