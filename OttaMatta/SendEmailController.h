//
//  SendEmailController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

#define DIAGNOSTIC_INFO_FNAME   @"diagnosticInfo.xml"



@protocol SendEmailProtocol <NSObject>

-(void) sendEmailCompleteWithStatus:(MFMailComposeResult)status;

@end

@interface SendEmailController : NSObject
    <MFMailComposeViewControllerDelegate>

@property BOOL includeDiagnostics;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSMutableString *body;
@property (nonatomic, retain) UIViewController *parent;
@property (nonatomic, retain) id<SendEmailProtocol> delegate;


-(id) initWithParent:(UIViewController *)theParent;
-(void) sendContactUsEmail;
-(NSMutableString *) defaultBody;
-(void) showNoEmailMsg;
-(void) sendGenericEmailWithTitle:(NSString *)title Recipients:(NSArray *)recipients;


@end
