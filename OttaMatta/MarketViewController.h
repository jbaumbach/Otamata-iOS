//
//  OttaSecondViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundIconView.h"

@interface MarketViewController : UIViewController
    <UITableViewDataSource, 
    UITableViewDelegate,
    UISearchBarDelegate>
{
    int _currentKeyboardKey;
}

//
// View status
//
typedef enum 
{
    vsLoadingData,
    vsDisplayingData
}
ViewStatusCode;


@property (retain, nonatomic) NSMutableArray *searchResults;
@property (retain, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (retain, nonatomic) IBOutlet UISearchBar *theSearchBar;
@property (retain, nonatomic) IBOutlet UIView *loadingView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *sortSegmentedControl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (retain, nonatomic) UIView *tableBackgroundSelectedView;

- (IBAction)sortBarChanged:(id)sender;
- (void)webSearchBtnClick:(id)sender;

-(void) doSearch;
-(void) setViewStatus:(ViewStatusCode)status;
-(void) searchComplete;

-(void) hideKeyBoardIfAtId:(NSString *)theId;

@end
