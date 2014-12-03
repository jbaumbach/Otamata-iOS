//
//  WebsearchViewController.m
//  Otamata
//
//  Created by John Baumbach on 7/7/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WebsearchViewController.h"
#import "GlobalFunctions.h"
#import "Config.h"
#import "JSONKit.h"
#import "WebsoundDetailViewController.h"
#import "WebsearchHistory.h"
#import "OtamataFunctions.h"

@implementation WebsearchViewController
@synthesize theSearchBar;
@synthesize searchResultsTable;
@synthesize searchProgress;
@synthesize loadingView;
@synthesize startPageView;
@synthesize loadingSpinner;
@synthesize viewStatusMessage;
@synthesize recentSearches;
@synthesize searchResultsLabel;
@synthesize statusSubdetailLabel;
@synthesize whileWaitingLabel;
@synthesize whileWaitingArrow;
@synthesize tableBackgroundSelectedView;
@synthesize searchResults;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize searchTerm;
@synthesize searchTimer;
@synthesize searchStartTime;
@synthesize gadView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Web Search", @"Web Search");
        self.tabBarItem.title = @"Search";
        //self.tabBarItem.image = [UIImage imageNamed:@"downloadicon"];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //
    // Manually set the row height of the table cells.  Better performance just to hard code
    // it here rather than instantiate an object from the NIB and get the rect.
    //
    //searchResultsTable.rowHeight = 73.0f;
    
    theSearchBar.tintColor = [UIColor colorWithHexString:SEARCHBAR_TINT];
    
    if ([loadingSpinner respondsToSelector:@selector(color)])
    {
        loadingSpinner.color = [UIColor colorWithHexString:SPINNER_COLOR];
    }
    
    //
    // These views (representing viewstates of this screen) are outside of
    // the viewcontroller in the NIB because it's a pain adding stuff to them
    // when they're on top of each other.  So, keep them separate until
    // runtime.
    //
    CGRect mainViewRect = self.view.frame;
    
    searchResultsTable.frame = CGRectMake(0, 
                                          mainViewRect.size.height - searchResultsTable.frame.size.height, 
                                          searchResultsTable.frame.size.width, 
                                          searchResultsTable.frame.size.height);  
    [self.view addSubview:searchResultsTable];
    
    loadingView.frame = CGRectMake(0, 
                                   mainViewRect.size.height - loadingView.frame.size.height, 
                                   loadingView.frame.size.width, 
                                   loadingView.frame.size.height);  
    [self.view addSubview:loadingView];
    
    startPageView.frame = CGRectMake(0, 
                                     mainViewRect.size.height - startPageView.frame.size.height, 
                                     startPageView.frame.size.width, 
                                     startPageView.frame.size.height);  
    [self.view addSubview:startPageView];
    
    //
    // Show no results page
    //
    [self setViewStatus:wsvsStartScreen];
    
    self.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [self.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];
    
    recentSearches.color = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    recentSearches.backgroundColor = [UIColor clearColor];
    [recentSearches setCornerRadius:13.0f];

    [searchResultsLabel setText:@"Enter some search terms."];
    statusSubdetailLabel.text = @"";

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSearchHistory:)];
    [recentSearches addGestureRecognizer:tapGesture];
    [tapGesture release];

    //
    // Ad stuff
    //
    [self setAds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotificationToRemoveAds:) name:gmiRemoveAllAds object:nil];
    
    
}

- (void)viewDidUnload
{
    [self setTheSearchBar:nil];
    [self setSearchResultsTable:nil];
    [self setSearchProgress:nil];
    [self setLoadingView:nil];
    
    self.searchResults = nil;
    self.tableBackgroundSelectedView = nil;
    self.activeDownload = nil;
    self.imageConnection = nil;
    self.searchTerm = nil;
    self.searchTimer = nil;
    self.gadView.delegate = nil;
    self.gadView = nil;
    self.searchStartTime = nil;
    
    [self setLoadingSpinner:nil];
    [self setViewStatusMessage:nil];
    [self setRecentSearches:nil];
    [self setSearchResultsLabel:nil];
    [self setStatusSubdetailLabel:nil];
    [self setStartPageView:nil];
    
    [self setWhileWaitingLabel:nil];
    [self setWhileWaitingArrow:nil];
    
    //
    // Remove us as observer, or app crashes when this object is dealloc'd.
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    [theSearchBar release];
    [searchResultsTable release];
    [searchProgress release];
    [loadingView release];
    [loadingSpinner release];
    [viewStatusMessage release];
    [recentSearches release];
    [searchResultsLabel release];
    [statusSubdetailLabel release];
    [startPageView release];
    [whileWaitingLabel release];
    [whileWaitingArrow release];
    [super dealloc];
}

