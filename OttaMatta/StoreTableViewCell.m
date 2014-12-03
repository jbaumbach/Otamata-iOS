//
//  StoreTableViewCell.m
//  OttaMatta
//
//  Created by John Baumbach on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreTableViewCell.h"

@implementation StoreTableViewCell
@synthesize descriptionLabel;
@synthesize longDescriptionLabel;
@synthesize buyButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [descriptionLabel release];
    [longDescriptionLabel release];
    [buyButton release];
    [super dealloc];
}
- (IBAction)buyButtonClicked:(id)sender {
}
@end
