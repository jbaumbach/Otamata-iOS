//
//  ShareSoundHelperController.m
//  Otamata
//
//  Created by John Baumbach on 5/2/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Twitter/Twitter.h>
#import "ShareSoundHelperController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "SendingDialogView.h"
#import "OttaAppDelegate.h"

//
// Otamata Facebook app id - from their site after adding this app
//
//static NSString* kAppId = @"269490483146896";

@implementation ShareSoundHelperController
@synthesize smsToFriendController;
@synthesize parentController;
@synthesize delegate;
@synthesize shareConfig;
@synthesize emailer;
@synthesize facebook;

-(void) dealloc
{   
    self.delegate = nil;
    self.smsToFriendController = nil;
    self.shareConfig = nil;
    self.parentController = nil;
    self.emailer = nil;
    self.facebook = nil;
    
    DLog(@"ShareSoundHelperController instance %@ dealloc'ing", self);
    
    //
    // Remove us as observer, or app crashes when this object is dealloc'd.
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


#pragma mark - SMS Sharing

-(void) shareViaSMS
{
    //
    // Don't init this property twice.  It over-releases the parent controller!
    //
    if (self.smsToFriendController == nil)
    {
        self.smsToFriendController = [[[SmsToFriendController alloc] initWithParent:parentController] autorelease];
        self.smsToFriendController.delegate = self;
    }
    
    [smsToFriendController sendToFriend:shareConfig];
}

#pragma mark - Email sharing

-(void) shareViaEmail
{
    if (self.emailer == nil)
    {
        self.emailer = [[[SendEmailController alloc] initWithParent:parentController] autorelease];
    }
    
    emailer.body = [NSString stringWithFormat:@"I've sent you a sound.  Click this link to play it:\r\n\r\n%@", [self urlForCurrentSound]];
    
    emailer.subject = @"Check out this sound";
    emailer.delegate = self;
    [emailer sendGenericEmailWithTitle:@"Send Sound" Recipients:nil];
}

#pragma mark - Url copy to clipboard

-(void) shareViaUrl
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *currentUrl = [self urlForCurrentSound];
    
    pasteboard.string = currentUrl;
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Copied to Clipboard" message:[NSString stringWithFormat:@"The url '%@' has been copied to your clipboard.  Open any app and paste it in.  Enjoy.", currentUrl] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
    [alert show];
    
    [self shareCompleteWithResult:0];

}

#pragma mark - Twitter sharing

-(void) shareViaTwitter
{
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = 
        [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:@"Check out this sound."];
        
        //
        // The order added here is the order the pics go underneath the paper clip thingy
        //
        
        UIImage *theImage;
        NSData *iconData = [shareConfig.currentSound getIconData];

        if (shareConfig.CurrentType == sstFullSoundDetails && shareConfig.currentSound.hasIcon && [iconData isKindOfClass:[NSData class]])
        {
            theImage = [[[UIImage alloc] initWithData:iconData] autorelease];
        }
        else
        {
            theImage = [UIImage imageNamed:@"default-icon1.png"];
        }

        [tweetSheet addImage:theImage];
        [tweetSheet addURL:[NSURL URLWithString:[self urlForCurrentSound]]];
        
        //
        // This ^ thing is like an inline delegate function.  It appears to be called a "block" or something.
        // This seems to go against everything objective-c stands for?
        //
        TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result) 
        {
            switch (result)
            {
                case TWTweetComposeViewControllerResultCancelled:
                    DLog(@"Twitter Result: canceled");
                    break;
                case TWTweetComposeViewControllerResultDone:
                    DLog(@"Twitter Result: sent");
                    break;
                default:
                    DLog(@"Twitter Result: ummmmm...");
                    break;
            }
            
            //
            // When adding a completionhandler, you have to dismiss the twitter dialog manually
            //
            [self.parentController dismissModalViewControllerAnimated:YES];
            
            [self shareCompleteWithResult:0];
        };

        [tweetSheet setCompletionHandler:completionHandler];
        
        [self.parentController presentModalViewController:tweetSheet animated:YES];
        
        [tweetSheet release];
    }
    else
    {
        float iosVersion = [GlobalFunctions iosVersion];
        NSString *message;
        
        if (iosVersion < 5.0)
        {
            message = @"Otamata can't Tweet from this device.  We need version 5.0 or higher of iOS.";
        }
        else
        {
            message = @"Otamata can't tweet from this device.  Ensure that your Twitter settings allow this app to send tweets.";
        }
        
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [box show];
    }

}

#pragma mark - Facebook FBSessionDelegate implementation

//
// Behold!  The seeminly infinite amount of lines required to share with Facebook!
// Yay!
//
 
//
// Check out instructions here: https://developers.facebook.com/docs/mobile/ios/build/#register
//
// For testing, make sure posts are private.  This is selected during the authorize phase
// on the twitter dialog.  You can reset the authorization by going to FB (app or web) and
// deleting the Otamata app.  
//
// On main website:
//   * Log in -> Account Settings -> Apps (left side) -> Click "X" to remove
//
//

