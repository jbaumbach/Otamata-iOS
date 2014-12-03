//
//  OptionsViewController.m
//  OttaMatta
//
//  Created by John Baumbach on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsViewController.h"

#import "HelpUploadSoundViewController.h"
#import "GlobalFunctions.h"
#import "HelpViewController.h"
#import "RestoreSoundsViewController.h"
#import "AboutViewController.h"
#import "VolumeTableViewCell.h"
#import "PurchaseViewController.h"
#import "WelcomeScrollViewController.h"

@implementation OptionsViewController
@synthesize mainTableView;
@synthesize tableBackgroundSelectedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Options", @"Options");
        self.tabBarItem.title = @"Options";
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
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
    self.mainTableView.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    
    self.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [self.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];

}

-(void)viewWillAppear:(BOOL)animated
{
    [mainTableView deselectAllRows];
}

- (void)viewDidUnload
{
    [self setMainTableView:nil];
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
    [mainTableView release];
    self.tableBackgroundSelectedView = nil;
    [super dealloc];
}

#pragma mark - Instance Methods

-(void) switchToggled:(UISwitch *)sender
{
    switch (sender.tag) 
    {
        case trtInappropriate:
            [Config setInappropriateContent:sender.isOn];
            break;
#ifdef DEV_VERSION          
        case trtServerType:
            [Config setUserServerPreference:sender.isOn ? DEV_REMOTE_HOST_IDX : PROD_REMOTE_HOST_IDX];
            break;
#endif
        case trtVolumeToFull:
            [Config setVolumeShouldBeFull:sender.isOn];
            [GlobalFunctions setCurrentMediaVolume:sender.isOn ? [Config getUserVolume] : 0.5f];
            VolumeTableViewCell *volCell = (VolumeTableViewCell *)[mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trtVolumeToFull inSection:0]];
            [volCell.volumeSlider setEnabled:sender.isOn];
            
            break;
            
        default:
            DLog(@"Unknown switch send a message!!!!");
            break;
    }
    
}

-(void) sliderValueChanged:(UISlider *)sender
{
    DLog(@"Volumne changed: %f", sender.value);
    [Config setUserVolume:sender.value];
    [GlobalFunctions setCurrentMediaVolume:sender.value];
}

#pragma mark - TableView protocols

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row != trtVolumeToFull)
    {
        return mainTableView.rowHeight;
    }
    else
    {
        //
        // Simple to hard-code here - grab val from IB. Prolly need better way if the table gets complex.
        //
        return 90.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // Select a cell to grab.  Note: all cells ids are unique here.  Todo: find a better way.
    //
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    //
    // If no reusable cell, create a new one.
    //
    if (cell == nil) {
        if (indexPath.row != trtVolumeToFull)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        else
        {
            cell = [GlobalFunctions initClassFromNib:[VolumeTableViewCell class]];
            ((VolumeTableViewCell *)cell).reuseIdentifierSpecial = CellIdentifier;
        }
    }
    
    //
    // Configure the cell.  Set it's properties.
    //
    [cell setSelectedBackgroundView:self.tableBackgroundSelectedView];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.clipsToBounds = YES;
    cell.accessoryView = nil;
    
    switch (indexPath.row)
    {
        case trtInappropriate:
            cell.textLabel.text = @"Inappropriate content";
            UISwitch *sw = [[[UISwitch alloc] initWithFrame:cell.accessoryView.frame] autorelease];
            [sw setOn:[Config getInappropriateContent]];
            [sw addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            if ([sw respondsToSelector:@selector(onTintColor)])
            {
                sw.onTintColor = [UIColor colorWithHexString:SPINNER_COLOR];
            }
            sw.tag = trtInappropriate;
            cell.accessoryView = sw;
            [cell setSelectedBackgroundView:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case trtGetCredits:
            cell.textLabel.text = @"Upgrade Otamata";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case trtUploadSounds:
            cell.textLabel.text = @"How to add sounds";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case trtRestoreTrash:
            cell.textLabel.text = @"Restore from trash";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case trtVolumeToFull:
            
            DLog(@"Need a statement here or the next statement won't compile.  XCode bug?");
            
            VolumeTableViewCell *volCell = (VolumeTableViewCell *)cell;

            //
            // Set up the switch
            //
            [volCell.setVolSwitch setOn:[Config getVolumeShouldBeFull]];
            [volCell.setVolSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            if ([volCell.setVolSwitch respondsToSelector:@selector(onTintColor)])
            {
                volCell.setVolSwitch.onTintColor = [UIColor colorWithHexString:SPINNER_COLOR];
            }
            volCell.setVolSwitch.tag = trtVolumeToFull;
            
            //
            // Set up the slider
            //
            [volCell.volumeSlider setValue:[Config getUserVolume]];
            [volCell.volumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            if ([volCell.volumeSlider respondsToSelector:@selector(thumbTintColor)])
            {
                volCell.volumeSlider.minimumTrackTintColor = [UIColor colorWithHexString:NAVBAR_TINT];
            }
            volCell.volumeSlider.tag = trtVolumeToFull;
            volCell.volumeSlider.enabled = [Config getVolumeShouldBeFull];

            [cell setSelectedBackgroundView:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            
            break;

        case trtHelp:
            cell.textLabel.text = @"Otamata help";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case trtShowIntroScreens:
            cell.textLabel.text = @"Welcome screens";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case trtAbout:
            cell.textLabel.text = @"About Otamata";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
#ifdef DEV_VERSION
        case trtServerType:
            cell.textLabel.text = @"Development server";
            UISwitch *sw2 = [[[UISwitch alloc] initWithFrame:cell.accessoryView.frame] autorelease];
            [sw2 setOn:[Config getUserServerPreference] == DEV_REMOTE_HOST_IDX];
            [sw2 addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];

            if ([sw2 respondsToSelector:@selector(onTintColor)])
            {
                sw2.onTintColor = [UIColor colorWithHexString:SPINNER_COLOR];
            }
            sw2.tag = trtServerType;
            cell.accessoryView = sw2;
            [cell setSelectedBackgroundView:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
#endif
        default:
            cell.textLabel.text = [NSString stringWithFormat:@"Item %d", indexPath.row];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TotalValuesInTable;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == trtUploadSounds)
    {
        HelpUploadSoundViewController *controller = [[[HelpUploadSoundViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.row == trtHelp)
    {
        HelpViewController *controller = [[[HelpViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.row == trtRestoreTrash)
    {
        RestoreSoundsViewController *controller = [[[RestoreSoundsViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.row == trtAbout)
    {
        AboutViewController *controller = [[[AboutViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.row == trtGetCredits)
    {
        PurchaseViewController *controller = [[[PurchaseViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.row == trtShowIntroScreens)
    {
        WelcomeScrollViewController *welcomeController = [[[WelcomeScrollViewController alloc] init] autorelease];
        [self presentModalViewController:welcomeController animated:YES];
    }
}

@end
