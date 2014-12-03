//
//  OttaSecondViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MarketViewController.h"

#import "GDataXMLNode.h"
#import "JSONKit.h"
#import "SoundDetailViewController.h"
#import "SoundManager.h"
#import "SoundTableViewCell.h"
#import "Config.h"
#import "RateView.h"
#import "GlobalFunctions.h"
#import "WebsearchViewController.h"

@implementation MarketViewController
@synthesize searchResults;
@synthesize searchResultsTable;
@synthesize theSearchBar;
@synthesize loadingView;
@synthesize sortSegmentedControl;
@synthesize loadingSpinner;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize tableBackgroundSelectedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Browse", @"Browse");
        self.tabBarItem.title = @"Browse"; // <=- note: this is ignored if you use the default system item 
        self.tabBarItem.image = [UIImage imageNamed:@"downloadicon"];
        //self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0] autorelease];

    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Manually set the row height of the table cells.  Better performance just to hard code
    // it here rather than instantiate an object from the NIB and get the rect.
    //
    searchResultsTable.rowHeight = 73.0f;
    
    theSearchBar.tintColor = [UIColor colorWithHexString:SEARCHBAR_TINT];
    sortSegmentedControl.tintColor = [UIColor colorWithHexString:SORTSEGMENT_TINT];
    if ([loadingSpinner respondsToSelector:@selector(color)])
    {
        loadingSpinner.color = [UIColor colorWithHexString:SPINNER_COLOR];
    }
    
    
    [self doSearch];
    
    self.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [self.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];
    
    //
    // Use this code when you have a built-in navigation controller and just want to add
    // a button to it
    //
    /*
    UIBarButtonItem *webSearchBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Web" style:UIBarButtonItemStylePlain target:self action:@selector(webSearchBtnClick:)] autorelease];
    self.navigationItem.rightBarButtonItem = webSearchBtn;
    */
}

