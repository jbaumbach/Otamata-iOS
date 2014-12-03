//
//  StoreController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreController.h"
#import "GlobalFunctions.h"

@implementation StoreController

@synthesize productIdentifierList;
@synthesize productsDelegate;
@synthesize purchaseDelegate;
@synthesize trannyInfo;
@synthesize wasTrannySuccessful;

-(void) dealloc
{
    [super dealloc];

    self.productIdentifierList = nil;
    self.productsDelegate = nil;
    self.trannyInfo = nil;
}


+(BOOL) purchasingEnabled
{
    return [SKPaymentQueue canMakePayments];
}

- (void) requestProductData
{
    
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    //
    // Grab our product list from the iTunesConnect store. This object will be released in the callbacks.
    //
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifierList];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate implementation

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    DLog(@"Resp debug desc and desc: %@ and %@", response.debugDescription, response.description);
    
    NSArray *myProduct = response.products;
    NSArray *invalidProcs = response.invalidProductIdentifiers;
    
    if (productsDelegate && [productsDelegate respondsToSelector:@selector(productListResponse:withProducts:)])
    {
        DLog(@"Valid products (if any): %@", myProduct);
        DLog(@"Invalid products (if any): %@", invalidProcs);
        
        [productsDelegate productListResponse:YES withProducts:myProduct];
    }
    else
    {
        DLog(@"StoreController: No delegate to send results to!");
    }
    
    [request autorelease];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    DLog(@"SKStore get products: Failed with error: %@", error);
    
    if (productsDelegate && [productsDelegate respondsToSelector:@selector(productListResponse:withProducts:)])
    {
        [productsDelegate productListResponse:NO withProducts:nil];
    }
    else
    {
        DLog(@"StoreController: No delegate to send failure result to!");
    }

    [request autorelease];
}


#pragma mark - Other functions

//
// kick off the purchase transaction.  This will generate a callback to the observer
// at the end of this function.  
//
- (void)purchaseProduct:(SKProduct *)theProduct
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:theProduct.productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
} 

//
// Apple wants us to have a "Restore" button.  Let's do it.
//
- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
#pragma mark - Successful Transaction Methods

//
// saves a record of the transaction by storing the receipt to disk or updating server?
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"In 'recordTransaction'");
    
    if ([purchaseDelegate respondsToSelector:@selector(didGetTransactionReceipt:)])
    {
        [purchaseDelegate didGetTransactionReceipt:transaction];
    }
    else
    {
        DLog(@"StoreController: No delegate to send payment receipt confirmation to!");
    }

} 

- (void)provideContent:(NSString *)productId
{
    DLog(@"In 'provideContent'");

    if ([purchaseDelegate respondsToSelector:@selector(didPurchaseContentWithId:)])
    {
        [purchaseDelegate didPurchaseContentWithId:productId];
    }
    else
    {
        DLog(@"StoreController: No delegate to handle purchase completion!");
    }
}

//
// removes the transaction from the queue and posts a notification with the 
// transaction result.  Also shows an alert box with the result.
//
// The alert box is shown here in case there's no actual UI being shown
// to the user.  This code can run when the app starts up and the transactions
// are sent to us by Apple. 
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    DLog(@"StoreController: in 'finishTransaction'.  Going to post a notification!");
    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //
    // Cool way to send messages to someone, without having to know
    // who that is via an app delegate.  It's possible this will
    // go to multiple places!  I need to test that.
    //
    self.trannyInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    self.wasTrannySuccessful = wasSuccessful;
    
    //
    // Here we have a failing of the MVC model.  I just want to put up 
    // a message box, then continue with the code below.  But no, I can't
    // do that.  I have to save all these variables to the class, then
    // resume operation in another function.  Kind of lame.
    //
    UIAlertView *box = [[[UIAlertView alloc] 
                         initWithTitle:@"Purchase" 
                         message:wasSuccessful ? @"Thank you for your purchase!  Be sure to back up your device regularly to preserve your stuff!" : @"Oops, the purchase was not successful.  Please try again later, and if the issue persists send us an email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [box show];
    
} 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self finishTransactionPart2];
}

- (void)finishTransactionPart2
{
    if (self.wasTrannySuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:self.trannyInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:self.trannyInfo];
    }
 
    [self notifyTransactionEnded];
}

-(void)notifyTransactionEnded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionEnded object:self userInfo:nil];
}

#pragma mark - Handle Successful Transaction Methods

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"In 'completeTransaction'");
    
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}


//
// called when a transaction has been restored and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"In 'restoreTransaction'");

    //
    // Only restore non-consumable transactions
    //
    if ([purchaseDelegate respondsToSelector:@selector(isRestorableProduct:)] && [purchaseDelegate isRestorableProduct:transaction.originalTransaction.payment.productIdentifier])
    {
        [self recordTransaction:transaction.originalTransaction];
        [self provideContent:transaction.originalTransaction.payment.productIdentifier];
        [self finishTransaction:transaction wasSuccessful:YES];
    }
    else
    {
        DLog(@"No delegate or not a restorable transaction");
    }
}

#pragma mark - Unsuccessful Transaction Methods

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        DLog(@"failed transaction with error!");
        
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        DLog(@"Cancelled transaction.");
        
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [self notifyTransactionEnded];
    }
} 

#pragma mark - SKPaymentTransactionObserver implementation

/*
 Implements the observer thingy described here:
 
 http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/AddingaStoretoYourApplication/AddingaStoretoYourApplication.html
 
 The observer setup is done once in appdelegate.
 
 */

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions 
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        DLog(@"Transaction updated: %@", transaction.transactionIdentifier);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}



@end

@implementation SKProduct (extended)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end 
