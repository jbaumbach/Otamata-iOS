//
//  StoreTableViewCell.h
//  OttaMatta
//
//  Created by John Baumbach on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIBTableViewCell.h"

@interface StoreTableViewCell : NIBTableViewCell

@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UILabel *longDescriptionLabel;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;
- (IBAction)buyButtonClicked:(id)sender;

@end
