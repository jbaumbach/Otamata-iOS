//
//  UploadSoundOperation.m
//  Otamata
//
//  Created by John Baumbach on 6/6/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "UploadSoundOperation.h"

#import "JSONKit.h"
#import "Config.h"
#import "QSStrings.h"

@implementation UploadSoundOperation

#pragma mark - Instance Methods

-(void) uploadSound:(Sound *)theSound isBrowsable:(BOOL)isBrowsable
{
    self.type = dtProgressBar;
    self.progress = 0.0;
    
    _serverResultHTTPStatusCode = -1;
    
    NSString *url = [Config uploadSoundUrl];
    
    self.activeDownload = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    //
    // todo: consider sanitizing the input.  this will be on a website at some point.  Check out 
    // what i'm doing in default.aspx.
    //
    
    NSString *formBody = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                          qsName, [GlobalFunctions urlEncodedString:theSound.name],
                          qsSoundFName, theSound.filename,
                          qsDescription, [GlobalFunctions urlEncodedString:theSound.soundDescription],
                          
                          qsUserId, [GlobalFunctions urlEncodedString:theSound.uploadedBy],   
                          qsSoundData, [GlobalFunctions urlEncodedString:[QSStrings encodeBase64WithData:theSound.soundData]],
                          qsSoundDataMd5, [theSound.soundData md5],
                          
                          qsIconFName, @"userimg.jpg",
                          qsIconData, [GlobalFunctions urlEncodedString:[QSStrings encodeBase64WithData:theSound.imageData]],
                          qsIconDataMd5, [theSound.imageData md5],
                          
                          qsIsBrowsable, isBrowsable ? @"1" : @"0",
                          qsDeviceId, [Config getUUID],
                          qsAppVersion, [GlobalFunctions appPublicVersion] ];
    
    [request setHTTPBody:[formBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    DLog(@"Form body should be size of: %d", [request.HTTPBody length])
    
    [request setTimeoutInterval:10];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
    [conn release];
}

-(void) markCompleteWithStatus:(int)status andObject:(id)object
{
    DLog(@"Upload complete!");
    
    [super dismissDialogWithStatus:status andObject:object];
}

#pragma mark - Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DLog(@"Got some data!");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    _serverResultHTTPStatusCode = [httpResponse statusCode];
    
    DLog(@"Got a response!  HTTP status code of: %d (%@)", _serverResultHTTPStatusCode, [NSHTTPURLResponse localizedStringForStatusCode:_serverResultHTTPStatusCode]);

    //
    // For debugging weird server issue - print out all the headers
    //
    NSDictionary *headers = [httpResponse allHeaderFields];
    
    for (NSString *key in headers.allKeys) {
        DLog(@"  %@ -> %@", key, [headers objectForKey:key]);
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    DLog(@"sendingBodyData, so far: %d, total so far: %d, expected total: %d", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    //
    // percentage = 100 * totalBytesWritten / totalBytesExpectedToWrite
    //
    if (totalBytesExpectedToWrite > 0)
    {
        self.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Failed with error! %@", error.localizedDescription);
    [self markCompleteWithStatus:sdvError andObject:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Download complete!");
    
    NSString *jsonString = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    DLog(@"Here is what we got %@", jsonString);
    NSDictionary *jsonData = [jsonString objectFromJSONString];
    
    
    if (_serverResultHTTPStatusCode != 200)
    {
        //
        // This generally will happen if something bad happens
        //
        SendDialogStatusCode resultCode = [SendingDialogView resultFromServerResponse:jsonData];
        NSString *resultDescription = [jsonData objectForKey:@"description"];
        
        DLog(@"Received result of %d with desc \"%@\"", resultCode, resultDescription);
    
        [self markCompleteWithStatus:resultCode andObject:nil];    
    }
    else
    {
        //
        // If success, a sound object will be returned with our new server sound id
        //
        Sound *resultSound = [[[Sound alloc] initWithDictionary:jsonData] autorelease];
        
        [self markCompleteWithStatus:sdvSuccess andObject:resultSound];
    }
}


@end