- (void)viewDidUnload
{
    [self setSearchResultsTable:nil];
    [self setTheSearchBar:nil];
    [self setLoadingView:nil];
    [self setSortSegmentedControl:nil];
    [self setLoadingSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [searchResultsTable release];
    self.searchResults = nil;
    
    [theSearchBar release];
    
    [loadingView release];
    [sortSegmentedControl release];
    [loadingSpinner release];
    [super dealloc];
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //
    // Grab the sound we are looking for
    //
    Sound *currentSound = [searchResults objectAtIndex:indexPath.row];
    
    //
    // Set up some cell view styles for creating/dequeueing/initing the type of cell we want
    //
    NSString *cellIdentifier = @"CellType";
    
    SoundTableViewCell *cell = nil;

    //
    // The cell has a control which downloads the icon, so we don't want to recycle
    // the cell while that's going on.  
    //
    if (![currentSound shouldDownloadIcon])
    {
        cell = (SoundTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    if (cell == nil) {
        cell = (SoundTableViewCell *)[GlobalFunctions initClassFromNib:[SoundTableViewCell class]];
        
        //
        // The cell should not be dequeable if the associated iconview is going to 
        // be asyncronously downloading the icon data.
        //
        if (![currentSound shouldDownloadIcon])
        {
            cell.reuseIdentifierSpecial = cellIdentifier;
        }
        
        [cell setSelectedBackgroundView:self.tableBackgroundSelectedView];

        //
        // Todo: these UIImages might use up a lot of memory - make them static in a singleton?
        //
        cell.ratingView.notSelectedImage = [UIImage imageNamed:NOTSELECTEDIMAGE];
        cell.ratingView.halfSelectedImage = [UIImage imageNamed:HALFSELECTEDIMAGE];
        cell.ratingView.fullSelectedImage = [UIImage imageNamed:FULLSELECTEDIMAGE];

        // DLog(@"Created new with resuse id: %@  (was looking for: %@)", cell.reuseIdentifier, cellIdentifier);
    }
    else
    {
        // DLog(@"Dequeued!");
    }
    
    
    // Configure the cell

    [cell.nameLabel setText:currentSound.name];
    [cell.uploadedByLabel setText:currentSound.uploadedBy];
    
    if (currentSound.averageRating >= 0)
    {
        cell.ratingView.hidden = NO;
        cell.notYetRatedLabel.hidden = YES;
        cell.ratingView.rating = currentSound.averageRating;
    }
    else
    {
        cell.ratingView.hidden = YES;
        cell.notYetRatedLabel.hidden = NO;
        cell.notYetRatedLabel.textColor = [UIColor colorWithHexString:SPINNER_COLOR];
    }
    cell.ratingView.editable = NO;
    cell.ratingView.maxRating = 5;
    //cell.ratingView.delegate = self;

    [cell.dateLabel setText:[GlobalFunctions formatDate:currentSound.uploadDate]];
    [cell.downloadsLabel setText:[NSString stringWithFormat:@"%d downloads", currentSound.downloads]];
    cell.iconView.theSound = currentSound;
    //cell.iconView.iconDownloadDelegate = self;
    
    if ([cell.loadingSpinner respondsToSelector:@selector(color)])
    {
        cell.loadingSpinner.color = [UIColor colorWithHexString:SPINNER_COLOR];
    }

    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyBoardIfAtId:nil];
    SoundDetailViewController *controller = [[[SoundDetailViewController alloc] init] autorelease];
    controller.sound = [searchResults objectAtIndex:indexPath.row];
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
    [self doSearch];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchBarSearchInitiated:searchBar];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar 
{
    [self searchBarSearchInitiated:searchBar];
}

#pragma mark - User Actions

- (IBAction)sortBarChanged:(id)sender {
    [self doSearch];
}

- (void)webSearchBtnClick:(id)sender {
    
    WebsearchViewController *controller = [[[WebsearchViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    
}


#pragma mark - Other Methods

-(SoundSearchOrder) searchOrder
{
    //
    // Just return the index because they currently match the values of 
    // the sort order enum
    //
    DLog(@"Segment index: %d", sortSegmentedControl.selectedSegmentIndex);
    
    return (SoundSearchOrder)sortSegmentedControl.selectedSegmentIndex;
}
-(void) doSearch
{
    //
    // This code is direct from the Apple docs.  It starts the d/l.  The callbacks
    // grab the data.
    //
    [self setViewStatus:vsLoadingData];
    
    NSString *term = theSearchBar.text == nil ? @"" : theSearchBar.text;
    
    NSString *url = [Config soundSearchUrlForTerm:term withOrder:[self searchOrder] includeInappropriate:[Config getInappropriateContent]];
    
    DLog(@"Using search url: %@", url);
    
    self.activeDownload = [NSMutableData data];
    // 
    // Do a "GET" operation
    //
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
    self.imageConnection = conn;
    [conn release];

}

-(void) setViewStatus:(ViewStatusCode)status
{
    switch (status) {
        case vsLoadingData:
            [searchResultsTable setHidden:YES];
            [loadingView setHidden:NO];
            break;
            
        case vsDisplayingData:
            [searchResultsTable setHidden:NO];
            [loadingView setHidden:YES];
        default:
            break;
    }
}

-(void) searchComplete
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;

    [self setViewStatus:vsDisplayingData];
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
    self.searchResults = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
        
    DLog(@"Response had %d bytes.", self.activeDownload.length);
    
    NSDictionary *jsonData = [jsonString objectFromJSONString];
    NSDictionary *allSounds = [jsonData objectForKey:@"sounds"];
    Sound *localSound = nil;
    Sound *soundToUse = nil;
    
    for (NSDictionary *soundData in allSounds)
    {
        //
        // Load the values for the sound from the server results.  Then see if we have the sound cached locally.
        // This only applies to server sounds.  Not user or default sounds.
        //
        // Note: only the values returned from the server call are saved in memory.  When the icon is finished loading, 
        // the entire object is serialized to disk.
        //
        Sound *remoteSound = [[[Sound alloc] initWithDictionary:soundData] autorelease];
        localSound = [SoundManager getLocalSoundFromId:remoteSound.soundId];
        
        if (localSound)
        {
            DLog(@"Going to use local sound for id: %@", localSound.soundId);
         
            if (localSound.programVersion != PROGRAM_VERSION)
            {
                DLog(@"Todo: upgrade sound of version %d to version %d", localSound.programVersion, PROGRAM_VERSION);
            }
            
            soundToUse = localSound;
        }
        else
        {
            DLog(@"Going to use remote sound for id: %@", remoteSound.soundId);
            
            soundToUse = remoteSound;
            
            //
            // Set some defaults
            //
            soundToUse.status = sscPreview;
            soundToUse.programVersion = PROGRAM_VERSION;
            remoteSound.iconAppDefaultId = 1;   // If necessary, use the standard default icon, the index = 1
            
            if (!remoteSound.hasIcon)
            {
                remoteSound.iconSrcType = istAppDefault;
            }
            else
            {
                remoteSound.iconSrcType = istLocalData;
            }
        }   
        
        //
        // Update some of the info from the server regardless
        //
        soundToUse.averageRating = remoteSound.averageRating;
        soundToUse.downloads = remoteSound.downloads;
        
        [self.searchResults addObject:soundToUse];
    }

    [self searchComplete];    
    [searchResultsTable reloadData];
    
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

@end
