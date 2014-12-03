//
//  TapForTapAdMobBanner.m
//  TapForTap
//
//  Created by Sami Samhuri on 12-06-25.
//  Copyright (c) 2012 Beta Street. All rights reserved.
//

#import "TapForTapAdMobBanner.h"

@implementation TapForTapAdMobBanner

@synthesize delegate = _delegate;
@synthesize adView = _adView;

#pragma mark -
#pragma mark GADCustomEventBanner

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request  {
    
    if (!self.adView) {
        self.adView = [[[TapForTapAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)] autorelease];
        // If you have not set a default app ID, provide one here.
        // self.adView.appId = @"YOUR APP ID";
        self.adView.autoRollover = NO;
        self.adView.delegate = self;
    }
    [self.adView loadAds];
}

#pragma mark -
#pragma mark TapForTapAdView Callbacks

- (void) tapForTapAdViewDidReceiveAd: (TapForTapAdView *)adView
{
    self.adView.delegate = nil;
    [self.delegate customEventBanner: self didReceiveAd: adView];
}

- (void) tapForTapAdView: (TapForTapAdView *)adView didFailToReceiveAd: (NSString *)reason
{
    self.adView.delegate = nil;
    [self.delegate customEventBanner: self didFailAd: nil];
}

-(void)dealloc
{
    self.adView = nil;
    self.delegate = nil;
    
    [super dealloc];
}
@end
