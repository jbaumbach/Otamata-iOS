//
//  SoundTableViewCell.m
//  OttaMatta
//
//  Created by John Baumbach on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundTableViewCell.h"
#import "GlobalFunctions.h"

@implementation SoundTableViewCell
@synthesize nameLabel;
@synthesize uploadedByLabel;
@synthesize iconView;
@synthesize dateLabel;
@synthesize ratingView;
@synthesize downloadsLabel;
@synthesize loadingSpinner;
@synthesize notYetRatedLabel;

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
    [nameLabel release];
    [uploadedByLabel release];
    [iconView release];
    [dateLabel release];
    [ratingView release];
    [downloadsLabel release];
    [loadingSpinner release];
    [notYetRatedLabel release];
    //self.reuseIdentifierSpecial = nil;
    
    [super dealloc];
}
@end
