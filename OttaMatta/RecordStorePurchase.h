//
//  RecordStorePurchase.h
//  OttaMatta
//
//  Created by John Baumbach on 2/2/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseServerOperation.h"

@interface RecordStorePurchase : BaseServerOperation

-(void) recordPurchase:(NSString *)purchaseId forUser:(NSString *)userId;


@end
