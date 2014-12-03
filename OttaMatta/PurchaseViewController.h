//
//  PurchaseViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//
// Instructions for purchasing development are in StoreController.m
//


#import <UIKit/UIKit.h>
#import "StoreController.h"
#import "MultiViewHelper.h"
#import "ColorfulButton.h"

//
// View status
//
typedef enum 
{
    vsLoadingData,
    vsDisplayingData,
    vsError
}
ViewStatusCode;



@interface PurchaseViewController : UIViewController
    <UITableViewDataSource,
    UITableViewDelegate,
    StoreControllerProtocol>
{
    // BOOL _canTapItems;
}

//
// UI Elements
//
@property (retain, nonatomic) IBOutlet UIView *loadingView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (retain, nonatomic) IBOutlet UITableView *mainTable;
@property (retain, nonatomic) IBOutlet UIView *errorView;
- (IBAction)restoreClicked:(id)sender;

//
// Instance properties
//
@property (retain, nonatomic) UIView *tableBackgroundSelectedView;
@property (retain, nonatomic) NSArray *availableProducts;
@property (retain, nonatomic) MultiViewHelper *viewHelper;

//
// Instance methods
//
//-(void) setViewStatus:(ViewStatusCode)status;


@end
