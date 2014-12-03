//
//  WebsearchResultSite.h
//  Otamata
//
//  Created by John Baumbach on 7/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebsearchSound.h"

@interface WebsearchResultSite : NSObject

@property (nonatomic, retain) NSString *siteName;
@property (nonatomic, retain) NSMutableArray *sounds;

@end