#pragma mark - Table methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    WebsearchResultSite *site = (WebsearchResultSite *)[searchResults objectAtIndex:section];
    NSString *domain = site.siteName;
    int resultCount = site.sounds.count;
    
    return [NSString stringWithFormat:@"%@ (%d)", domain, resultCount];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.searchResults count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    int count = ((WebsearchResultSite *)[searchResults objectAtIndex:section]).sounds.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //
    // Set up some cell view styles for creating/dequeueing/initing the type of cell we want
    //
    NSString *cellIdentifier = @"CellType";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    WebsearchSound *currentSound = [self soundAtIndexPath:indexPath];
    
    cell.textLabel.text = currentSound.fileName;
    
    NSString* commaString = [GlobalFunctions formatWithCommas:currentSound.size];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bytes", commaString];
    
    [cell setSelectedBackgroundView:self.tableBackgroundSelectedView];

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyBoardIfAtId:nil];
    
    WebsoundDetailViewController *controller = [[[WebsoundDetailViewController alloc] init] autorelease];
    controller.webSound = [self soundAtIndexPath:indexPath];
    controller.searchTerm = searchTerm;
    [self.navigationController pushViewController:controller animated:YES];
    
    [tableView deselectAllRows];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [theSearchBar resignFirstResponder];
}

/*
 #pragma mark - SoundIconDownloadedProtocol Implementation
 
 -(void) soundIconDownloadedForId:(int)soundId withData:(NSData *)data
 {
 DLog(@"Finished downloading icon for sound id: %d", soundId);
 
 //theSound.imageData = decodedIconData;
 //[SoundManager serializeSound:theSound];
 
 
 }
 */

#pragma mark - SearchBarDelegate Implementation

-(void) hideKeyBoardIfAtId:(NSString *)theId
{
    DLog(@"Want to hide keyboard for id: %d and currently we have %d", [theId intValue], _currentKeyboardKey);
    
    if ([theId intValue] == _currentKeyboardKey || theId == nil)
    {
        [theSearchBar resignFirstResponder];
    }
}

//
// Incremental search support
//
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    /*
     DLog(@"Text changed: %@", searchText);
     
     [self performSelector:@selector(hideKeyBoardIfAtId:) withObject:[NSString stringWithFormat:@"%d", ++_currentKeyboardKey] afterDelay:4];
     
     [self doSearch:searchText];
     */
}

