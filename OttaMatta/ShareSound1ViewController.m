//
//  ShareSound1ViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/30/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "ShareSound1ViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "ShareSound2ViewController.h"

@implementation ShareSound1ViewController
@synthesize mainTable;
@synthesize soundInfoControl;
@synthesize soundInfoHolder;
@synthesize tableBackgroundSelectedView;
@synthesize shareConfig;
@synthesize showSoundInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    
    self.title = @"Share";
    
    self.mainTable.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    
    self.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [self.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];

    //
    // The parent must set this variable - don't create a new one here
    //
    //self.shareConfig = [[ShareSound alloc] init];
    
    //
    // Create a sound info control and set it into our placeholder view
    //
    self.soundInfoControl = [GlobalFunctions initClassFromNib:[SoundInfoControl class]];
    self.soundInfoControl.sound = self.shareConfig.currentSound;  // <=-- sound to use
    [soundInfoHolder addSubview:self.soundInfoControl];
    
}

- (void)viewDidUnload
{
    [self setMainTable:nil];
    [self setSoundInfoControl:nil];
    [self setSoundInfoHolder:nil];

    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tableBackgroundSelectedView = nil;
    self.shareConfig = nil;
    
    
    [super viewDidUnload];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [mainTable deselectAllRows];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mainTable release];
    [soundInfoControl release];
    [soundInfoHolder release];
    [super dealloc];
}

/*

#pragma mark - Helper Methods

//
// Experiment: ability to hide the sound info control.  Became too much effort.
// Let's keep it simple. 
//
-(void) hideSoundInfoDisplay
{
    CGRect tableFrame = self.mainTable.frame;

    float currentTop = tableFrame.origin.y;
    
    tableFrame = CGRectMake(tableFrame.origin.x, 0, tableFrame.size.width, tableFrame.size.height + currentTop);
    
    self.mainTable.frame = tableFrame;
    
    [soundInfoHolder setHidden:YES];
    
}
*/


#pragma mark - TableView protocols

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // Select a cell to grab.  Note: all cells ids are unique here.  Todo: find a better way.
    //
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //
    // If no reusable cell, create a new one.
    //
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    //
    // Configure the cell.  Set it's properties.
    //
    [cell setSelectedBackgroundView:self.tableBackgroundSelectedView];
    //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.clipsToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [shareConfig.shareMethods objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[shareConfig.shareMethodIcons objectAtIndex:indexPath.row]];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [shareConfig.shareMethods count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    shareConfig.CurrentMethod = indexPath.row;
    
    ShareSound2ViewController *controller = [[[ShareSound2ViewController alloc] init] autorelease];
    controller.shareConfig = self.shareConfig;
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
