//
//  WelcomeScrollViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/22/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WelcomeScrollViewController.h"

#import "WelcomePg1ViewController.h"
#import "WelcomePg2ViewController.h"
#import "WelcomePg3ViewController.h"

#import "GlobalFunctions.h"
#import "Config.h"

@implementation WelcomeScrollViewController

@synthesize welcomeScrollView;
@synthesize welcomePageControl;
@synthesize pages;

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
    [self setupPage];
    
}

- (void)viewDidUnload
{
    [self setWelcomePageControl:nil];
    [self setWelcomeScrollView:nil];
    
    self.pages = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)welcomePageControl:(id)sender {
}

- (void)dealloc {
    [welcomePageControl release];
    [welcomeScrollView release];
    [super dealloc];
}

- (void)setupPage
{
    //
    // Set up some delegate stuff, some behaviors, and colors
    //
	welcomeScrollView.delegate = self;
	[welcomeScrollView setCanCancelContentTouches:NO];
	welcomeScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	welcomeScrollView.scrollEnabled = YES;
    welcomeScrollView.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    self.welcomePageControl.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];

    //
    // Add all our pages to an array of pages.  This lets us loop through them, as well
    // as hold onto a reference to them.  If we don't keep a reference, it's zombie time.
    //
    // There's some optimization potential here.  The pages can perhaps just be referenced,
    // then lazy-loaded as the user scrolls to them.  For now, the performance is pretty 
    // good on a 3GS, so let's keep it simple.
    // 
    self.pages = [NSMutableArray arrayWithObjects:
                  [[[WelcomePg1ViewController alloc] init] autorelease],
                  [[[WelcomePg2ViewController alloc] init] autorelease],
                  [[[WelcomePg3ViewController alloc] init] autorelease],
                  nil];

    CGFloat viewWidth = welcomeScrollView.frame.size.width;
    NSUInteger numberOfPages = self.pages.count;
    
    //
    // Set up the dots thingy, and the content size of scrollview.
    // 
	self.welcomePageControl.numberOfPages = numberOfPages;
    CGFloat totalWidth = viewWidth * numberOfPages;
    [welcomeScrollView setContentSize:CGSizeMake(totalWidth, [welcomeScrollView bounds].size.height)];

    //
    // Grab the frame of the first page.  We'll use it's dims to space out the other
    // pages horizontally within the frame of the parent scrollview.
    //
    CGRect rect = ((UIViewController *)[self.pages objectAtIndex:0]).view.frame;
    
    for (int loop = 0; loop < numberOfPages; loop++)
    {
        WelcomePageViewController *currentPage = [self.pages objectAtIndex:loop];
        
        //
        // If its the second page or later, move the origin over another page width
        //
        if (loop > 0)
        {
            rect.origin.x += viewWidth;
            currentPage.view.frame = rect;
        }
        
        //
        // Add the page to the scrollview
        //
        [welcomeScrollView addSubview:currentPage.view];
        
        currentPage.dismissableController = self;
    }    
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    welcomePageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)pageChanged:(id)sender {
	/*
	 *	Change the scroll view
	 */
    CGRect frame = welcomeScrollView.frame;
    frame.origin.x = frame.size.width * welcomePageControl.currentPage;
    frame.origin.y = 0;
	
    [welcomeScrollView scrollRectToVisible:frame animated:YES];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}
@end
