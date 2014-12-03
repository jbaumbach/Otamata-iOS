//
//  WebsearchHistory.h
//  Otamata
//
//  Created by John Baumbach on 7/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebsearchHistory : NSObject

//
// Instance Properties
//
@property (nonatomic, retain) NSString *term;
@property int resultCount;
@property (nonatomic, retain) NSDate *searchDate;

//
// Instance Methods
// 
-(id)initWithCoder:(NSCoder *)dictionary;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(NSString *)cleanTerm;

//
// Static Methods - todo: make this a separate manager class
//
+(NSString *)searchHistoryPath;
+(NSMutableArray *)getSearchHistory;
+(void) setSearchHistory:(NSMutableArray *)searchHistory;
+(void) saveSearch:(NSString *)theSearchTerm withResultCount:(int)count;
+(void) upsertSearch:(WebsearchHistory *)search inList:(NSMutableArray *)searchHistory;
@end
