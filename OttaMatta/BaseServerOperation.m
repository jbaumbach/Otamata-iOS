//
//  BaseServerOperation.m
//  OttaMatta
//
//  Created by John Baumbach on 2/2/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "BaseServerOperation.h"

@implementation BaseServerOperation
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize delegate;
@synthesize key;


-(void)dealloc
{
    activeDownload = nil;
    imageConnection = nil;
    
    [super dealloc];
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

//
// Hmmmm... some technical debt incurred here.  The response should be simple, but
// I've confused the issue by also letting it be the HTTP status code. 
// Well, svdSuccess means success, otherwise you'll get svdError or some other number.
//
+(SendDialogStatusCode) resultFromServerResponse:(NSDictionary *)jsonData
{
    // Here is what we got {"reason":"Value for soundid must be numeric.","statuscode":400}
    // Here is what we got {"code":0,"description":"Success"}
    SendDialogStatusCode result = sdvError;
    
    if ([jsonData objectForKey:@"code"])
    {
        result = [[jsonData objectForKey:@"code"] intValue];
    }

    return result;
}

@end
