//
//  ShareSound1ViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/30/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareSoundConfig.h"
#import "SoundInfoControl.h"

@interface ShareSound1ViewController : UIViewController
    <UITableViewDelegate,
    UITableViewDataSource>
{
}

@property (retain, nonatomic) IBOutlet UITableView *mainTable;
@property (retain, nonatomic) SoundInfoControl *soundInfoControl;
@property (retain, nonatomic) IBOutlet UIView *soundInfoHolder;

@property (retain, nonatomic) UIView *tableBackgroundSelectedView;

@property (nonatomic, retain) ShareSoundConfig *shareConfig;

@property (nonatomic) BOOL showSoundInfo;

//-(void) hideSoundInfoDisplay;

@end
