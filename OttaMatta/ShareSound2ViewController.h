//
//  ShareSound2ViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/29/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedCornerView.h"
#import "ShareSoundHelperController.h"

@interface ShareSound2ViewController : UIViewController
    <ShareSoundProtocol>

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIView *mainContent;
@property (retain, nonatomic) IBOutlet RoundedCornerView *optionPlainView;
@property (retain, nonatomic) IBOutlet UIImageView *optionPlainImage;

@property (retain, nonatomic) IBOutlet RoundedCornerView *optionPlainWithLinkView;
@property (retain, nonatomic) IBOutlet UIImageView *optionPlainWithLinkImage;

@property (retain, nonatomic) IBOutlet RoundedCornerView *optionDetailsView;
@property (retain, nonatomic) IBOutlet UIImageView *optionDetailsGraphic;

@property (nonatomic, retain) ShareSoundConfig *shareConfig;
@property (nonatomic, retain) ShareSoundHelperController *helperController;

-(void) resetBackgrounds;
-(void) resetBackgroundsWithDelay:(float)delay;


@end
