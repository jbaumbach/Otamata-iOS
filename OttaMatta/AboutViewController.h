//
//  AboutViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorfulButton.h"

@interface AboutViewController : UIViewController
{
}

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet ColorfulButton *emailButton;

- (IBAction)emailButtonClicked:(id)sender;
- (IBAction)websiteButtonClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *lblVer;

@end
