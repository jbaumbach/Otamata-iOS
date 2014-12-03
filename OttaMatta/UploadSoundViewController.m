//
//  UploadSoundViewController.m
//  Otamata
//
//  Created by John Baumbach on 6/3/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "UploadSoundViewController.h"
#import "GlobalFunctions.h"
#import "SoundInfoControl.h"
#import "TermsAndConditionsViewController.h"

@implementation UploadSoundViewController
@synthesize navItemTitle;
@synthesize txtUserName;
@synthesize uploadButton;
@synthesize enableAllUsers;
@synthesize lblPrivacyNotice;
@synthesize lblTermsLink;
@synthesize sound;
@synthesize soundInfoHolder;
@synthesize actualNavBar;
@synthesize soundInfoControl;
@synthesize delegate;
@synthesize enableAllUsersDefaultIsOn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        enableAllUsersDefaultIsOn = NO;
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
    
    //
    // Create a sound info control and set it into our placeholder view
    //
    self.soundInfoControl = [GlobalFunctions initClassFromNib:[SoundInfoControl class]];
    self.soundInfoControl.sound = self.sound;
    [soundInfoHolder addSubview:self.soundInfoControl];
    
    [navItemTitle setTitle:@"Upload Sound"];
    [uploadButton setTitle:@"Continue"];
    [actualNavBar setTintColor:[UIColor colorWithHexString:NAVBAR_TINT]];
    
    [txtUserName setBackgroundColor:[UIColor colorWithHexString:VERY_LIGHT_GREEN]];

    txtUserName.delegate = self;
    txtUserName.text = [Config getUserName];
    
    if ([enableAllUsers respondsToSelector:@selector(onTintColor)])
    {
        enableAllUsers.onTintColor = [UIColor colorWithHexString:SPINNER_COLOR];
    }
    [enableAllUsers setOn:enableAllUsersDefaultIsOn];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblTermsLinkClicked:)];
    [lblTermsLink setUserInteractionEnabled:YES];
    [lblTermsLink addGestureRecognizer:tapGesture];
    [tapGesture release];
    lblTermsLink.textColor = [UIColor colorWithHexString:SPINNER_COLOR];

    
    [self setPrivacyMessage];
    [self setButtonStates];
}

- (void)viewDidUnload
{
    [self setTxtUserName:nil];
    [self setUploadButton:nil];
    [self setNavItemTitle:nil];
    [self setSoundInfoHolder:nil];
    
    self.soundInfoControl = nil;
    
    [self setActualNavBar:nil];
    [self setEnableAllUsers:nil];
    [self setLblPrivacyNotice:nil];
    [self setLblTermsLink:nil];
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
    [txtUserName release];
    [uploadButton release];
    [navItemTitle release];
    self.sound = nil;
    
    [soundInfoHolder release];
    [actualNavBar release];
    self.delegate = nil;
    
    [enableAllUsers release];
    [lblPrivacyNotice release];
    [lblTermsLink release];
    [super dealloc];
}

#pragma mark - Instance Members

-(void) setPrivacyMessage
{
    if (enableAllUsers.isOn)
    {
        lblPrivacyNotice.text = PRIVACY_PUBLIC_DESC;
    }
    else
    {
        lblPrivacyNotice.text = PRIVACY_PRIVATE_DESC;
    }
}

-(void) setButtonStates
{
    bool haveName = [txtUserName text].length > 0;
    uploadButton.enabled = haveName;
}

-(BOOL) validateForm
{
    BOOL result = NO;
    
    int userNameLength = [txtUserName text].length;
    NSString *validationMessage = nil;
    
    if (userNameLength <= 5)
    {
        validationMessage = @"Please enter a name of greater than 5 characters.";
    }
    else if (userNameLength >= 30)
    {
        validationMessage = @"Please enter a name of less than 30 characters.";
    }
    else
    {
        result = YES;
    }
    
    if (validationMessage != nil)
    {
        UIAlertView *oops = [[[UIAlertView alloc] initWithTitle:@"Upload Validation" message:validationMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [oops show];
    }

    return result;
}

#pragma mark - User Actions

- (IBAction)cancelClicked:(id)sender {
    [self buttonClicked:mrCancel];
}

- (IBAction)uploadClicked:(id)sender {
    if ([self validateForm])
    {
        [Config setUserName:txtUserName.text];
        
        [self buttonClicked:mrOK];
    }
}

- (IBAction)privacySwitchToggled:(id)sender {
    [self setPrivacyMessage];
}

-(void) buttonClicked:(ModalResult)action
{
    if ([delegate respondsToSelector:@selector(userAction:withUserName:andSharingPreference:)])
    {
        [delegate userAction:action withUserName:txtUserName.text andSharingPreference:enableAllUsers.isOn];
    }
    else
    {
        DLog(@"Well, no delegate defined, I guess we'll just keep hanging out here forever.");
    }
}

-(void) lblTermsLinkClicked:(UIGestureRecognizer *)gestureRecognizer
{
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Config websiteTermsAndConditionsUrl]]];
    
    TermsAndConditionsViewController *terms = [[[TermsAndConditionsViewController alloc] init] autorelease];
    [self presentModalViewController:terms animated:YES];
    
}

#pragma mark - Manual Setters

-(void) setSound:(Sound *)newSound
{
    [sound release];
    sound = [newSound retain];
}

#pragma mark - Text Field Delegate

//
// Happens when keyboard "Return" key is clicked
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"Text field should return?");
    
    [txtUserName resignFirstResponder];
    
    [self setButtonStates];
    
    return YES;
}


@end
