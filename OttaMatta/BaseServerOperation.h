//
//  BaseServerOperation.h
//  OttaMatta
//
//  Created by John Baumbach on 2/2/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalFunctions.h"
#import "Config.h"
#import "SendingDialogView.h"

//
// This base class is very similar to SendingDialogView except there's no progress overlay.
//
// I didn't see a great way to implement the connection delegate as shared code since
// there's no multiple inheritance in objective-c.  There may be a better way than this.
//
@interface BaseServerOperation : NSObject

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) id<SendDialogViewComplete> delegate;
@property (nonatomic, retain) NSString *key;    // In case you have multiple dialogs on a single form, set this

+(SendDialogStatusCode) resultFromServerResponse:(NSDictionary *)jsonData;

@end
