//
//  PurchaseViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurchaseViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "ColorfulButton.h"
#import "StoreTableViewCell.h"
#import "OtamataSingleton.h"

@implementation PurchaseViewController
@synthesize loadingView;
@synthesize loadingSpinner;
@synthesize mainTable;
@synthesize errorView;
@synthesize tableBackgroundSelectedView;
@synthesize availableProducts;
@synthesize viewHelper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//
// We "observed" the completion of the purchase!  Let's close this
// UI since it's unlikely the user will purchase more stuff at this
// juncture.
//
-(void) transactionDoneWithPurchase:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) transactionEnded:(NSNotification *)notification
{
    [viewHelper setViewStatus:vsDisplayingData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainTable.rowHeight = 89;
    
    // Do any additional setup after loading the view from its nib.
    
    //
    // Set us up as an observer of the completed transaction coming out of
    // the StoreController class.  This way we can dismiss ourselves if
    // we need to.
    //
    // Note: we don't worry about transaction failed, that's handled by transaction ended.
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionDoneWithPurchase:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionEnded:) name:kInAppPurchaseManagerTransactionEnded object:nil];
    
    
    if ([loadingSpinner respondsToSelector:@selector(color)])
    {
        loadingSpinner.color = [UIColor colorWithHexString:SPINNER_COLOR];
    }
    
    self.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [self.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];
    
    //
    // Set up the multi-state view
    //
    self.viewHelper = [[[MultiViewHelper alloc] initWithParent:self.view andInitialView:vsLoadingData] autorelease];
    [self.viewHelper addPage:loadingView withKey:vsLoadingData];
    [self.viewHelper addPage:mainTable withKey:vsDisplayingData];
    [self.viewHelper addPage:errorView withKey:vsError];
    
    self.title = @"Store";

    //
    // Set up the store controller to grab our product list from iTunesConnect
    //
    StoreController *store = [OtamataSingleton sharedOtamataSingleton].store;
    store.productsDelegate = self;
    store.productIdentifierList = [Config productList];
    [store requestProductData];
    
}

- (void)viewDidUnload
{
    [self setLoadingView:nil];
    [self setLoadingSpinner:nil];
    [self setMainTable:nil];
    [self setErrorView:nil];
    [self setTableBackgroundSelectedView:nil];
    self.availableProducts = nil;
    self.viewHelper = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [loadingView release];
    [loadingSpinner release];
    [mainTable release];
    [errorView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerTransactionEnded object:nil];

    
    [super dealloc];
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return availableProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellIdentifier = @"CellType";
    
    StoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [GlobalFunctions initClassFromNib:[StoreTableViewCell class]];
    }

    SKProduct *product = (SKProduct *)[availableProducts objectAtIndex:indexPath.row];
    
    DLog(@"Product title: %@" , product.localizedTitle);
    DLog(@"Product description: %@" , product.localizedDescription);
    DLog(@"Product price: %@" , product.price);
    DLog(@"Loc Product price: %@" , product.localizedPrice);
    DLog(@"Product id: %@" , product.productIdentifier);

    if ([[product localizedTitle] length] == 0)
    {
        cell.descriptionLabel.text = [NSString stringWithFormat:@"Product %d", indexPath.row];
        cell.longDescriptionLabel.text = @"Sorry, this product is currently not available.";
        [cell.buyButton setTitle:@"n/a" forState:UIControlStateNormal];
        [cell.buyButton setTitle:@"n/a" forState:UIControlStateSelected];
        cell.buyButton.tag = indexPath.row;
    }
    else
    {
        cell.descriptionLabel.text = product.localizedTitle;
        cell.longDescriptionLabel.text = product.localizedDescription;
        [cell.buyButton setTitle:product.localizedPrice forState:UIControlStateNormal];
        [cell.buyButton setTitle:product.localizedPrice forState:UIControlStateSelected];
        cell.buyButton.tag = indexPath.row;
        
        [cell.buyButton addTarget:self action:@selector(buyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - StoreControllerProtocol implementation

-(void) productListResponse:(BOOL)success withProducts:(NSArray *)products
{
    if (success && products.count > 0)
    {
        DLog(@"Found %d items!", products.count);
        
        [viewHelper setViewStatus:vsDisplayingData];
        self.availableProducts = products;
        [mainTable reloadData];
    }
    else
    {
        [viewHelper setViewStatus:vsError];
    }
}

#pragma mark - Other Methods


-(void) buyButtonClicked:(UIButton *)sender
{
    [viewHelper setViewStatus:vsLoadingData];
    
    SKProduct *product = (SKProduct *)[availableProducts objectAtIndex:sender.tag];
    
    DLog(@"Item clicked: %@", product.localizedTitle);
    StoreController *store = [OtamataSingleton sharedOtamataSingleton].store;
    [store purchaseProduct:product];
}

- (IBAction)restoreClicked:(id)sender {
    DLog(@"Restore clicked!");
    StoreController *store = [OtamataSingleton sharedOtamataSingleton].store;
    [store restoreCompletedTransactions];
}
@end
