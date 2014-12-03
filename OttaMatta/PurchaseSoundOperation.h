//
//  PurchaseSoundOperation.h
//  OttaMatta
//
//  Created by John Baumbach on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendingDialogView.h"
#import "Sound.h"

@interface PurchaseSoundOperation : SendingDialogView

-(void) purchaseSound:(Sound *)theSound;

@end
