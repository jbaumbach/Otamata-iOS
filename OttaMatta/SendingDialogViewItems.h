//
//  SendingDialogViewItems.h
//  OttaMatta
//
//  Created by John Baumbach on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendingDialogViewItems : UIView
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *statusDetailLabel;

@end
