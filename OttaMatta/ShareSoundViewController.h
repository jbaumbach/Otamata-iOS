//
//  ShareSoundViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/29/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleObjectSelectionViewController.h"
#import "ShareSoundHelperController.h"

typedef enum
{
    sssShareMethod,
    sssSoundType,
    ShareSoundSettingsCount
} ShareSoundSetting;



@interface ShareSoundViewController : UIViewController
    <UITableViewDelegate, 
    UITableViewDataSource,
    SimpleObjectSelectionProtocol,
    ShareSoundProtocol>
{
}

@property (nonatomic, retain) NSArray *tableSectionHeadings;
@property (nonatomic, retain) NSArray *shareTypes;
@property (nonatomic, retain) NSArray *shareMethods;
@property (nonatomic, retain) ShareSoundConfig *shareConfig;
@property (nonatomic, retain) ShareSoundHelperController *helperController;


@property (retain, nonatomic) UIView *tableBackgroundSelectedView;

@property (retain, nonatomic) IBOutlet UITableView *actionsTableView;
- (IBAction)nextClicked:(id)sender;
@end