//
// Invalidate the Facebook stuff so a login will have to happen again.
//
-(void) invalidateFacebookAuthorization
{
    self.facebook.accessToken = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"FBAccessTokenKey"];
    
    //
    // Broadcast a message so if anyone's listening, they can respond appropriately
    // Hint: the FB UI dialog listens, and bails if it gets this.  Usually
    // this only happens during dev when you manually delete the app from
    // your FB "Apps" preferences.
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:gmiFacebookIdInvalidated object:nil];
}

//
// This typically happens after authorizing for the first time, or the token expired.
//
- (void)fbDidLogin {
    DLog(@"fb: fbDidLogin");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self postToFacebookWithUI];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    DLog(@"fb: fbDidNotLogin");
    
    //
    // Note: the FB class doesnt have more detailed error info.  But, something didn't work.
    // Let's bomb outta here to perhaps address the weird memory warning we sometimes get.
    //
    [self shareCompleteWithResult:0];
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    DLog(@"fb: fbDidExtendToken: %@, expiry %@", accessToken, expiresAt);
}

- (void)fbDidLogout
{
    DLog(@"fb: fbDidLogout");
}

- (void)fbSessionInvalidated
{
    DLog(@"fb: fbSessionInvalidated");
    [self invalidateFacebookAuthorization];
}

#pragma mark - FBRequestDelegate

- (void)requestLoading:(FBRequest *)request
{
    DLog(@"fb: requestLoading");
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    DLog(@"fb: didReceiveResponse");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    //
    // todo: figure out why this is not working on 3GS phone.  The login
    // page webview looks very strange as well.
    //
    
    DLog(@"fb: didFailWithError: %@", error.description);
    
    [self dismissProgressSpinner];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    DLog(@"fb: didLoad");
    
    [self dismissProgressSpinner];
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    DLog(@"fb: didLoadRawResponse");
}



#pragma mark - Facebook sharing

-(void) showProgressSpinner
{
    //
    // Let's keep track of the spinner screen with a BOOL, just in case.  Don't want bad logic to make 
    // some UI craziness.  Although, a function to search the subviews for
    // the spinner might be more elegant.  Bah.  This works.
    //
    DLog(@"Gonna show spinner: %d", _isShowingProgressSpinner);
    
    if (!_isShowingProgressSpinner)
    {
        SendingDialogView *view = [[[SendingDialogView alloc] initWithFrame:parentController.view.frame] autorelease];
        [parentController.view addSubview:view];
        _isShowingProgressSpinner = YES;
        
        //
        // The spinner screen never shows up unless we let iOS do some stuff.
        // Plus, on a good connection, it flashes by too fast. 
        //
        [GlobalFunctions sleepAndProcessMessages:0.2];
    }
}

-(void) dismissProgressSpinner
{
    DLog(@"Gonna hide spinner: %d", _isShowingProgressSpinner);
    if (_isShowingProgressSpinner)
    {
        [parentController.view removeFromSuperview];
        _isShowingProgressSpinner = NO;
    }
}

- (BOOL) passFacebookAppChecks
{
    BOOL result = NO;
    
    // Check App ID:
    // This is really a warning for the developer, this should not
    // happen in a completed app
    if (!kFacebookAppId) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Setup Error"
                                  message:@"Missing app ID. You cannot run the app until you provide this in the code."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
        [alertView show];
        [alertView release];
    } else {
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize", kFacebookAppId];
        
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] &&
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Setup Error"
                                      message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil,
                                      nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            result = YES;
        }
    }
    
    return result;
}

-(void) postToFacebookWithUI
{
    DLog(@"Ok, finally, post to the graph thingy");
    
    //
    // Bring up the FB modal view, then post
    //
    SharingEnterSoundInfo *controller = [[[SharingEnterSoundInfo alloc] init] autorelease];
    controller.delegate = self;
    
    if (parentController != nil)
    {
        //
        // Sometimes waking up is slow and we get a weird modal transition
        // exception "while transition is already in progress".  Sleep a bit.
        //
        [GlobalFunctions processMessagesAndSleep:0.2];

        //
        // The user does stuff, then either continues or cancel.  See "SharingEnterSoundInfoDelegate"
        // for what happens then.
        // 
        [parentController presentModalViewController:controller animated:YES];
    }
    else
    {
        DLog(@"Crap, no parent controller!");
    }
}


-(void) shareViaFacebook
{
    _isShowingProgressSpinner = NO;
    
    if ([self passFacebookAppChecks])
    {
        if (self.facebook == nil)
        {
            self.facebook = [[[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:self] autorelease];
        }
        
        //
        // We've saved access tokens to the user defaults.  Get 'em back.
        //
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        //
        // Debugging: this tests going through the validation process each time.
        //
        //[self invalidateFacebookAuthorization];
        
        if (![self.facebook isSessionValid]) 
        {
            //
            // Let's try to add some specific permissions
            //
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"publish_actions",
                                    nil];
            
            //
            // When we are notified that the user came back to Otamata from FB, 
            // execute this function
            //
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnedFromFacebookAuth:) name:gmiReturnFromFBAuthorization object:nil];

            //
            // Note: this only brings up a login screen in a webview.  
            // Not like OMGPOP's app.
            // Todo: figure out why.  Although, maybe not crucial, the way it works
            // now does look excactly like the FB docs say it should look.  I
            // wonder what OMGPOP is doing.
            //
            [self.facebook authorize:permissions];
            [permissions release];
        }
        else
        {
            //
            // Extend the session if possible.  If the user deauth'd our app,
            // this will call some different delegate funcs that we can handle.
            //
            [self.facebook extendAccessToken];
            
            //
            // Bring up the UI to enter the post text; user can post or cancel.
            //
            [self postToFacebookWithUI];
        }
    }
    
}

