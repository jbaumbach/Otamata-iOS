//
//  SoundDetailViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundIconView.h"
#import "SendingDialogView.h"
#import "ColorfulButton.h"
#import "SoundPlayer.h"

//
// Keys for multiple view dialogs
//
#define vwdPurchase @"purchase"

//
// Labels
//
#define btlTextLoading  @"Loading..."

@interface SoundDetailViewController : UIViewController
    <SendDialogViewComplete,
    UIAlertViewDelegate, 
    SoundIconViewProtocol>
{
    NSInteger _userCredits;
    NSString *_playButtonText;
}

//
// UI elements
//
@property (retain, nonatomic) IBOutlet UILabel *soundNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *soundDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *uploadByLabel;
@property (retain, nonatomic) IBOutlet UILabel *creditsAvailDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *creditsAvailLabel;
@property (retain, nonatomic) IBOutlet SoundIconView *soundIcon;
@property (retain, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (retain, nonatomic) IBOutlet ColorfulButton *playButton;
@property (retain, nonatomic) IBOutlet ColorfulButton *getCreditsButton;

//
// Instance properties
//
@property (retain, nonatomic) Sound *sound;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) id helperController;
@property (nonatomic, retain) SoundPlayer *player;

//
// User actions
//
- (IBAction)playClicked:(id)sender;
- (IBAction)purchaseClicked:(id)sender;
- (IBAction)getCreditsButtonClicked:(id)sender;
- (IBAction)inappropriateClicked:(id)sender;

//
// Instance methods
//
-(void) soundDownloadComplete:(BOOL)success;
-(void) setScreenFieldsFromSound;
-(void) updateCreditsAvailableLabel;
-(void) startSoundDownload;


@end
