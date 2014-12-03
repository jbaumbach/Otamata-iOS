//
//  HelpViewController.h
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorfulButton.h"

@interface HelpViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
- (IBAction)emailButtonClicked:(id)sender;
@property (retain, nonatomic) IBOutlet ColorfulButton *emailButton;
//- (IBAction)btnUploadLinkClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *lblUploadSounds;
@end
