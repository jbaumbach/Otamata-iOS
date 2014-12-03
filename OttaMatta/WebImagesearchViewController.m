//
//  WebImagesearchViewController.m
//  Otamata
//
//  Created by John Baumbach on 7/14/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WebImagesearchViewController.h"
#import "GlobalFunctions.h"
#import "Config.h"
#import "JSONKit.h"

@implementation WebImagesearchViewController
//@synthesize mainNav;
@synthesize statusLabel;
@synthesize loadingSpinner;
@synthesize navigationBar;
@synthesize theSearchBar;
@synthesize term;
@synthesize images;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize delegate;
@synthesize navTintColor;
@synthesize imageScroller;
@synthesize containerView;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.theSearchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0 , 0, 320, 44)] autorelease];
    theSearchBar.tintColor = [UIColor colorWithHexString:SEARCHBAR_TINT];
    theSearchBar.delegate = self;
    theSearchBar.text = term;
    theSearchBar.placeholder = @"Enter image search term(s)";
    
    if (navTintColor != nil)
    {
        self.navigationBar.tintColor = self.navTintColor;
    }
        
    [self startImageSearch];
    
}

- (void)viewDidUnload
{
    //[self setMainNav:nil];
    [self setStatusLabel:nil];
    [self setLoadingSpinner:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.term = nil;
    self.images = nil;
    self.activeDownload = nil;
    self.imageConnection = nil;
    self.delegate = nil;
    
    [self setNavigationBar:nil];
    self.navTintColor = nil;
    self.theSearchBar = nil;
    self.imageScroller = nil;
    self.containerView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    //[mainNav release];
    [statusLabel release];
    [loadingSpinner release];
    
    [navigationBar release];
    [theSearchBar release];
    [super dealloc];
}

#pragma mark - Instance Methods

-(void) startImageSearch
{
    [statusLabel setHidden:NO];
    if (term != nil && [term length] > 0)
    {
        //
        // This code is direct from the Apple docs.  It starts the d/l.  The callbacks
        // grab the data.
        //
        NSString *url = [Config webImageSearchUrlForTerm:self.term];
        DLog(@"Getting data with url: %@", url);

        statusLabel.text = @"Searching for images...";
        [statusLabel setHidden:NO];
        
        [loadingSpinner startAnimating];
        [self.containerView removeFromSuperview];
        
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
        self.imageConnection = conn;
        [conn release];
        
        
    }
    else
    {
        //DLog(@"Programmer error: there's no search term!");
        
        [self setScroller];
        
        statusLabel.text = @"Enter a search term";
        [loadingSpinner stopAnimating];

    }
}

-(void) soundDownloadComplete:(BOOL)success
{
    [loadingSpinner stopAnimating];

    
    if (success)
    {
        [statusLabel setHidden:YES];
    }
    else
    {
        [statusLabel setHidden:NO];
        statusLabel.text = @"Sorry, no results found.";
    }
}

-(void) addSpinnerToView:(UIView *)theView
{
    CGRect targetFrame = CGRectMake(0, 0, theView.frame.size.width, theView.frame.size.height);
    UIView *spinnerView = [[[UIView alloc] initWithFrame:targetFrame] autorelease];
    spinnerView.backgroundColor = [UIColor clearColor];
    
    float spinnerBoxSize = 50.0;
    CGRect spinnerFrame = CGRectMake((theView.frame.size.width - spinnerBoxSize) / 2, (theView.frame.size.height - spinnerBoxSize) / 2, spinnerBoxSize, spinnerBoxSize);
    
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    spinner.frame = spinnerFrame;
    [spinner startAnimating];
    
    
    [spinnerView addSubview:spinner];
    [theView addSubview:spinnerView];
    
    [GlobalFunctions sleepAndProcessMessages:0.1];
    
}

//
// Yes... yes... here's where the magic happens...
//
-(void) setScroller
{
    UIColor *containerViewBackgroundColor = [UIColor blackColor];   // debugging: red
    UIColor *imageBackgroundColor = [UIColor colorWithHexString:VERY_LIGHT_GREEN];
    
    CGRect parentRect = [self.view frame];
    CGRect navbarRect = [self.navigationBar frame];
    CGRect searchBarRect = [self.theSearchBar frame];
    
    CGRect scrollerRect = CGRectMake(parentRect.origin.x, 0 + navbarRect.size.height, parentRect.size.width, parentRect.size.height - navbarRect.size.height);
    
    self.imageScroller = [[[UIScrollView alloc] initWithFrame:scrollerRect] autorelease];
    imageScroller.delegate = self;
    
    [self.view addSubview:imageScroller];
    [imageScroller addSubview:theSearchBar];
    
    //
    // Calculate size requirements for the image container
    //
    int numImages = images.count;
    
    if (numImages > 0)
    {
        int numColumns = 3;
        float margins = 10.0;
        
        float containerWidth = scrollerRect.size.width;    // parentRect.size.width - (margins * 2);
        
        //
        // Let's do square images for now
        //
        float imageWidth = (containerWidth - (  ((numColumns - 1) * margins) + (2 * margins)     )) / numColumns;
        int numRows = numImages / numColumns;
        int extraRow = numImages % numColumns == 0 ? 0 : 1;
        
        float imageHeight = imageWidth;
        //float imageContainerOriginY = 0;
        float rowHeight = imageHeight + margins;
        
        CGRect imageContainerRect = CGRectMake(0, 
                                               searchBarRect.size.height, 
                                               containerWidth, 
                                               searchBarRect.size.height + (2 * margins) + (rowHeight * (numRows + extraRow))); // todo: adjust this to account for an empty last row
        
        
        self.containerView = [[[UIView alloc] initWithFrame:imageContainerRect] autorelease];
        
        containerView.backgroundColor = containerViewBackgroundColor;
        
        [imageScroller addSubview:containerView];
        imageScroller.contentSize = imageContainerRect.size;
        
        float originX = margins;
        float originY = margins;
        
        for (NSDictionary *anImage in images) 
        {
            //
            // Create an imageview and place it in the container
            //
            CGRect imageFrame = CGRectMake(originX, originY, imageWidth, imageHeight);
            WebsearchImageView *imageView = [[[WebsearchImageView alloc] initWithFrame:imageFrame] autorelease];
            imageView.backgroundColor = imageBackgroundColor;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.clipsToBounds = YES;
            imageView.sourceImageInfo = anImage;
            
            [containerView addSubview:imageView];
            
            //
            // Load an image in the imageview
            //
            NSString *thumbnailUrl = [anImage objectForKey:@"thumbnailurl"];
            [self loadImageAsync:imageView withUrl:thumbnailUrl];
            
            //
            // Let the user select the image
            //
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClickedImage:)];
            [imageView addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            //
            // Calculate next image's position
            //
            originX += imageWidth + margins;
            if (originX + imageWidth > containerWidth)
            {
                originX = margins;
                originY += imageHeight + margins;
            }
        }
        
        imageScroller.backgroundColor = [UIColor clearColor]; //scrollerBackgroundColor;
        
    }
    else
    {
        DLog(@"No images!");
        self.containerView = nil;
        statusLabel.text = @"No images found";
        [loadingSpinner stopAnimating];
        
        imageScroller.backgroundColor = [UIColor clearColor];
    }
    
    [GlobalFunctions sleepAndProcessMessages:0.1];
    
}

