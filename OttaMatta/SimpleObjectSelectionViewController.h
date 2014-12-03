//
//  SimpleObjectSelectionViewController2.h
//  Moola
//
//  Created by John Baumbach on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// To use:
//  * Implement the protocol in your header and body.
//  * Set the dialog title and delegate when you create the item.  Here's an example:
//      SimpleObjectSelectionViewController *controller = [[SimpleObjectSelectionViewController alloc] init];
//      controller.selectList = [Accounts getAccounts];
//      controller.dialogTitle = @"Select Account";
//      controller.delegate = self;
//      [self.navigationController pushViewController:controller animated:YES];
//      [controller release];
//
// To set a background color when selected:
//  controller.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
//  [controller.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];
//
@protocol SimpleObjectSelectionProtocol <NSObject>

@required
//
// Dismiss the dialog when this is called in your class. Key is optional.
//
- (void)simpleObjectDialogDismissed:(NSObject *)item withKey:(NSObject *)key;

@optional
//
// Implement this method if the selectList items are NOT
// NSString objects.  
//
- (NSString *)getTextOfItem:(NSObject *)item withKey:(NSObject *)key;
- (NSString *)getDetailTextOfItem:(NSObject *)item withKey:(NSObject *)key;
@end


@interface SimpleObjectSelectionViewController : UIViewController
{
    id<SimpleObjectSelectionProtocol> delegate;
}

@property (retain, nonatomic) IBOutlet UITableView *mainTableView;


//
// When I get smarter, I should probably convert this list type to NSFastEnumeration
// instead of NSMutableArray.  It'll make this controller a lot more flexible.
//
@property (nonatomic, retain) NSMutableArray *selectList;
@property (nonatomic, retain) NSArray *selectIcons;
@property (assign) id<SimpleObjectSelectionProtocol> delegate;
@property (nonatomic, retain) NSString *dialogTitle;
@property (nonatomic, retain) NSObject *selectedItem;
@property (nonatomic, retain) NSObject *key;
@property (retain, nonatomic) NSString *closeButtonTitle;
@property UITableViewCellStyle tableViewStyle;
@property (retain, nonatomic) UIView *tableBackgroundSelectedView;

@end
