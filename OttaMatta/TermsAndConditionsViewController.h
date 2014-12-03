//
//  TermsAndConditionsViewController.h
//  Otamata
//
//  Created by John Baumbach on 6/21/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsAndConditionsViewController : UIViewController

- (IBAction)doneClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UIWebView *mainWebView;
@property (retain, nonatomic) IBOutlet UINavigationItem *navItemTitle;
@property (retain, nonatomic) IBOutlet UINavigationBar *actualNavBar;
@end
