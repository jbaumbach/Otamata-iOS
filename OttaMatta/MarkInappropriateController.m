//
//  MarkInappropriateController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkInappropriateController.h"
#import "MarkInappropriateOperation.h"


@implementation MarkInappropriateController
@synthesize parentView;
@synthesize sound;
@synthesize delegate;

-(id)initWithSound:(Sound *)theSound andView:(UIView *)view withDelegate:(id<SendDialogViewComplete>)theDelegate;
{
    if (self = [super init])
    {
        self.sound = theSound;
        self.parentView = view;
        self.delegate = theDelegate;
    }
    
    return self;
}

-(void)dealloc
{
    self.sound = nil;
    self.parentView = nil;
    self.delegate = nil;
    
    [super dealloc];
}

-(void)markSoundAsInappropriate
{
    //
    // Bring up 'Are you sure?' dialog.  The actual action is in the delegate.
    //
    NSString *message = [NSString stringWithFormat:@"Really mark \"%@\" as inappropriate?", self.sound.name];
    
    UIAlertView *box = [[[UIAlertView alloc] initWithTitle:@"Mark Inappropriate" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    
    [box show];

}

#pragma mark - AlertViewDelete protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"The inapproprate alert with answered with index: %d", buttonIndex);
    
    if (buttonIndex == 1)
    {
        //
        // Mark sound as inappropriate
        //
        MarkInappropriateOperation *view = [[MarkInappropriateOperation alloc] initWithFrame:parentView.frame];
        [parentView addSubview:view];
        view.delegate = self;
        [view markInappropriate:self.sound];
        
    }
}

#pragma mark - SendDialogViewComplete protocol

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status
{
    //
    // User marked sound as inappropriate. Ask to move to trash.
    //
    if (delegate && [delegate respondsToSelector:@selector(sendCompleteWithStatus:)])
    {
        [delegate sendCompleteWithStatus:status];
    }
    else
    {
        DLog(@"Well, protocol not implemented, I guess nothing will happen now.");
    }
}
@end
