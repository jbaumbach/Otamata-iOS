//
//  VolumeTableViewCell.h
//  OttaMatta
//
//  Created by John Baumbach on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "NIBTableViewCell.h"

@interface VolumeTableViewCell : NIBTableViewCell

@property (retain, nonatomic) IBOutlet UISwitch *setVolSwitch;
@property (retain, nonatomic) IBOutlet UISlider *volumeSlider;

@end
