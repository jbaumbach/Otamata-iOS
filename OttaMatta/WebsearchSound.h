//
//  WebsearchSound.h
//  Otamata
//
//  Created by John Baumbach on 7/7/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebsearchSound : NSObject


@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *soundId;
@property (nonatomic, retain) NSData *soundData;
@property long size;
@property (nonatomic, retain) NSString *term;
@property (nonatomic, retain) NSString *sourceUrl;
@property (nonatomic, retain) NSString *md5hash;

+(NSString *)otamataWebsoundSerializedFileExtension;
-(BOOL) hasSoundData;
@end
