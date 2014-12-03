//
//  HelpViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

#import "SendEmailController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "HelpUploadSoundViewController.h"

@implementation HelpViewController
@synthesize lblUploadSounds;
@synthesize emailButton;
@synthesize mainScrollView;
@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Help";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [mainScrollView addSubview:contentView];
    [mainScrollView setContentSize:contentView.bounds.size];

    [self.emailButton setTitle:EMAIL_GENERAL forState:UIControlStateNormal];
    [self.emailButton setTitle:EMAIL_GENERAL forState:UIControlStateSelected];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnUploadLinkClicked:)];
    // Note: the UILable must have user interaction enabled, either in code or IB.
    [lblUploadSounds addGestureRecognizer:tapGesture];
    [tapGesture release];
    lblUploadSounds.textColor = [UIColor colorWithHexString:SPINNER_COLOR];

}

- (void)viewDidUnload
{
    [self setMainScrollView:nil];
    [self setContentView:nil];
    [self setEmailButton:nil];
    [self setLblUploadSounds:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mainScrollView release];
    [contentView release];
    [emailButton release];
    [lblUploadSounds release];
    [super dealloc];
}

#pragma mark - Other Methods

- (IBAction)emailButtonClicked:(id)sender {
    SendEmailController *emailer = [[SendEmailController alloc] initWithParent:self];
    [emailer sendContactUsEmail];
    //
    // Note: do NOT release or autorelease the emailer object here or you'll get a zombie.   
    // todo: set emailer control as a property of the view controller and release
    // at unload.
    //
    // OK to ignore "Analyze" warnings about potential mem leaks here.
    //
}

-(void) uploadSoundsLinkClicked:(UIButton *)sender
{
}

//- (IBAction)btnUploadLinkClicked:(id)sender {
-(void) btnUploadLinkClicked:(UIGestureRecognizer *)gestureRecognizer
{
    HelpUploadSoundViewController *controller = [[[HelpUploadSoundViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];

}
@end
