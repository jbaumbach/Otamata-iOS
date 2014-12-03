//
//  OtamataPurchaseManager.m
//  OttaMatta
//
//  Created by John Baumbach on 2/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtamataPurchaseManager.h"
#import "Config.h"

@implementation OtamataPurchaseManager
@synthesize recorder;

-(void) didPurchaseContentWithId:(NSString *)productId
{
    DLog(@"didPurchaseContentWithId: %@", productId);
    
    int newCredits = -1;

    if ([productId isEqualToString:[GlobalFunctions appProductId:kAddtlDwldsUnlimitedSub]])
    {
        newCredits = kUnlimitedCredits;
    }
    else if ([productId isEqualToString:[GlobalFunctions appProductId:kEnableWebsearchSaving]])
    {
        DLog(@"Todo: enable websearchsaving here");
        // [Config setEnableWebsearchDownloads:YES];
        
    }
    else if ([productId isEqualToString:[GlobalFunctions appProductId:kRemoveAllAds]])
    {
        DLog(@"'No ads' option purchased - setting config and posting notifications.");
        [Config setRemoveAds:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:gmiRemoveAllAds object:nil];
    }
    else
    {
        //
        // This is not good.
        //
    }
        
    if (newCredits > 0)
    {
        [Config setUserCredits:newCredits];
    }
}

//
// Tell server we got a receipt, and record it
// 
-(void) didGetTransactionReceipt:(SKPaymentTransaction *)transaction
{
    self.recorder = [[[RecordStorePurchase alloc] init] autorelease];
    [recorder recordPurchase:transaction.payment.productIdentifier forUser:[Config getUUID]];
}

-(BOOL) isRestorableProduct:(NSString *)productId
{
    return [productId isEqualToString:[GlobalFunctions appProductId:kAddtlDwldsUnlimitedSub]];
}

#pragma mark - SendDialogViewComplete implementation

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status
{
    self.recorder = nil;
    
}


@end
