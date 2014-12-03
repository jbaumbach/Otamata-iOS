//
//  SendEmailController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendEmailController.h"

#import "Config.h"
#import "GDataXMLNode.h"
#import "OtamataFunctions.h"
#import "GlobalFunctions.h"

@implementation SendEmailController
@synthesize includeDiagnostics;
@synthesize subject;
@synthesize body;
@synthesize parent;
@synthesize delegate;

//
// Todo: refactor this for more efficiency with the generic emailer.  For example, there
// is no reason to set a defaut body since it's going to get replaced anyway.
//
-(id) initWithParent:(UIViewController *)theParent
{
    if (self = [super init])
    {
        includeDiagnostics = YES;
        self.subject = [NSString stringWithFormat:@"Contact Us", [GlobalFunctions appName]];
        self.body = [self defaultBody];
        self.parent = theParent;
    }
    return self;
}

-(void)dealloc
{
    self.subject = nil;
    self.body = nil;
    self.parent = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
    DLog(@"Email send with result: %@, and error: %@", [OtamataFunctions emailResultFromEnum:result], error);
    [controller dismissModalViewControllerAnimated:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(sendEmailCompleteWithStatus:)])
    {
        [delegate sendEmailCompleteWithStatus:result];
    }
    else
    {
        DLog(@"No 'SendEmailProtocol' delegate defined!  Just gonna hang out then.");
    }
}

-(void) showNoEmailMsg
{
    // Can't send email
    UIAlertView *dlg = [[[UIAlertView alloc] initWithTitle:@"Email Setup" message:@"Your device currently isn't configured to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [dlg show];
}

-(void) sendContactUsEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailDialog = [[[MFMailComposeViewController alloc] init] autorelease];
        mailDialog.mailComposeDelegate = self;
        
        //
        // Note: setting the title doesn't do anything, it's always the subject
        //
        [mailDialog setTitle:[NSString stringWithFormat:@"Contact %@", [GlobalFunctions appName]]];
        [mailDialog setSubject:subject];
        [mailDialog setMessageBody:body isHTML:NO];
        
        mailDialog.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];


        if (includeDiagnostics)
        {
            GDataXMLDocument *userInfo = [OtamataFunctions getDeviceDataAsXML];
            [mailDialog addAttachmentData:[userInfo XMLData] mimeType:@"text/xml" fileName:DIAGNOSTIC_INFO_FNAME];
        }
        
        [mailDialog setToRecipients:[NSArray arrayWithObject:EMAIL_GENERAL]];
        [parent presentModalViewController:mailDialog animated:YES];
        
    }
    else
    {
        [self showNoEmailMsg];
    }
}

//
// Send generic email.  Set title and body on the instance before calling this.
//
-(void) sendGenericEmailWithTitle:(NSString *)title Recipients:(NSArray *)recipients
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailDialog = [[[MFMailComposeViewController alloc] init] autorelease];
        mailDialog.mailComposeDelegate = self;
        
        //
        // Note: setting the title doesn't do anything, it's always the subject
        //
        // [mailDialog setTitle:@"Ugga bugga"];
        [mailDialog setSubject:subject];
        [mailDialog setMessageBody:body isHTML:NO];
        
        mailDialog.navigationBar.tintColor = [UIColor colorWithHexString:NAVBAR_TINT];
        
        if (recipients != nil)
        {
            [mailDialog setToRecipients:recipients];
        }
        
        [parent presentModalViewController:mailDialog animated:YES];
        
    }
    else
    {
        [self showNoEmailMsg];
    }
}

-(NSMutableString *) defaultBody
{
    NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
    
    [result appendString:@"\r\n\r\n\r\nThe following details are some diagnostic settings from your device.  These settings "];
    [result appendString:@"will help us diagnose any issues you might be having.  "];
     
    if (includeDiagnostics)
    {
        [result appendFormat:@"The same info is also included in the attached file \"%@\"", DIAGNOSTIC_INFO_FNAME];        
    }
    
    [result appendFormat:@"\r\n\r\n%@", [OtamataFunctions getDeviceData]];
    
    return result;
}
@end
