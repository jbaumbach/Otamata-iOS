//
//  OtamataSingleton.h
//  OttaMatta
//
//  Created by John Baumbach on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreController.h"
#import "FBConnect.h"
#import "ShareSoundConfig.h"

@interface OtamataSingleton : NSObject

+ (OtamataSingleton *)sharedOtamataSingleton;

@property float origUserVolume;
@property (nonatomic, retain) StoreController *store;

@end
