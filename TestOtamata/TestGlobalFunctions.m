//
//  TestGlobalFunctions.m
//  Otamata
//
//  Created by John Baumbach on 6/10/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "TestGlobalFunctions.h"
#import "GlobalFunctions.h"

#import <UIKit/UIKit.h>
//#import "application_headers" as required
#import "WebsearchHistory.h"

@implementation TestGlobalFunctions

-(void) test_GlobalFunctions_parseRFC3339Date
{
    NSString *date1 = @"2012-06-03T21:49:47Z";
    NSDate *resDate1 = [NSDate parseRFC3339Date:date1];
    
    STAssertNotNil(resDate1, @"Date is nil");
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:resDate1];

    STAssertEquals(3, [components day], @"Day parsing");
    STAssertEquals(6, [components month], @"Month parsing");
    STAssertEquals(2012, [components year], @"Year parsing");
    
    
    NSString *date2 = @"BadDate";
    NSDate *resDate2 = [NSDate parseRFC3339Date:date2];
    
    STAssertNil(resDate2, @"Date should be nil");

    
    NSDate *resDate3 = [NSDate parseRFC3339Date:nil];
    STAssertNil(resDate3, @"Date should be nil");
    
    NSNull *date4 = [[[NSNull alloc] init] autorelease];
    
    //
    // Note: build warning here is on purpose - we're testing what happens if null goes in
    //
    NSDate *resDate4 = [NSDate parseRFC3339Date:date4];
    STAssertNil(resDate4, @"Date should be nil");
    
    

}
@end
