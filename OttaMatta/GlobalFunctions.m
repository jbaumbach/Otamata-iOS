//
//  GlobalFunctions.m
//  Moola
//
//  Created by John Baumbach on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "GlobalFunctions.h"
#include <sys/xattr.h>
#import <MediaPlayer/MPMusicPlayerController.h>

@implementation GlobalFunctions


//
// Format a string on the fly, since this is apparently missing from the date class
// in this language.  It's in EVERY other modern language.  Jeez.
// 
+ (NSString *)formatDate:(NSDate *)theDate 
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M-d-yyyy"];
    NSString *result = [dateFormatter stringFromDate:theDate];
    [dateFormatter release];
    return result;
}

+ (NSString *)formatFloatToCurrency:(float)theAmount
{
    return [NSString stringWithFormat:@"$%0.2f", theAmount];
}

+(NSString *)formatNumberToCurrency:(NSNumber *)theAmount
{
    return [self formatFloatToCurrency:[theAmount floatValue]];
}

//
// Yes, all this is required to put in the commas.  Weird.
//
+(NSString *)formatWithCommas:(long)theNumber
{
    NSNumber* number = [NSNumber numberWithLong:theNumber];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];
    NSString* commaString = [numberFormatter stringForObjectValue:number];
    [numberFormatter release];

    return commaString;
}
//
// I got tired of writing this function
//
+(void)navigateFromSelf:(UIViewController *)mySelf toViewController:(Class)target
{
    UIViewController *controller = [target alloc];
    [mySelf.navigationController pushViewController:controller animated:YES];
    [controller release];

}

//
// To pop the dismissed view controller from the navigation controller
//
+(void)dismissViewControllerFromSelf:(UIViewController *)mySelf
{
    [mySelf.navigationController popViewControllerAnimated:YES];
}

+(NSString *)productName
{
    NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
    return [infoPList objectForKey:@"CFBundleDisplayName"];
}

//
// Return a color for the passed index.  
//
+(UIColor *)colorForIndex:(NSUInteger)index
{
    UIColor *result;
    
    switch (index) {
        case 0:
            result = [UIColor redColor];
            break;
            
        case 1:
            result = [UIColor greenColor];
            break;
            
        case 2:
            result = [UIColor yellowColor];
            break;
            
        case 3:
            result = [UIColor magentaColor];
            break;
            
        case 4:
            result = [UIColor purpleColor];
            break;
            
        case 5:
            result = [UIColor orangeColor];
            break;
            
        case 6:
            result = [UIColor blueColor];
            break;
            
        default:
            result = [UIColor grayColor];
            break;
    }

    return result;
}

+(BOOL)fileExists:(NSString *)filePath
{
    BOOL result;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    result = [filemgr fileExistsAtPath:filePath];
    // prolly doesn't need to be released?  [filemgr release];
    
    return result;
}

+(NSString *)descriptiveRect:(CGRect)rect
{
    return [NSString stringWithFormat:@"x:%f y:%f w:%f h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

+(void) centerView:(UIView *)view inFrame:(CGRect)frame
{
    CGRect itemViewFrame = view.frame;
    
    itemViewFrame.origin.x = (frame.size.width / 2) - (itemViewFrame.size.width / 2);
    itemViewFrame.origin.y = (frame.size.height / 2) - (itemViewFrame.size.height / 2);
    
    view.frame = itemViewFrame;
}

//
// Function to grab an instance of a class that:
//
//  1. Has a NIB file of [name].
//  2. Has a class name specified as the class [name] in InterfaceBuilder.
//
+(id) initClassFromNib:(Class)class
{
    id result = nil;
    
    NSString *className = [class description];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[class class]])
        {
            result = currentObject;
            break;
        }
    }

    return result;
}

+(NSString *) urlEncodedString:(NSString *)string
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)string,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
}

//
// These fields all grab the localized strings from info.plist.  Docs here:
// 
// http://developer.apple.com/library/ios/#documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
//
+(NSString *) appName
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDict objectForKey:@"CFBundleDisplayName"];
    
    return name;
}

//
// The one the App store cares about.  The "Version" value on the Summary screen, and "Bundle Versions String, Short" in info.plist 
//
+(NSString *) appPublicVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *publicBuildVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];   // The app store version
    
    return publicBuildVersion;
}

