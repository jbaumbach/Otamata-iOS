//
//  ShareSoundViewController.m
//  Otamata
//
//  Created by John Baumbach on 4/29/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import "ShareSoundViewController.h"
#import "Config.h"
#import "GlobalFunctions.h"
#import "ShareSoundHelperController.h"

@implementation ShareSoundViewController
@synthesize actionsTableView;
@synthesize tableBackgroundSelectedView;
@synthesize tableSectionHeadings;
@synthesize shareTypes;
@synthesize shareMethods;
@synthesize shareConfig;
@synthesize helperController;

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
    
    self.title = @"Share Sound";
    
    self.actionsTableView.backgroundColor = [UIColor colorWithHexString:TABLEVIEW_BG_COLOR];
    
    self.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [self.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];

    //
    // The order here must be the same as the "ShareSoundSetting" enum in the header
    //
    self.tableSectionHeadings = [[[NSArray alloc] initWithObjects:
                                 @"How to share it?", 
                                 @"How should it look?", 
                                 nil] autorelease];
    
    //
    // The order here must be the same as the "SoundShareType" enum in the header
    //
    self.shareTypes = [[[NSArray alloc] initWithObjects:
                       @"Sound and full details", 
                       @"Sound only, no details",
                       @"Sound only plus link to details",
                       nil] autorelease];
    
    //
    // The order here must be the same as the "SoundShareMethod" enum in the header
    //
    self.shareMethods = shareConfig.shareMethods;
}

- (void)viewDidUnload
{
    [self setActionsTableView:nil];
    [super viewDidUnload];
    
    self.tableSectionHeadings = nil;
    self.shareTypes = nil;
    self.shareMethods = nil;
    
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [actionsTableView deselectAllRows];
}

- (void)dealloc {
    [actionsTableView release];
    self.helperController = nil;
    
    [super dealloc];
}


#pragma mark - TableView protocols

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // Select a cell to grab.  Note: all cells ids are unique here.  Todo: find a better way.
    //
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.section];
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.clipsToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    switch (indexPath.section)
    {
        //
        // We can cheat a little since we know there's only one row per section
        //
        case sssShareMethod:
            cell.textLabel.text = [shareMethods objectAtIndex:shareConfig.CurrentMethod];
            cell.imageView.image = [UIImage imageNamed:[shareConfig.shareMethodIcons objectAtIndex:shareConfig.CurrentMethod]];
            break;
            
        case sssSoundType:
            cell.textLabel.text = [shareTypes objectAtIndex:shareConfig.CurrentType];
            break;
            
        default:
            cell.textLabel.text = [NSString stringWithFormat:@"Item %d", indexPath.row];
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ShareSoundSettingsCount;
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [tableSectionHeadings objectAtIndex:section];
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

//
// This is all to set the text color for the section header.  Sigh.
//
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //
    // Todo: make these dimension values dynamic - read from "something" somewhere.  Hardcoding
    // is fragile.  Quick and dirty for now.
    //
    float fontSizeForHeaders = 17;
    
    UIView *tempView=[[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)] autorelease];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
    tempLabel.backgroundColor=[UIColor clearColor]; 
    tempLabel.shadowColor = [UIColor blackColor];
    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [UIColor whiteColor]; 
    //tempLabel.font = [UIFont fontWithName:@"Helvetica" size:fontSizeForHeaders];
    tempLabel.font = [UIFont boldSystemFontOfSize:fontSizeForHeaders];
    tempLabel.text = [tableSectionHeadings objectAtIndex:section];
    
    [tempView addSubview:tempLabel];
    
    [tempLabel release];
    return tempView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items;
    NSObject *currentItem;
    NSArray *images = nil;
    
    switch (indexPath.section) {
        case sssSoundType:
            items = [NSMutableArray arrayWithArray:shareTypes];
            currentItem = [items objectAtIndex:shareConfig.CurrentType];
            break;
            
        case sssShareMethod:
            items = [NSMutableArray arrayWithArray:shareMethods];
            currentItem = [items objectAtIndex:shareConfig.CurrentMethod];
            images = shareConfig.shareMethodIcons;
            break;
            
        default:
            [NSException raise:@"Table section unknown" format:nil];
    }

    SimpleObjectSelectionViewController *controller = [[SimpleObjectSelectionViewController alloc] init];
    controller.selectList = items;
    controller.selectIcons = images;
    controller.selectedItem = currentItem;
    controller.dialogTitle = [tableSectionHeadings objectAtIndex:indexPath.section];
    controller.delegate = self;
    controller.key = [tableSectionHeadings objectAtIndex:indexPath.section];
    controller.tableBackgroundSelectedView = [[[UIView alloc] init] autorelease];
    [controller.tableBackgroundSelectedView setBackgroundColor:[UIColor colorWithHexString:SPINNER_COLOR]];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
}

#pragma mark - SimpleObjectSelectionProtocol implementation

- (void)simpleObjectDialogDismissed:(NSObject *)item withKey:(NSObject *)key
{
    DLog(@"Selected item: %@ for type: %@", item, key);
    
    switch ([tableSectionHeadings indexOfObject:key]) 
    {
        case sssSoundType:
            shareConfig.CurrentType = [shareTypes indexOfObject:item];
            break;

        case sssShareMethod:
            shareConfig.CurrentMethod = [shareMethods indexOfObject:item];
            break;
            
        default:
            [NSException raise:@"Object key unknown" format:nil];
            break;
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [actionsTableView reloadData];
}

#pragma mark - ShareSoundDelegate implementation

-(void) shareCompleteWithResult:(int)result
{
    DLog(@"Got a response from the controller: %d", result);
    
    //
    // We're outta here
    //
    [self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark - User Actions

- (IBAction)nextClicked:(id)sender 
{
    //
    // Open share helper, it does all the work.
    //
    self.helperController = [[[ShareSoundHelperController alloc] init] autorelease];
    helperController.shareConfig = self.shareConfig;
    helperController.parentController = self;
    helperController.delegate = self;
    [helperController doShare];

}
@end