#pragma mark - User Actions

- (IBAction)cancelClicked:(id)sender {

    if ([delegate respondsToSelector:@selector(userDidSelectImage:withImage:)])
    {
        [delegate userDidSelectImage:NO withImage:nil];
    }
    else
    {
        DLog(@"No delegate defined, I suppose we'll just sit here forever.  Not what you'd hope for.");
    }
}

-(void) userClickedImage:(UIGestureRecognizer *)gestureRecognizer
{
    DLog(@"userClickedImage");

    WebsearchImageView *imageSelected = (WebsearchImageView *)[gestureRecognizer view];
    NSLog(@"Selected image: %@", [imageSelected.sourceImageInfo objectForKey:@"thumbnailurl"]);

    [self addSpinnerToView:imageSelected];
    
    //
    // Download the full size image, and crop it
    //
    NSString *url = [imageSelected.sourceImageInfo objectForKey:@"url"];
    
    DLog(@"Grabbing full version of image: %@", url);
    
    NSData *fullImage = [[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]] autorelease];
    
    //
    // Remove all current views (most likely the spinny progress thingy)
    //
    [[imageSelected subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];

    if (fullImage != nil)
    {
        UIImage *theImage = [UIImage imageWithData:fullImage];
        
        PhotoCropperViewController *controller = [[[PhotoCropperViewController alloc] initWithPhoto:theImage delegate:self] autorelease];
        [self presentModalViewController:controller animated:YES];
    }
    else
    {
    }
}



#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // int dlLength = [activeDownload length];
    // int dataLength = [data length];
    // int lengthReceived = dlLength + dataLength;
    
    //
    // This odd statement apparently sleeps a bit, allowing the UI to update.
    //
    float delaySecs = [Config getUserServerPreference] == 1 ? 0.05 : 0.05;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delaySecs]];
    
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Failed with error! %@", error.localizedDescription);
    
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [self soundDownloadComplete:NO];
}

-(void) loadImageAsync:(UIImageView *)imageView withUrl:(NSString *)url
{
    //
    // Odd, legacy-looking code courtesy of this dude:
    //
    // http://stackoverflow.com/questions/933099/getting-image-from-url-objective-c
    //
    
    //
    // todo: find some way to kill all these threads if necesary, e.g. user
    // searches for something else.
    //
    dispatch_async(dispatch_get_global_queue(0,0), 
    ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), 
        ^{
            if (imageView != nil && [imageView respondsToSelector:@selector(setImage:)])
            {
                imageView.image = [UIImage imageWithData: data];
            }
        });
        [data release];
    });
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Download complete!");
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    NSDictionary *dataResults = [jsonString objectFromJSONString];
    
    self.images = [dataResults objectForKey:@"results"];
    
    for (NSDictionary *anImage in images) {
        DLog(@"Found url: %@", [anImage objectForKey:@"url"]);
    }

    [self setScroller];
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [self soundDownloadComplete:YES];
    
    
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

#pragma mark - PhotoCropperDelegate implementation

- (void) photoCropperDidFinish:(UIImage *)photo
{
    //[self dismissModalViewControllerAnimated:YES];
    //DLog(@"Dismissed modal, now doing delegate");
    
    //[GlobalFunctions sleepAndProcessMessages:0.1];
    
    
    if (delegate != nil && [delegate respondsToSelector:@selector(userDidSelectImage:withImage:)])
    {
        if (photo != nil)
        {
            [delegate userDidSelectImage:YES withImage:photo];
        }
        else
        {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        DLog(@"Boo!  Bad programmer!  No delegate set");
    }
}


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
    self.term = searchBar.text;
    
    [self startImageSearch];
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

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [theSearchBar resignFirstResponder];
}


@end

#pragma mark - WebsearchImageView helper class implementation

@implementation WebsearchImageView
@synthesize sourceImageInfo;

-(void)dealloc
{
    self.sourceImageInfo = nil;
    [super dealloc];
}
@end