+(NSString *) appBuild
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *buildVersion = [infoDict objectForKey:@"CFBundleVersion"];     // This is the internal build number "Bundle Version"
    
    return buildVersion;
}

+(float) iosVersion
{
    UIDevice *device = [UIDevice currentDevice];
    float result = [device.systemVersion floatValue];
    
    return result;
}

//
// Technical Q&A QA1719 - https://developer.apple.com/library/ios/#qa/qa1719/_index.html
//
// How do I prevent files from being backed up to iCloud and iTunes?
//
// Starting in iOS 5.0.1 a new "do not back up" file attribute has been introduced allowing developers to clearly 
// specify which files should be backed up, which files are local caches only and subject to purge, and which files should 
// not be backed up but should also not be purged. In addition, setting this attribute on a folder will prevent the folder and 
// all of its contents from being backed up.
//
+ (BOOL) addSkipBackupAttributeToItemAtFilePath:(NSString *)theFilePath
{
    if (theFilePath != nil)
    {
        @try
        {
            const char* filePath = [theFilePath UTF8String];
            
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            return (result == 0);
        }
        @catch (NSException *e)
        {
            DLog(@"Exception in addSkipBackupAttributeToItemAtURL: %@", e);
        }
        @finally
        {
        }
    }
    
    return NO;
}

+(float) getCurrentMediaVolume
{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    return musicPlayer.volume;
}

+(void) setCurrentMediaVolume:(float)volume
{
    //
    // Uses mediaplayer framework
    //
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = volume; 
}

//
// Gets the "Bundle Identifier" from the info.plist section.
//
// example: com.ergocentricsoftware.otamata
//
+(NSString *) bundleIdentifier
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

//
// Returns the bundle identifier and the product id concatenated
//
+(NSString *) appProductId:(NSString *)productId
{
    return [NSString stringWithFormat:@"%@.%@", [self bundleIdentifier], productId];
}

//
// The duration is in seconds.
//
+(void) sleepAndProcessMessages:(float)duration
{
    //
    // This odd statement apparently sleeps a bit, allowing the UI to update.
    //
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
}

+(void) processMessagesAndSleep:(float)duration
{
    [self sleepAndProcessMessages:duration];
}

+(void) doEventsAndSleep:(float)duration
{
    [self sleepAndProcessMessages:duration];
}

//
// Take an image and resize it into the new size, centering it in the target.  The target should
// be a square.
//
+ (UIImage *)convertImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIImage *result;
    CGSize currentSize = [image size];
    
    DLog(@"Current size: %f,%f  new size: %f,%f ", currentSize.width, currentSize.height, newSize.width, newSize.height);
    
    //
    // Scale it
    // 
    float widthscale = newSize.width / currentSize.width;
    float heightscale = newSize.height / currentSize.height;
    
    float actualscale = MIN(widthscale, heightscale);
    CGRect targetRect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    if (widthscale < heightscale)
    {
        //
        // The width will be ok, center the height
        //
        float leftoverHeight = newSize.height - (currentSize.height * actualscale);
        targetRect.size.height = currentSize.height * actualscale;
        targetRect.origin.y = leftoverHeight / 2.0;
    }
    else
    {
        //
        // The height will be ok, center the width
        //
        float leftoverWidth = newSize.width - (currentSize.width * actualscale);
        targetRect.size.width = currentSize.width * actualscale;
        targetRect.origin.x = leftoverWidth / 2.0;
    }
    UIImage *scaledImage = [[UIImage alloc] initWithCGImage:[image CGImage] scale:actualscale orientation:UIImageOrientationUp];
    
    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // drawing with a fill color
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    // Add Filled Rectangle, 
    CGContextFillRect(context, CGRectMake(0.0, 0.0, newSize.width, newSize.height));
    
    
    [scaledImage drawInRect:targetRect];
    result = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    [scaledImage release];
    
    return result;
}

+(NSString *) getUserDefault:(NSString *)keyName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:keyName];
}

+(void) setUserDefault:(NSString *)keyName toValue:(NSString *)newValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:newValue forKey:keyName];
    [userDefaults synchronize];
}



@end


#pragma mark - Class Extension Methods

@implementation NSNumber (expanded)

