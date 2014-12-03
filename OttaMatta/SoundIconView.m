//
//  SoundIconView.m
//  OttaMatta
//
//  Created by John Baumbach on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundIconView.h"
#import "SoundManager.h"
#import "GlobalFunctions.h"
#import "QSStrings.h"
#import "JSONKit.h"

@implementation SoundIconView
@synthesize delegate;
@synthesize theSound;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize iconCornerRadius;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

//
// Sometimes this happens instead of the frame version (if from IB)
//
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initView];
    }
    return self;
}

//
// If inited from code, this happens.
//
-(id)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}

-(void)dealloc
{
    self.delegate = nil;
    self.theSound = nil;
    
    self.activeDownload = nil;
    [imageConnection cancel];
    self.imageConnection = nil;
    
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) initView
{
    // DLog(@"View is initing");
    
    self.layer.cornerRadius = 8.0f;
    self.clipsToBounds = YES;
    //self.backgroundColor = [UIColor greenColor];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedGesture:)];
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release];
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
                                                                                                              
    
}

//
// Called when the sound is set by the parent.  Load the icon from local storage
// or d/l it from the server.
//
-(void)setTheSound:(Sound *)aSound
{
    // DLog(@"Setting sound object!");
    
    [theSound release];

    if (aSound != nil)
    {
        theSound = [aSound retain];
        [self loadOrGetIcon];
    }
}

//
// Set the radius of the icon
//
-(void) setIconCornerRadius:(float)newIconRadius
{
    self.layer.cornerRadius = newIconRadius;
}

-(void) loadOrGetIcon
{
    if (theSound.shouldDownloadIcon)
    {
        [self getIcon];
    }
    else
    {
        [self setIconInView];
    }
}

//
// Start the download of the icon from the server if we don't already have it
//
-(void) getIcon
{
    
    if (theSound.shouldDownloadIcon)
    {
        //
        // This code is direct from the Apple docs.  It starts the d/l.  The callbacks
        // grab the data.
        //
        NSString *url = [Config soundIconUrlForId:theSound.soundId];
        
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
        self.imageConnection = conn;
        [conn release];
    }    

}

-(void) setIconInView
{

    NSData *iconData = [theSound getIconData];
    
    if ([iconData isKindOfClass:[NSData class]])
    {
        //
        // Remove all current views (most likely the spinny progress thingy)
        //
        [[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        
        UIImage *image = [[[UIImage alloc] initWithData:iconData] autorelease];
        UIImageView *imgView = [[[UIImageView alloc] initWithImage:image] autorelease];
        imgView.frame = [self bounds];
        
        [self addSubview:imgView];
        
        // call our delegate and tell it that our icon is ready for display
        [self setNeedsDisplay];
    }
    else
    {
        DLog(@"Oops, unable to get icon data even though we should have it!");
    }
}

-(void) setIconWithData:(NSData *)data
{
    theSound.imageData = data;
    theSound.iconSrcType = istLocalData;
    [self setIconInView];
}

-(void) longPressedGesture:(UIGestureRecognizer *)gestureRecognizer
{
    DLog(@"longPressedGesture");
    
    if (delegate && [delegate respondsToSelector:@selector(longPressedForSound:)] && gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [delegate longPressedForSound:theSound];
    }
}

-(void) tapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    DLog(@"tapGesture");

    if (delegate && [delegate respondsToSelector:@selector(pressedForSound:)] && gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [delegate pressedForSound:theSound];
    }
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
    
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // DLog(@"Download complete!");
        
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    NSDictionary *dataResults = [jsonString objectFromJSONString];
    
    NSString *iconHash = [dataResults objectForKey:@"md5hash"];
    NSString *iconData64 = [dataResults objectForKey:@"datasixtyfour"];
    
    NSData *decodedIconData = [QSStrings decodeBase64WithString:iconData64];
    NSString *decodedIconMd5 = [decodedIconData md5];
    BOOL downloadSuccess = [decodedIconMd5 isEqualToString:iconHash];
    //int soundId = [[dataResults objectForKey:@"soundid"] intValue];
    
    // DLog(@"Found MD5 hash of: %@, expected %@, is same? %d", decodedIconMd5, iconHash, downloadSuccess);
    
    if (downloadSuccess)
    {
        theSound.imageData = decodedIconData;
        [SoundManager serializeSound:theSound];
        
        /*
        if (iconDownloadDelegate && [iconDownloadDelegate respondsToSelector:@selector(soundIconDownloadedForId:withData:)])
        {
            [iconDownloadDelegate soundIconDownloadedForId:soundId withData:decodedIconData];
        }
         */
    }

    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [self setIconInView];
    
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
