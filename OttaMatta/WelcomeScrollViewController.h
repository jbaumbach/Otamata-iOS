//
//  WelcomeScrollViewController.h
//  Otamata
//
//  Created by John Baumbach on 4/22/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeScrollViewController : UIViewController
    <UIScrollViewDelegate>
{
    BOOL pageControlIsChangingPage;
}

@property (retain, nonatomic) IBOutlet UIScrollView *welcomeScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *welcomePageControl;
@property (retain, nonatomic) NSMutableArray *pages;

- (IBAction)pageChanged:(id)sender;
- (void)setupPage;

@end
