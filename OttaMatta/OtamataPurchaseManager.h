//
//  OtamataPurchaseManager.h
//  OttaMatta
//
//  Created by John Baumbach on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//
// Instructions for purchasing development are in StoreController.m
//


#import <Foundation/Foundation.h>
#import "StoreController.h"
#import "RecordStorePurchase.h"

@interface OtamataPurchaseManager : NSObject
    <PurchaseControllerProtocol, 
    SendDialogViewComplete>

@property (nonatomic, retain) RecordStorePurchase *recorder;

@end
