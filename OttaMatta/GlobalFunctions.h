//
//  GlobalFunctions.h
//  Moola
//
//  Created by John Baumbach on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define DEFAULT_VOID_COLOR [UIColor blueColor]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease]; [alert show]; }
#else
#   define ULog(...)
#endif



//
// Global static functions  
//
@interface GlobalFunctions : NSObject {

}

+ (NSString *)formatDate:(NSDate *)theDate;
+ (NSString *)formatFloatToCurrency:(float)theAmount;
+(NSString *)formatNumberToCurrency:(NSNumber *)theAmount;
+(NSString *)formatWithCommas:(long)theNumber;
+(void)navigateFromSelf:(UIViewController *)mySelf toViewController:(Class)target;
+(void)dismissViewControllerFromSelf:(UIViewController *)mySelf;
+(NSString *)productName;
+(UIColor *)colorForIndex:(NSUInteger)index;
+(BOOL)fileExists:(NSString *)filePath;
+(NSString *)descriptiveRect:(CGRect)rect;
+(void) centerView:(UIView *)view inFrame:(CGRect)frame;
+(id) initClassFromNib:(Class)class;
+(NSString *) urlEncodedString:(NSString *)string;
+(NSString *) appName;
+(NSString *) appPublicVersion;
+(NSString *) appBuild;
+(float) iosVersion;

//+ (BOOL) addSkipBackupAttributeToItemAtURLString:(NSString *)urlString;
//+ (BOOL) addSkipBackupAttributeToItemAtURL:(NSURL *)url;
+ (BOOL) addSkipBackupAttributeToItemAtFilePath:(NSString *)theFilePath;
+(float) getCurrentMediaVolume;
+(void) setCurrentMediaVolume:(float)volume;
+(NSString *) bundleIdentifier;
+(NSString *) appProductId:(NSString *)productId;
+(void) sleepAndProcessMessages:(float)duration;
+(void) processMessagesAndSleep:(float)duration;
+(void) doEventsAndSleep:(float)duration;
+ (UIImage *)convertImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(NSString *) getUserDefault:(NSString *)keyName;
+(void) setUserDefault:(NSString *)keyName toValue:(NSString *)newValue;


@end


@interface NSNumber (expanded)
//
// Pass YES for positive, or NO for negative
//
-(NSNumber *) setSign:(BOOL)sign;
-(NSString *) toCurrency;
@end

@interface UITableView (expanded)
-(void) deselectAllRows;
-(void) scrollToTop;
@end

/*
 An extension method to help us base gradient endpoints on the passed color.  This returns a color with all the base colors adjusted up or down by a positive or negative percent.
 */
typedef enum
{
    cctRed = 0,
    cctGreen = 1,
    cctBlue = 2,
    cctAlpha = 3
} ColorComponentType;

@interface UIColor (expanded)
-(float) GetColorComponent:(ColorComponentType)type;
-(UIColor *) colorAdjustedByPercent:(int)percent;
-(UIColor *) oppositeColor;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end


@interface UISegmentedControl (expanded) 
-(NSInteger) indexForValue:(NSString *)theValue;
@end

@interface NSData (expanded)
- (NSString*)md5;
@end

@interface NSDate (expanded)
+ (NSDate *)parseRFC3339Date:(NSString *)dateString; 
@end

@interface NSString (expanded) 
- (BOOL) isNumeric;
@end

/*
@interface NSString (expanded)
-(NSString *) urlEncoded;
@end
*/