//
//  SoundInfoControl.m
//  Otamata
//
//  Created by John Baumbach on 6/3/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "SoundInfoControl.h"
#import "GlobalFunctions.h"
#import "SoundPlayer.h"

@implementation SoundInfoControl
@synthesize icon;
@synthesize nameLabel;
@synthesize descriptionLabel;
@synthesize sound;

- (id)initWithFrame:(CGRect)frame
{
    DLog(@"SoundInfoControl:initWithFrame");
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    DLog(@"SoundInfoControl:initWithCoder");
    
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }

    //
    // Causes exception
    //
    // self = [GlobalFunctions initClassFromNib:[SoundInfoControl class]];
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [icon release];
    [nameLabel release];
    [descriptionLabel release];
    [sound release];
    
    [super dealloc];
}

//
// Manually implement setter here because we wanna do more stuff when 
// the sound property is assigned to.
//
-(void)setSound:(Sound *)newSound
{
    icon.theSound = newSound;
    nameLabel.text = newSound.name;
    descriptionLabel.text = newSound.soundDescription;
    
    [sound release];
    sound = [newSound retain];
    
    icon.delegate = self;
}

#pragma mark - SoundIconViewProtocol implementation

- (void) pressedForSound:(Sound *)theSound
{
    [SoundPlayer playSoundFromData:theSound.soundData];
}


@end
