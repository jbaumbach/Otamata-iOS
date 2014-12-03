//
//  WebsearchViewController.h
//  Otamata
//
//  Created by John Baumbach on 7/7/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarketViewController.h"
#import "WebsearchSound.h"
#import "WebsearchResultSite.h"
#import "RoundedCornerView.h"
#import "SimpleObjectSelectionViewController.h"
#import "GADBannerView.h"

#define MAX_SEARCH_STATUS_RETRIES   45


//
// View status
//
typedef enum 
{
    wsvsStartScreen,
    wsvsLoadingData,
    wsvsDisplayingData,
    wsvsError
}
WebSearchViewStatusCode;


@interface WebsearchViewController : UIViewController
    <UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    SimpleObjectSelectionProtocol>
{
    int _currentKeyboardKey;
    int _numberOfStatusRetries;
    int _totalResults;
}

//
// UI Elements
//
@property (retain, nonatomic) IBOutlet UISearchBar *theSearchBar;
@property (retain, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (retain, nonatomic) IBOutlet UIProgressView *searchProgress;
@property (retain, nonatomic) IBOutlet UIView *loadingView;
@property (retain, nonatomic) IBOutlet UIView *startPageView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (retain, nonatomic) IBOutlet UILabel *viewStatusMessage;
@property (retain, nonatomic) IBOutlet RoundedCornerView *recentSearches;
@property (retain, nonatomic) IBOutlet UILabel *searchResultsLabel;
@property (retain, nonatomic) IBOutlet UILabel *statusSubdetailLabel;
@property (retain, nonatomic) IBOutlet UILabel *whileWaitingLabel;
@property (retain, nonatomic) IBOutlet UIImageView *whileWaitingArrow;

//
// Member variables
//
@property (retain, nonatomic) NSMutableArray *searchResults;
@property (retain, nonatomic) UIView *tableBackgroundSelectedView;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *searchTerm;
@property (nonatomic, retain) NSDate *searchTimer;
@property (nonatomic, retain) NSDate *searchStartTime;
@property (nonatomic, retain) GADBannerView *gadView;

//
// Instance methods
//
-(void) hideKeyBoardIfAtId:(NSString *)theId;
-(void) setViewStatus:(WebSearchViewStatusCode)status;
-(void) doSearch;
-(WebsearchSound *)soundAtIndexPath:(NSIndexPath *)indexPath;
-(void) gotoSearchHistory:(UIGestureRecognizer *)gestureRecognizer;
-(void) addOrRemoveBannerAd:(BOOL)add;
-(void) gotNotificationToRemoveAds:(NSNotification *)notification;
-(void) setAds;

@end
