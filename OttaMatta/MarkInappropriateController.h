//
//  MarkInappropriateController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendingDialogView.h"
#import "Sound.h"


@interface MarkInappropriateController : NSObject
    <UIAlertViewDelegate, 
    SendDialogViewComplete>
{
}

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) Sound *sound;
@property (nonatomic, retain) id<SendDialogViewComplete> delegate;

-(id)initWithSound:(Sound *)theSound andView:(UIView *)view withDelegate:(id<SendDialogViewComplete>)theDelegate;
-(void)markSoundAsInappropriate;


@end