-(NSNumber *) setSign:(BOOL)sign
{
    int mult = sign ? 1 : -1;
    float currentValAbs = ABS([self floatValue]);
    return [NSNumber numberWithFloat:(mult * currentValAbs)];
}

-(NSString *) toCurrency
{
    return [GlobalFunctions formatNumberToCurrency:self];
}
@end

@implementation UITableView (expanded)

-(void) deselectAllRows
{
    NSArray *selectedRows = [self indexPathsForSelectedRows];
    
    for (NSIndexPath *selectedRow in selectedRows)
    {
        [self deselectRowAtIndexPath:selectedRow animated:NO];
    }
}

-(void) scrollToTop
{
    [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

}
@end

@implementation UIColor (expanded)
-(float) GetColorComponent:(ColorComponentType)type
{
    return CGColorGetComponents(self.CGColor)[type];
}

-(UIColor *) colorAdjustedByPercent:(int)percent
{
    UIColor *result;
    float multPct = percent * 0.01;
    
    float baseRed = [self GetColorComponent:cctRed];    //CGColorGetComponents(self.CGColor)[0];
    float baseGreen = [self GetColorComponent:cctGreen];  //CGColorGetComponents(self.CGColor)[1];
    float baseBlue = [self GetColorComponent:cctBlue];   //CGColorGetComponents(self.CGColor)[2];
    float baseAlpha = [self GetColorComponent:cctAlpha];  //CGColorGetComponents(self.CGColor)[3];
    
    float newRed, newGreen, newBlue;
    
    if (percent > 0)
    {
        newRed = MIN(baseRed * (1.0 + multPct), 1.0f);
        newGreen = MIN(baseGreen * (1.0 + multPct), 1.0f);
        newBlue = MIN(baseBlue * (1.0 + multPct), 1.0f);
    }
    else
    {
        /* added safety:
        newRed = baseRed * (1.0 + multPct);
        newGreen = baseGreen * (1.0 + multPct);
        newBlue = baseBlue * (1.0 + multPct);
        */
        
        newRed = MAX(baseRed * (1.0 + multPct), 0.0f);
        newGreen = MAX(baseGreen * (1.0 + multPct), 0.0f);
        newBlue = MAX(baseBlue * (1.0 + multPct), 0.0f);
    }
    
    result = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:baseAlpha];
    
    return result;
}

-(UIColor *) oppositeColor
{
    float resultRed = fmodf([self GetColorComponent:cctRed] + 1.0f, 1.0f);
    float resultGreen = fmodf([self GetColorComponent:cctGreen] + 1.0f, 1.0f);
    float resultBlue = fmodf([self GetColorComponent:cctBlue] + 1.0f, 1.0f);
    float resultAlpha = [self GetColorComponent:cctAlpha];
    
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// String should be 6 or 8 characters
	if ([cString length] < 6) return DEFAULT_VOID_COLOR;
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	
	if ([cString length] != 6) return DEFAULT_VOID_COLOR;
    
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}

@end

@implementation UISegmentedControl (expanded)

-(NSInteger) indexForValue:(NSString *)theValue
{
    int result = 0;
    
    for (int loop = 0; loop < [self numberOfSegments]; loop++)
    {
        if ([[self titleForSegmentAtIndex:loop] isEqualToString:theValue])
        {
            result = loop;
            break;
        }
    }
    
    DLog(@"Probably found %@ at position %d", theValue, result);
    
    return result;
}
@end

@implementation NSData (expanded)
- (NSString*)md5
{
    
    unsigned char result[16];
    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}
@end

@implementation NSDate (expanded)
+ (NSDate *)parseRFC3339Date:(NSString *)dateString 
{
    NSDate *theDate = nil;

    if ([dateString isKindOfClass:[NSString class]])
    {
        NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
        [rfc3339TimestampFormatterWithTimeZone setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        NSError *error = nil; 
        if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:dateString range:nil error:&error]) {
            DLog(@"Date '%@' could not be parsed: %@", dateString, error);
        }
        
        [rfc3339TimestampFormatterWithTimeZone release];
    }
    
    return theDate;
}
@end

@implementation NSString (expanded)
- (BOOL) isNumeric
{
    NSScanner *sc = [NSScanner scannerWithString:self];
    if ( [sc scanFloat:NULL] )
    {
        return [sc isAtEnd];
    }
    return NO;
}
@end

