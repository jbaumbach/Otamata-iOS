//
//  RecordStorePurchase.m
//  OttaMatta
//
//  Created by John Baumbach on 2/2/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "RecordStorePurchase.h"
#import "JSONKit.h"

@implementation RecordStorePurchase

#pragma mark - Instance Methods

-(void) recordPurchase:(NSString *)purchaseId forUser:(NSString *)userId 
{
    NSString *url = [Config recordPurchaseUrl];
    
    self.activeDownload = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSString *formBody = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@", 
                          qsPurchaseId, purchaseId, 
                          qsDeviceId, [Config getUUID],
                          qsAppVersion, [GlobalFunctions appPublicVersion] ];

    
    [request setHTTPBody:[formBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:10];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
    [conn release];
}

-(void) recordCompleteWithStatus:(SendDialogStatusCode)status
{
    DLog(@"Purchase recording complete, status = %d", status);
    
    if ([self.delegate respondsToSelector:@selector(sendCompleteWithStatus:)])
    {
        [self.delegate sendCompleteWithStatus:status];
    }
    else
    {
    }
}

#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DLog(@"Got some data!");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Purchase recording failed with error! %@", error.localizedDescription);
    [self recordCompleteWithStatus:sdvError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Purchase recording - download complete!");
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    DLog(@"Here is what we got %@", jsonString);
    NSDictionary *jsonData = [jsonString objectFromJSONString];
    
    SendDialogStatusCode resultCode = [SendingDialogView resultFromServerResponse:jsonData];

    NSString *resultDescription = [jsonData objectForKey:@"description"];
    
    DLog(@"Received result of %d with desc \"%@\"", resultCode, resultDescription);
    
    [self recordCompleteWithStatus:resultCode];    
}
@end
