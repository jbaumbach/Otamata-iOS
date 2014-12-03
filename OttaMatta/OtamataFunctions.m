//
//  OtamataFunctions.m
//  OttaMatta
//
//  Created by John Baumbach on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtamataFunctions.h"
#import "Config.h"
#import "SoundManager.h"

@implementation OtamataFunctions

+(GDataXMLDocument *)getDeviceDataAsXML
{
    UIDevice *device = [UIDevice currentDevice];
    
    GDataXMLElement *installationInfo = [GDataXMLNode elementWithName:@"installationinfo"];
    
    //
    // Grab program data element
    //
    GDataXMLElement *program = [GDataXMLElement elementWithName:[GlobalFunctions appName]]; // bundle.bundle display name
    GDataXMLNode *ver = [GDataXMLNode elementWithName:@"version" stringValue:[GlobalFunctions appPublicVersion]]; 
    GDataXMLNode *build = [GDataXMLNode elementWithName:@"version" stringValue:[GlobalFunctions appBuild]]; 
    // GDataXMLNode *sounds = [GDataXMLNode elementWithName:@"soundcount" stringValue:[NSString stringWithFormat:@"%d", [[SoundManager getLocalSounds] count]]];
    GDataXMLNode *uuid = [GDataXMLNode elementWithName:@"uuid" stringValue:[Config getUUID]];
    
    [program addAttribute:ver];
    [program addAttribute:build];
    //[program addAttribute:sounds];
    [program addAttribute:uuid];
    
    [installationInfo addChild:program];
    
    //
    // Grab device info element
    //
    GDataXMLElement *deviceInfo = [GDataXMLElement elementWithName:@"userdevice"];
    GDataXMLNode *name = [GDataXMLNode elementWithName:@"name" stringValue:device.name];
    GDataXMLNode *systemName = [GDataXMLNode elementWithName:@"systemname" stringValue:device.systemName];
    GDataXMLNode *sysVer = [GDataXMLNode elementWithName:@"systemversion" stringValue:device.systemVersion];
    GDataXMLNode *model = [GDataXMLNode elementWithName:@"model" stringValue:device.model];
    
    [deviceInfo addAttribute:name];
    [deviceInfo addAttribute:systemName];
    [deviceInfo addAttribute:sysVer];
    [deviceInfo addAttribute:model];
    
    [installationInfo addChild:deviceInfo];
    
    //
    // Put it all together
    //
    GDataXMLDocument *result = [[[GDataXMLDocument alloc] 
                                 initWithRootElement:installationInfo] autorelease];
    
    return result;
    
}

+(NSString *)getDeviceData
{
    UIDevice *device = [UIDevice currentDevice];
    
    NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
    
    [result appendFormat:@"Version: %@ (%@)\r\n", [GlobalFunctions appPublicVersion], [GlobalFunctions appBuild]];
    [result appendFormat:@"UUID: %@\r\n", [Config getUUID]];
    [result appendFormat:@"Device name: %@\r\n", device.name];
    [result appendFormat:@"System name: %@\r\n", device.systemName];
    [result appendFormat:@"System ver: %@\r\n", device.systemVersion];
    [result appendFormat:@"Model: %@\r\n", device.model];
    
    //return [result copy];
    return result;
}

+(NSString *)emailResultFromEnum:(MFMailComposeResult)result
{
    switch (result) {
        case MFMailComposeResultCancelled:
            return @"MFMailComposeResultCancelled";
        case MFMailComposeResultSaved:
            return @"MFMailComposeResultSaved";
        case MFMailComposeResultSent:
            return @"MFMailComposeResultSent";
        case MFMailComposeResultFailed:
            return @"MFMailComposeResultFailed";
        default:
            return @"undefined";
    }
}

+(CGSize) bannerAdSize
{
    /* Apple iAd version: 
     CGSize bannerAdSize = [ADBannerView sizeFromBannerContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
     */
    
    // Note: banner ad is 320x50
    
    CGSize bannerAdSize = kGADAdSizeBanner.size;

    return bannerAdSize;
}

+(GADBannerView *) addBannerAdToView:(UIView *)parentView andViewController:(UIViewController *)rootViewController withSize:(CGSize)bannerAdSize
{
    GADBannerView *result = nil;
    
    /* Apple iAd version: 
     CGSize bannerAdSize = [ADBannerView sizeFromBannerContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
     */
    
    // Note: banner ad is 320x50
    
    CGRect frameToAddTo = [parentView frame];
    
    int bottomOfView = frameToAddTo.size.height;
    
    //
    // Place ad at the bottom of the screen
    //
    CGRect holdingBannerFrame = CGRectMake(0, bottomOfView, bannerAdSize.width, bannerAdSize.height); 
    CGRect targetBannerFrame = CGRectMake(0, bottomOfView - bannerAdSize.height, bannerAdSize.width, bannerAdSize.height);
    
    /* Apple iAd version:
     self.adView = [[[ADBannerView alloc] initWithFrame:targetBannerFrame] autorelease];
     adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
     adView.delegate = self;
     */
    
    result = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:holdingBannerFrame.origin] autorelease];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    result.adUnitID = ADMOB_PUBLISHER_ID;
    result.rootViewController = rootViewController;
    
    //
    // Note: the parent of the banner must ALSO release the delegate.  Autoreleasing it here
    // causes a crash.  Apparently it's not being retained?  Code analysis will find
    // a potential mem leak here.  It's ok as long as you always release the delegate.  This is
    // also mentioned in the Google docs on this component.
    //
    OtamataFunctions *adDelegate = [[OtamataFunctions alloc] init];
    result.delegate = adDelegate;
    adDelegate->_hasSlidInAlready = NO;
    adDelegate->_targetFrame = targetBannerFrame;
    
    // Apple iAd version: [self.view addSubview:adView];
    [parentView addSubview:result];
    
    GADRequest *gadRequest = [GADRequest request];
    
#ifdef DEV_VERSION
    //gadRequest.testing = YES;
#endif
    
    [result loadRequest:gadRequest];
    
    return result;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    DLog(@"Did receive G Ad.  Slide already? %d", _hasSlidInAlready);
    
    if (!_hasSlidInAlready)
    {
        [UIView beginAnimations:@"BannerSlide" context:nil];
        bannerView.frame = _targetFrame;
        _hasSlidInAlready = YES;
        [UIView commitAnimations];
    }
}
@end
