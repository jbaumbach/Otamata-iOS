//
//  OtamataFunctions.h
//  OttaMatta
//
//  Created by John Baumbach on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "GDataXMLNode.h"
#import "GADBannerView.h"

@interface OtamataFunctions : NSObject
    <GADBannerViewDelegate>
{
    BOOL    _hasSlidInAlready;
    CGRect  _targetFrame;
}

+(GDataXMLDocument *)getDeviceDataAsXML;
+(NSString *)getDeviceData;
+(NSString *)emailResultFromEnum:(MFMailComposeResult)result;

//
// Ad support
//
+(CGSize) bannerAdSize;
+(GADBannerView *) addBannerAdToView:(UIView *)parentView andViewController:(UIViewController *)rootViewController withSize:(CGSize)bannerAdSize;

@end
