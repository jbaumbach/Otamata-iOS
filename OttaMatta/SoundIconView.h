//
//  SoundIconView.h
//  OttaMatta
//
//  Created by John Baumbach on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Sound.h"

@protocol SoundIconViewProtocol <NSObject>

@optional
- (void) longPressedForSound:(Sound *)sound;
- (void) pressedForSound:(Sound *)sound;

@end

@interface SoundIconView : UIView
{
}

//
// Instance properties
//
@property (nonatomic, retain) id<SoundIconViewProtocol> delegate;
@property (nonatomic, retain) Sound *theSound;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic) float iconCornerRadius;

//
// Instance methods
//
-(void) initView;
-(void) getIcon;
-(void) setIconInView;
-(void) setIconWithData:(NSData *)data;
-(void) loadOrGetIcon;


@end
