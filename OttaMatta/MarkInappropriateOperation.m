//
//  MarkInappropriateOperation.m
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkInappropriateOperation.h"

#import "JSONKit.h"
#import "Config.h"


@implementation MarkInappropriateOperation

#pragma mark - Instance Methods

-(void) markInappropriate:(Sound *)theSound 
{
    NSString *url = [Config markInappropriateUrl];
    
    self.activeDownload = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *formBody = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@", 
                          qsSoundId, theSound.soundId,
                          qsDeviceId, [Config getUUID],
                          qsAppVersion, [GlobalFunctions appPublicVersion] ];

    
    [request setHTTPBody:[formBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:10];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
    [conn release];
}

-(void) markCompleteWithStatus:(int)status
{
    DLog(@"Rating complete!");
    
    [super dismissDialogWithStatus:status];
}

#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DLog(@"Got some data!");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Failed with error! %@", error.localizedDescription);
    [self markCompleteWithStatus:1];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Download complete!");
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    DLog(@"Here is what we got %@", jsonString);
    NSDictionary *jsonData = [jsonString objectFromJSONString];
    
    SendDialogStatusCode resultCode = [SendingDialogView resultFromServerResponse:jsonData];

    NSString *resultDescription = [jsonData objectForKey:@"description"];
    
    DLog(@"Received result of %d with desc \"%@\"", resultCode, resultDescription);
    
    [self markCompleteWithStatus:resultCode];    
}

@end
