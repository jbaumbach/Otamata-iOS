//
//  WebsearchHistory.m
//  Otamata
//
//  Created by John Baumbach on 7/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "WebsearchHistory.h"
#import "GlobalFunctions.h"

@implementation WebsearchHistory
@synthesize term;
@synthesize resultCount;
@synthesize searchDate;


-(void)dealloc
{
    self.term = nil;
    self.searchDate = nil;
    
    [super dealloc];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%d) at %@", self.term, self.resultCount, self.searchDate];
}

#pragma mark - Serialization

-(id)initWithCoder:(NSCoder *)dictionary
{
    //
    // Deserialize from the passed data.  This dictionary was typically read from a serialized file.
    //
    if (self = [super init]) {
        self.term = [dictionary decodeObjectForKey:@"term"];
        self.resultCount = [dictionary decodeIntForKey:@"resultCount"];
        self.searchDate = [dictionary decodeObjectForKey:@"searchDate"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //
    // Take all the properties and put them into the passed encode.  This is done right before
    // writing the encoded data to a storage medium (like a disk file).
    //
    [aCoder encodeObject:term forKey:@"term"];
    [aCoder encodeInt:resultCount forKey:@"resultCount"];
    [aCoder encodeObject:searchDate forKey:@"searchDate"];
}

-(NSString *)cleanTerm
{
    return [[self.term lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(BOOL)isEqual:(id)object
{
    bool result = NO;
    
    if ([object isKindOfClass:[WebsearchHistory class]])
    {
        NSString *str1 = [self cleanTerm];
        NSString *str2 = [((WebsearchHistory *) object) cleanTerm];
        result = [str1 isEqualToString:str2];
    }
        
    return result;
}

#pragma mark - Search History Manager

+(NSString *)searchHistoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    
    NSString *serializedDataPath = [NSString stringWithFormat:@"%@/searchhistory.bin", documentsDirectory];

    return serializedDataPath;
}

//
// Return the current list, or nil.
//
+(NSMutableArray *)getSearchHistory
{
    NSString *path = [self searchHistoryPath]; 
    NSDictionary *rootObject; 
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path]; 
    NSMutableArray *currentHistory = [rootObject valueForKey:@"searchhistory"];
    
    if (currentHistory != nil && [currentHistory count] > 1)
    {
        NSArray *sortedHistory = [currentHistory sortedArrayUsingComparator: ^(id obj1, id obj2) 
        {
            WebsearchHistory *ws1 = (WebsearchHistory *)obj1;
            WebsearchHistory *ws2 = (WebsearchHistory *)obj2;
            
            //
            // Order search history by search date
            //
            return [ws2.searchDate compare:ws1.searchDate];
        }];
        
        return [NSMutableArray arrayWithArray:sortedHistory];
    }
    else
    {
        return  currentHistory;
    }
}

//
// Save the current list
//
+(void) setSearchHistory:(NSMutableArray *)searchHistory
{
    if (searchHistory == nil)
    {
        DLog(@"Warning: saving nil as the array.");
    }
    
    NSString *path = [self searchHistoryPath]; 
    NSMutableDictionary *rootObject; 
    rootObject = [NSMutableDictionary dictionary]; 
    [rootObject setValue:searchHistory forKey:@"searchhistory"]; 
    [NSKeyedArchiver archiveRootObject:rootObject toFile: path]; 
}

+(void) upsertSearch:(WebsearchHistory *)search inList:(NSMutableArray *)searchHistory
{
    search.term = [search cleanTerm];
    
    NSUInteger currentIndex = [searchHistory indexOfObject:search];
    
    if (currentIndex == NSNotFound)
    {
        [searchHistory addObject:search];
    }
    else
    {
        [searchHistory replaceObjectAtIndex:currentIndex withObject:search];
    }
    
}

+(void) saveSearch:(NSString *)theSearchTerm withResultCount:(int)count
{
    //
    // Save the search, even if there are no results
    //
    WebsearchHistory *search = [[[WebsearchHistory alloc] init] autorelease];
    search.term = theSearchTerm;
    search.resultCount = count;
    search.searchDate = [NSDate date];  // Note: GMT
    
    NSMutableArray *currentSearchHistory = [WebsearchHistory getSearchHistory];
    
    DLog(@"To search history: %@", search);
    
    //
    // If we have no history, let's create a list to hold the first one
    //
    if (currentSearchHistory == nil)
    {
        currentSearchHistory = [[[NSMutableArray alloc] init] autorelease];
    }
    
    [self upsertSearch:search inList:currentSearchHistory];
    [self setSearchHistory:currentSearchHistory];
    
    DLog(@"Boom - saved search history");
    
}


@end
