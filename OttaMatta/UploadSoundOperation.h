//
//  UploadSoundOperation.h
//  Otamata
//
//  Created by John Baumbach on 6/6/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "SendingDialogView.h"
#import "Sound.h"


@interface UploadSoundOperation : SendingDialogView
{
    NSInteger _serverResultHTTPStatusCode;
}

-(void) uploadSound:(Sound *)theSound isBrowsable:(BOOL)isBrowsable;

@end
