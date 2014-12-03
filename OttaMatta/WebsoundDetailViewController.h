//
//  WebsoundDetailViewController.h
//  Otamata
//
//  Created by John Baumbach on 7/8/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorfulButton.h"
#import "SoundIconView.h"
#import "WebsearchSound.h"
#import "ImageSelector.h"
#import "SoundPlayer.h"

//
// IDs of various alertview(s)
//
typedef enum
{
    wsdvcSaveWithoutIcon = 1
} WebsoundDetailViewcontrollerAlertTag;


@interface WebsoundDetailViewController : UIViewController
    <UITextFieldDelegate,
    UIAlertViewDelegate,
    SoundIconViewProtocol,
    ImageSelectorProtocol,
    UIScrollViewDelegate>
{
    NSInteger _userCredits;
    NSString *_playButtonText;
    UIControl *_activeField;
    BOOL _playedSound;
    BOOL _playedSoundSuccessfully;
    
}

//
// UI Elements
//
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *soundNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *downloadingLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (retain, nonatomic) IBOutlet ColorfulButton *playButton;
@property (retain, nonatomic) IBOutlet UILabel *sourceWebsiteLabel;
@property (retain, nonatomic) IBOutlet UITextField *soundNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *soundDescriptionTextField;
@property (retain, nonatomic) IBOutlet SoundIconView *soundIcon;
@property (retain, nonatomic) IBOutlet UILabel *creditsAvailLabel;


//
// Member variables
//
@property (nonatomic, retain) WebsearchSound *webSound;
@property (nonatomic, retain) Sound *localSound;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *searchTerm;
@property (nonatomic, retain) ImageSelector *imageSelection;
@property (nonatomic, retain) SoundPlayer *player;

//
// UI User Actions
// 
- (IBAction)playClicked:(id)sender;
- (IBAction)chooseIconClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (IBAction)getCreditsButton:(id)sender;
- (void) sourceUrlLinkClicked:(UIGestureRecognizer *)gestureRecognizer;

//
// Instance methods
//
-(void) saveSoundAndExit;
-(void) startSoundDownload;
-(void) soundDownloadComplete:(BOOL)success;
-(void) setScreenFieldsFromSound;
-(void) updateCreditsAvailableLabel;
-(void) setDownloadStatusLabel;
-(void)registerForKeyboardNotifications;
-(BOOL) validateFormFields:(NSString **)messageIfFail;
-(void) hideKeyboard;
@end