#pragma mark - Safari sharing

-(void) shareViaSafari
{
    NSString *currentUrl = [self urlForCurrentSound];
    NSURL *url = [[[NSURL alloc] initWithString:currentUrl] autorelease];
    [[UIApplication sharedApplication] openURL:url];
    
    [self shareCompleteWithResult:0];
    
}

#pragma mark - Class Methods

-(void) doShare
{
    //
    // Share the sound here
    //
    switch (shareConfig.CurrentMethod) {
        case ssmSmsMessage:
            [self shareViaSMS];
            break;
            
        case ssmEmail:
            [self shareViaEmail];
            break;
            
        case ssmPlainUrl:
            [self shareViaUrl];
            break;
            
        case ssmTweet:
            [self shareViaTwitter];
            break;
            
        case ssmFacebook:
            [self shareViaFacebook];
            break;
            
        case ssmSafariPreview:
            [self shareViaSafari];
            break;
            
        default:
            [NSException raise:@"Unknown share method!" format:nil];
            break;
    }
    
}

//
// All of the various share methods should finish up by calling this method
//
-(void) shareCompleteWithResult:(int)result
{
    if ([delegate respondsToSelector:@selector(shareCompleteWithResult:)])
    {
        [delegate shareCompleteWithResult:result];
    }
    else
    {
        DLog(@"Crap - no delegate defined!  would have returned value: %d", result);
    }
}

-(NSString *) urlForCurrentSoundIcon
{
    return [Config soundPlayerIconUrl:[shareConfig.currentSound getServerSoundId] playerVersion:spvVersion1 displayType:shareConfig.CurrentType];
}

-(NSString *) urlForCurrentSound
{
    if ([shareConfig.currentSound isOnServer])
    {
        return [Config soundPlayerUrl:[shareConfig.currentSound getServerSoundId] playerVersion:spvVersion1 displayType:shareConfig.CurrentType];
    }
    else
    {
        //
        // This should never happen, always make sure the sound is on the server before getting to this point.
        //
        [NSException raise:@"urlForCurrentSound" format:@"The current sound is not on the server - no url can be created"];
        return @"";
    }
}

//
// Process the notification that we returned from FB auth
//
-(void) returnedFromFacebookAuth:(NSNotification *)notification
{
    DLog(@"Got notification msg: %@", notification);
    
    //
    // Tell the FB thingy that we have a url.  It'll have tokens and junk.  Then
    // it'll call delegate funcs on [self] that will do more stuff.
    //
    NSURL *url = notification.object;

    [self.facebook handleOpenURL:url];
}



#pragma mark - SmsToFriendDelegate implementation

-(void) sendCompleteWithResult:(MessageComposeResult)result
{    
    [self shareCompleteWithResult:0];
}

#pragma mark - SendEmailProtocol implementation

-(void) sendEmailCompleteWithStatus:(MFMailComposeResult)status
{
    [self shareCompleteWithResult:0];
}

#pragma mark - SharingEnterSoundInfoDelegate implementation

//
// Right now, this is only supporting Facebook.  It can be extended to support other
// stuff too, probably need to add an additional parameter.
//
-(void) userAction:(ModalResult)action withTitle:(NSString *)title andText:(NSString *)text
{
    //
    // The user did something
    //  
    if (action == mrOK)
    {
        //
        // "Send" clicked
        //
        [parentController dismissModalViewControllerAnimated:NO];

        //
        // A spinner progress screen 
        //
        [self showProgressSpinner];
        
        //
        // Use the actual picture for the post if we need to
        //
        NSString *imgUrl;
        
        if (shareConfig.CurrentType == sstFullSoundDetails && shareConfig.currentSound.hasIcon)
        {
            imgUrl = [self urlForCurrentSoundIcon];
        }
        else
        {
            imgUrl = [Config genericSoundUrl];
        }
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       kFacebookAppId, @"app_id",
                                       [self urlForCurrentSound], @"link",
                                       title, @"name",
                                       text, @"description",
                                       imgUrl, @"picture",
                                       @"Click to play", @"caption",
                                       nil];
        
        //
        // Note: if you omit a caption, it'll plug in your website (www.otamata.com)                                   
        //
        
        //
        // This posts directly to their feed.  Boom.
        //
        [self.facebook requestWithGraphPath:@"me/feed"
                                              andParams:params
                                          andHttpMethod:@"POST"
                                            andDelegate:self];
        
    }
    else
    {
        //
        // Cancel clicked
        //
        [parentController dismissModalViewControllerAnimated:YES];
    }
    
    [self shareCompleteWithResult:0];
}

@end
