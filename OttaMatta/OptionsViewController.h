//
//  OptionsViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

typedef enum
{
    trtInappropriate,
    trtGetCredits,
    trtUploadSounds,
    trtRestoreTrash,
    trtVolumeToFull,
    trtHelp,
    trtShowIntroScreens,
    trtAbout,
#ifdef DEV_VERSION
    trtServerType,
#endif
    TotalValuesInTable
} TableRowType;

@interface OptionsViewController : UIViewController
    <UITableViewDataSource,
    UITableViewDelegate>
{

}

@property (retain, nonatomic) IBOutlet UITableView *mainTableView;
@property (retain, nonatomic) UIView *tableBackgroundSelectedView;
@end
