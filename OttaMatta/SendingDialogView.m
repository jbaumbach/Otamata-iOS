//
//  SendingDialogView.m
//  OttaMatta
//
//  Created by John Baumbach on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendingDialogView.h"
#import "BaseServerOperation.h"

@implementation SendingDialogView
@synthesize type;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize delegate;
@synthesize key;
@synthesize progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;

        //
        // Init some more goodies.  Note: the background color must be "ClearColor" in IB 
        // for this class to have the rounded corners.
        //
        _itemView = [GlobalFunctions initClassFromNib:[SendingDialogViewItems class]];
        [GlobalFunctions centerView:_itemView inFrame:frame];
        [self setType:dtSpinner];
        
        [self addSubview:_itemView];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    const CGFloat BACKGROUND_OPACITY = 0.75;
    
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
    CGContextFillRect(context, rect);    
}

-(void)setType:(DialogType)newType
{
    if (newType == dtSpinner)
    {
        [_itemView.progressView setHidden:YES];
        [_itemView.spinnerView setHidden:NO];
        [_itemView.statusDetailLabel setHidden:YES];
    }
    else
    {
        [_itemView.progressView setHidden:NO];
        [_itemView.spinnerView setHidden:YES];
        [_itemView.statusDetailLabel setHidden:YES];
    }
    
    type = newType;
}

-(void)dealloc
{
    [_itemView release];
    activeDownload = nil;
    imageConnection = nil;
    
    [super dealloc];
}

//
// Call this function from your subclass
//
-(void) dismissDialogWithStatus:(SendDialogStatusCode)status
{
    [self removeFromSuperview];

    if (delegate)
    {
        if (key != nil && [delegate respondsToSelector:@selector(sendCompleteWithStatus:forKey:)])
        {
            [delegate sendCompleteWithStatus:status forKey:self.key];
        }
        else if ([delegate respondsToSelector:@selector(sendCompleteWithStatus:)])
        {
            [delegate sendCompleteWithStatus:status];
        }
    }
}

//
// Or, call this function from your subclass
//
-(void) dismissDialogWithStatus:(SendDialogStatusCode)status andObject:(id)object
{
    [self removeFromSuperview];
    
    if ([delegate respondsToSelector:@selector(sendCompleteWithStatus:forKey:andObject:)])
    {
        [delegate sendCompleteWithStatus:status forKey:self.key andObject:object];
    }
    else
    {
        DLog(@"Crap, we're going to exit but no one will know about it because there's no delegate.  I wonder, will it really exit if no one is there to know about it?  Like that tree in a forest thing.");
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

+(SendDialogStatusCode) resultFromServerResponse:(NSDictionary *)jsonData
{
    return [BaseServerOperation resultFromServerResponse:jsonData];
}

-(void) setProgress:(float)newProgress
{
    DLog(@"Setting progress in SendingDialogView to %f", newProgress);
    
    _itemView.progressView.progress = newProgress;
    [GlobalFunctions sleepAndProcessMessages:0.1];
    
}
@end
