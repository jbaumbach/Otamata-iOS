//
//  StoreController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

/*
 How to add new in-app purchases:
 =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
 1. Just about everything from the official Apple guide is done.  
 2. Add your product constants into the #define section in the config file (Config.h).
 3. Go to iTunes connect, then the in-app purchase section.  Click "Create New".
 4. Most often the type is "non-consumable".
 5. Enter these values:
    "Reference Name: (same as the constant value in step #2).
    "Product ID: com.ergocentricsoftware.otamata.(contact value from step #2).
    "Display Name:" a short name of a few words, using Title Case.
 	"Description:" This appears in the app when the purchase page is shown.
    "Cleared for purchase:" should probably be yes for now.
 6. Add code to enable the stuff for the purchase.  Look in
    OtamataPurchaseManager.m, function didPurchaseContentWithId.  There's a big if-then
    there.
 7. Add the new product ids into the main list.  See the "productList" method in
    Config.m.
 8. Test in the sandbox.  Info here: http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/DevelopingwithStoreKit/DevelopingwithStoreKit.html#//apple_ref/doc/uid/TP40008267-CH103-SW1
 9. The otamata test account uid and pw is in the file "HowToTestAppStore.pdf" I created in 
    the Documents / App Store directory of Otamata.
 
 */

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification" 
#define kInAppPurchaseManagerTransactionEnded @"kInAppPurchaseManagerTransactionEnded"


@protocol StoreControllerProtocol <NSObject>

-(void) productListResponse:(BOOL)success withProducts:(NSArray *)products;

@end



@protocol PurchaseControllerProtocol <NSObject>

-(void) didPurchaseContentWithId:(NSString *)productId;
-(void) didGetTransactionReceipt:(SKPaymentTransaction *)transaction;
-(BOOL) isRestorableProduct:(NSString *)productId;

@end



@interface StoreController : NSObject
    <SKProductsRequestDelegate,
    SKPaymentTransactionObserver, 
    UIAlertViewDelegate>

//
// Instance members
//
@property (nonatomic, retain) NSSet *productIdentifierList;
@property (nonatomic, retain) id<StoreControllerProtocol> productsDelegate;
@property (nonatomic, retain) id<PurchaseControllerProtocol> purchaseDelegate;
@property (nonatomic, retain) NSDictionary *trannyInfo;
@property BOOL wasTrannySuccessful;


//
// Class methods
//
+(BOOL) purchasingEnabled;


//
// Instance methods
//
- (void) requestProductData;
- (void)purchaseProduct:(SKProduct *)theProduct;
- (void)finishTransactionPart2;
- (void)notifyTransactionEnded;
- (void)restoreCompletedTransactions;



@end

//
// Extension to grab the localized price.  Thanks to here:
//
// http://troybrant.net/blog/2010/01/in-app-purchases-a-full-walkthrough/comment-page-4/#comment-15617
//
@interface SKProduct (extended)

@property (nonatomic, readonly) NSString *localizedPrice;

@end 