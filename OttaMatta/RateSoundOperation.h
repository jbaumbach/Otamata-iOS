//
//  RateSoundOperation.h
//  OttaMatta
//
//  Created by John Baumbach on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendingDialogView.h"
#import "Sound.h"

@interface RateSoundOperation : SendingDialogView

-(void) rateSound:(Sound *)theSound withRating:(int)rating userText:(NSString *)userText;
-(void) ratingCompleteWithStatus:(int)status;

@end