-(void)searchBarSearchInitiated:(UISearchBar *)searchBar
{
    self.searchTerm = theSearchBar.text == nil ? @"" : theSearchBar.text;
    
    if ([self.searchTerm length] <= 0)
    {
        //
        // Tell user he/she is bad.
        //
        UIAlertView *badUser = [[[UIAlertView alloc] initWithTitle:@"No Search Term" message:@"Please enter a search term!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [badUser show];
    }
    else
    {
        [searchBar resignFirstResponder];

        self.searchProgress.progress = 0.0;
        _numberOfStatusRetries = 0;
        
        [WebsearchHistory saveSearch:self.searchTerm withResultCount:-1];
        
        self.searchStartTime = [NSDate date];
        
        [GlobalFunctions sleepAndProcessMessages:0.1];
        
        [self doSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchBarSearchInitiated:searchBar];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar 
{
    [self searchBarSearchInitiated:searchBar];
}


#pragma mark - Other Methods

//
// Note: this function is called multiple times for a search (to update status)
// Code that only runs once is in "searchBarSearchInitiated"
//
-(void) doSearch
{

    self.searchTerm = theSearchBar.text == nil ? @"" : theSearchBar.text;
    
    if ([self.searchTerm length] <= 0)
    {
        [NSException raise:@"No search term" format:@"Need to have something before calling this function.  Always call 'searchBarSearchInitiated'"];
    }
    else
    {
        [self setViewStatus:wsvsLoadingData];
        [searchResultsTable scrollToTop];
        
        NSString *url = [Config websoundSearchUrlForTerm:self.searchTerm];
        
        DLog(@"Using search url: %@", url);
        
        self.activeDownload = [NSMutableData data];
        self.searchTimer = [NSDate date];
        
        // 
        // Do a "GET" operation
        //
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
        self.imageConnection = conn;
        [conn release];
    }    
}

-(void) setViewStatus:(WebSearchViewStatusCode)status
{
    [startPageView setHidden:YES];
    [searchResultsTable setHidden:YES];
    [loadingView setHidden:YES];
    
    switch (status) {
        case wsvsStartScreen:
            [startPageView setHidden:NO];
            break;
            
        case wsvsLoadingData:
            [loadingView setHidden:NO];
            break;
            
        case wsvsDisplayingData:
            [searchResultsTable setHidden:NO];
            break;
            
        default:
            break;
    }
}

-(void) resetConnections
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
}


-(void) searchComplete
{
    [self resetConnections];
    
    //
    // Set search results message
    // 
    if ([self.searchResults count] > 0)
    {
        [searchResultsLabel setText:[NSString stringWithFormat:@"%d results found", _totalResults]];
    }
    else
    {
        [searchResultsLabel setText:@"Sorry, no results found"];
    }
    
    [WebsearchHistory saveSearch:self.searchTerm withResultCount:_totalResults];
    self.searchProgress.progress = 0.0;
    [statusSubdetailLabel setText:@""];

    if (![Config getRemoveAds])
    {
        //
        // Make sure the ad displays for at least several seconds!
        //
        double elapsedTimeSecs = [[NSDate date] timeIntervalSinceDate:searchStartTime];
        
        DLog(@"Elapsed time in MS: %f", elapsedTimeSecs);
        
        const int minSecsToShowAd = 12;
        
        if (elapsedTimeSecs < minSecsToShowAd)
        {
            [GlobalFunctions sleepAndProcessMessages:minSecsToShowAd - elapsedTimeSecs];
        }

        
    }
    
    [self setViewStatus:wsvsDisplayingData];
}

-(void) searchCompleteWithMessage:(NSString *)msg
{
    [self resetConnections];
    [self setViewStatus:wsvsLoadingData];
    
}

-(WebsearchSound *)soundAtIndexPath:(NSIndexPath *)indexPath
{
    WebsearchSound *result = [((WebsearchResultSite *)[searchResults objectAtIndex:indexPath.section]).sounds objectAtIndex:indexPath.row];

    return result;
}

-(void) gotoSearchHistory:(UIGestureRecognizer *)gestureRecognizer
{
    NSMutableArray *searchHistoryItems = [WebsearchHistory getSearchHistory];
    [self.theSearchBar resignFirstResponder];
        
    if (searchHistoryItems != nil && searchHistoryItems.count > 0)
    {
        DLog(@"Gonna bring up search history");
        
        SimpleObjectSelectionViewController *controller = [[SimpleObjectSelectionViewController alloc] init];
        controller.selectList = searchHistoryItems;
        controller.dialogTitle = @"Search History";
        controller.delegate = self;
        controller.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
        [controller.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

-(void) addOrRemoveBannerAd:(BOOL)add
{
    CGSize bannerAdSize = [OtamataFunctions bannerAdSize];
    
    if (add)
    {
        if (self.gadView == nil)
        {
            self.gadView = [OtamataFunctions addBannerAdToView:self.loadingView andViewController:self withSize:bannerAdSize];
        }
    }
    else 
    {
        if (self.gadView == nil)
        {
            DLog(@"Ummmm... shouldn't be calling this without an adview!");
        }
        else
        {
            [self.gadView removeFromSuperview];
            self.gadView.delegate = nil;
            self.gadView = nil;
        }
    }
}

//
// Process the notification that ads are toast
//
-(void) gotNotificationToRemoveAds:(NSNotification *)notification
{
    DLog(@"Got notification msg: %@", notification);
    [self setAds];
}


-(void) setAds
{
    BOOL haveAds = ![Config getRemoveAds];
    
    [self addOrRemoveBannerAd:haveAds];
    whileWaitingLabel.hidden = !haveAds;
    whileWaitingArrow.hidden = !haveAds;
}

#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // DLog(@"Got some data!");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Failed with error! %@", error.localizedDescription);
    [self searchComplete];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Download complete!");
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    DLog(@"Response had %d bytes.", self.activeDownload.length);
    
    NSDictionary *jsonData = [jsonString objectFromJSONString];
    
    NSDictionary *status = [jsonData objectForKey:@"status"];
    
    int isDone = 0;
    float pctComplete = 0.0;
    _totalResults = 0;
    int urlsSearched = 0;
    int urlsTotal = 0;
    
    if (status == nil || status == (id)[NSNull null])
    {
        //
        // Server will return null for status AFTER the initial query and BEFORE the first sound
        // is successfully downloaded.
        //
        // todo: see what happens if there are NO results.  Prolly will stay null.  To fix on server!
        //
        DLog(@"Status is null");
        //statusSubdetailLabel.text = @"Waiting for status...";
    }
    else
    {
        isDone = [[status objectForKey:@"isdone"] intValue];
        pctComplete = [[status objectForKey:@"percentcomplete"] floatValue];
        _totalResults = [[status objectForKey:@"itemsfound"] intValue];
        urlsSearched = [[status objectForKey:@"urlsSearched"] intValue];
        urlsTotal = [[status objectForKey:@"urlsTotal"] intValue];
        
        [statusSubdetailLabel setText:[NSString stringWithFormat:@"Searched %d of %d sources, %d found", urlsSearched, urlsTotal, _totalResults]];
    }
    
    if (isDone == 0)
    {
        //
        // Update the UI with the current status, and get another status
        // 
        _numberOfStatusRetries++;
        
        DLog(@"Search not done, on %d retry of max %d...", _numberOfStatusRetries, MAX_SEARCH_STATUS_RETRIES);
        
        if (_numberOfStatusRetries < MAX_SEARCH_STATUS_RETRIES)
        {
            searchProgress.progress = pctComplete;
            
            //
            // Let's not go crazy on a speedy network
            //
            double elapsedTimeSecs = [[NSDate date] timeIntervalSinceDate:searchTimer];
            
            DLog(@"Elapsed time in MS: %f", elapsedTimeSecs);
            
            const int secsToWaitBetweenRetries = 2;
            
            if (elapsedTimeSecs < secsToWaitBetweenRetries)
            {
                [GlobalFunctions sleepAndProcessMessages:secsToWaitBetweenRetries - elapsedTimeSecs];
            }
            
            [self doSearch];
        }
        else
        {
            //
            // todo: make a better error message here
            //
            [self searchComplete];
        }
    }
    else
    {
        DLog(@"search is done!");
        
        self.searchResults = [[[NSMutableArray alloc] init] autorelease];
        
        NSDictionary *allSites = [jsonData objectForKey:@"results"];
        
        for (NSDictionary *site in allSites)
        {
            WebsearchResultSite *website = [[[WebsearchResultSite alloc] init] autorelease];
            website.siteName = [site objectForKey:@"sourcedomain"];
            website.sounds = [[[NSMutableArray alloc] init] autorelease];
            
            NSDictionary *allSounds = [site objectForKey:@"sounds"];
            
            for (NSDictionary *soundData in allSounds) 
            {
                //
                // todo: move this code to the websound model so it knows how to load itself
                //
                WebsearchSound *sound = [[[WebsearchSound alloc] init] autorelease];
                
                sound.fileName = [soundData objectForKey:@"filename"];
                sound.soundId = [soundData objectForKey:@"itemid"];
                sound.size= [[soundData objectForKey:@"size"] longValue];
                sound.sourceUrl = [soundData objectForKey:@"sourceurl"];
                sound.term = self.searchTerm;
                
                [website.sounds addObject:sound];
            }
            
            [self.searchResults addObject:website];
        }
        
        [self searchComplete];    
        [searchResultsTable reloadData];
    }
    
}
-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //return YES to say that we have the necessary credentials to access the requested resource
    DLog(@"Can we authenticate?");
    
    return YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    DLog(@"Received authentication request!");
    NSURLCredential *credential = [NSURLCredential credentialWithUser:[Config apiUserName] password:[Config apiPW] persistence:NSURLCredentialPersistenceForSession];
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

#pragma mark - SimpleObjectSelectionProtocol Implementation


- (void)simpleObjectDialogDismissed:(NSObject *)item withKey:(NSObject *)key
{
    WebsearchHistory *entry = (WebsearchHistory *)item;

    DLog(@"User selected: %@", [entry term]);
    
    theSearchBar.text = entry.term;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //[self doSearch];
    [self searchBarSearchInitiated:nil];
}

- (NSString *)getTextOfItem:(NSObject *)item withKey:(NSObject *)key
{
    WebsearchHistory *entry = (WebsearchHistory *)item;
    
    return entry.term;
}

- (NSString *)getDetailTextOfItem:(NSObject *)item withKey:(NSObject *)key
{
    WebsearchHistory *entry = (WebsearchHistory *)item;

    if (entry.resultCount >= 0)
    {
        return [NSString stringWithFormat:@"%d", entry.resultCount];
    }
    else
    {
        return @"In Progress";
    }
}



@end
