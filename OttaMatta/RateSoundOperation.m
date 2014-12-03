//
//  RateSoundOperation.m
//  OttaMatta
//
//  Created by John Baumbach on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RateSoundOperation.h"

#import "Config.h"
#import "JSONKit.h"
#import "GlobalFunctions.h"

@implementation RateSoundOperation

#pragma mark - Instance Methods

-(void) rateSound:(Sound *)theSound withRating:(int)rating userText:(NSString *)userText
{
    NSString *url = [Config rateSoundUrl];
    
    self.activeDownload = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSString *encodedUserText = [GlobalFunctions urlEncodedString:userText]; //[userText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *formBody = [NSString stringWithFormat:@"%@=%@&%@=%d&%@=%@&%@=%@&%@=%@", 
                          qsSoundId, theSound.soundId, 
                          qsRating, rating, 
                          qsText, encodedUserText, 
                          qsDeviceId, [Config getUUID],
                          qsAppVersion, [GlobalFunctions appPublicVersion] ];
    
    [request setHTTPBody:[formBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:10];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
    [conn release];
}

-(void) ratingCompleteWithStatus:(int)status
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
    [self ratingCompleteWithStatus:1];
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
    
    [self ratingCompleteWithStatus:resultCode];    
}
@end
