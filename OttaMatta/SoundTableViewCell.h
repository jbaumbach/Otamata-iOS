//
//  SoundTableViewCell.h
//  OttaMatta
//
//  Created by John Baumbach on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundIconView.h"
#import "RateView.h"
#import "NIBTableViewCell.h"

@interface SoundTableViewCell : NIBTableViewCell
{
}
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *uploadedByLabel;
@property (retain, nonatomic) IBOutlet SoundIconView *iconView;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet RateView *ratingView;
@property (retain, nonatomic) IBOutlet UILabel *downloadsLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (retain, nonatomic) IBOutlet UILabel *notYetRatedLabel;

@end

