//
//  TestWebsearchHistory.m
//  Otamata
//
//  Created by John Baumbach on 7/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "TestWebsearchHistory.h"
#import "WebsearchHistory.h"

@implementation TestWebsearchHistory

-(void) test_cleanTerm
{
    // Same as search1 but with different result count (and maybe date)
    WebsearchHistory *search3 = [[[WebsearchHistory alloc] init] autorelease];
    search3.term = @" Ugga bugga";
    search3.searchDate= [NSDate date];
    search3.resultCount = 99;
    
    
    STAssertTrue([[search3 cleanTerm] isEqual:@"ugga bugga"], @"Terms should be same even if stuff different");
    
    STAssertFalse([[search3 cleanTerm] isEqual:@"blah"], @"Terms should be same different");
}

-(void) test_isEqual
{
    WebsearchHistory *search1 = [[[WebsearchHistory alloc] init] autorelease];
    search1.term = @"ugga bugga";
    search1.searchDate= [NSDate date];
    search1.resultCount = 14;
    
    WebsearchHistory *search2 = [[[WebsearchHistory alloc] init] autorelease];
    search2.term = @"yo mamma";
    search2.searchDate = [NSDate date];
    search2.resultCount = 45;
    
    // Same as search1 but with different result count (and maybe date)
    WebsearchHistory *search3 = [[[WebsearchHistory alloc] init] autorelease];
    search3.term = @" Ugga bugga";
    search3.searchDate= [NSDate date];
    search3.resultCount = 99;
    
    
    STAssertTrue([search1 isEqual:search1], @"Object should equal itself");
    
    STAssertFalse([search1 isEqual:search2], @"Different objects should not be equal");
                   
    STAssertTrue([search1 isEqual:search3], @"Objects with same search term (even with case and whitespace differences) should be same");
    
}

-(void)test_upsertSearch
{
    WebsearchHistory *search1 = [[[WebsearchHistory alloc] init] autorelease];
    search1.term = @"ugga bugga";
    search1.searchDate= [NSDate date];
    search1.resultCount = 14;
    
    WebsearchHistory *search2 = [[[WebsearchHistory alloc] init] autorelease];
    search2.term = @"yo mamma";
    search2.searchDate = [NSDate date];
    search2.resultCount = 45;
    
    // Same as search1 but with different result count (and maybe date)
    WebsearchHistory *search3 = [[[WebsearchHistory alloc] init] autorelease];
    search3.term = @"ugga bugga";
    search3.searchDate= [NSDate date];
    search3.resultCount = 99;

    
    NSMutableArray *histList = [[[NSMutableArray alloc] init] autorelease];
    
    STAssertFalse([histList containsObject:search1], @"Weird - object already in empty list?");
    
    [WebsearchHistory upsertSearch:search1 inList:histList];
    
    STAssertTrue([histList containsObject:search1], @"Couldn't add object");
    STAssertFalse([histList containsObject:search2], @"Weird - object 2 in list already?");

    [WebsearchHistory upsertSearch:search2 inList:histList];
    
    STAssertTrue([histList containsObject:search2], @"Couldnt add object2");
    
    [WebsearchHistory upsertSearch:search3 inList:histList];

    STAssertTrue(histList.count == 2, @"Upsert should have updated the results, not added, new count is %d", histList.count);
    
    
    
}


@end
