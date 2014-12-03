//
//  NIBTableViewCell.m
//  Otamata
//
//  Created by John Baumbach on 2/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "NIBTableViewCell.h"

@implementation NIBTableViewCell
@synthesize reuseIdentifierSpecial;

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

- (NSString *)reuseIdentifier
{
    return reuseIdentifierSpecial;
}

- (void)dealloc {
    self.reuseIdentifierSpecial = nil;
    
    [super dealloc];
}

@end
