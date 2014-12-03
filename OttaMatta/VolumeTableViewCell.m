//
//  VolumeTableViewCell.m
//  OttaMatta
//
//  Created by John Baumbach on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VolumeTableViewCell.h"

@implementation VolumeTableViewCell
@synthesize setVolSwitch;
@synthesize volumeSlider;

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
    [setVolSwitch release];
    [volumeSlider release];
    [super dealloc];
}
- (IBAction)volumeChanged:(id)sender {
}
@end
