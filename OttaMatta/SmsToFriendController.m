//
//  SendToFriendController.m
//  Otamata
//
//  Created by John Baumbach on 3/25/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "SmsToFriendController.h"
#import "GlobalFunctions.h"
#import "Config.h"

@implementation SmsToFriendController

@synthesize parent;
@synthesize delegate;

-(id) initWithParent:(UIViewController *)theParent
{
    if (self = [super init])
    {
        parent = theParent;
    }
    return self;
}

-(void)dealloc
{
    self.parent = nil;
 
    [super dealloc];
}

-(void) sendToFriend:(ShareSoundConfig *)theSound
{
    NSString *playerUrl = [Config soundPlayerUrl:[theSound.currentSound getServerSoundId] playerVersion:spvVersion1 displayType:theSound.CurrentType];
    DLog(@"final url: %@", playerUrl);
    
    
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
        controller.body = [NSString stringWithFormat:@"I've sent you a sound.  Click this link to play it: %@", playerUrl];
        
        [controller setTitle:@"Send Sound"];
        controller.messageComposeDelegate = self;
        
        controller.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];
        
        [parent presentModalViewController:controller animated:YES];
    }
    else
    {
        UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"It looks like Otamata can't send SMSs on this device!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [box show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //
    // This dismisses the MFMessageComposeViewController if there is one
    //
    [parent dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled)
    {
        DLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent)
    {
        DLog(@"Message sent");  
    }
    else 
    {
        //
        // Note: this can also happen if the user can't send SMSs 
        //
        DLog(@"Message failed");
    }
    
    if ([delegate respondsToSelector:@selector(sendCompleteWithResult:)])
    {
        [delegate sendCompleteWithResult:result];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self messageComposeViewController:nil didFinishWithResult:MessageComposeResultFailed];
}
@end
