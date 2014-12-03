//
//  IconViewContainer.h
//  JohnsNavBasedProject
//
//  Created by John Baumbach on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IconViewContainerProtocal <NSObject>

-(UIView *) iconViewForItem:(NSObject *)item withFrame:(CGRect)frame;

@end


@interface IconViewContainer : UIView

@property (nonatomic, retain) id<IconViewContainerProtocal> delegate;
@property (nonatomic, retain) NSMutableArray *itemList;
@property float padding;
@property float iconCornerRadius;

-(void) drawView;
-(void)commonIniter;

double optimal_size (double W, double H, int N);


@end
