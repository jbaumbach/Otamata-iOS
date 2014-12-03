//
//  SimpleObjectSelectionViewController2.m
//  Moola
//
//  Created by John Baumbach on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleObjectSelectionViewController.h"

@implementation SimpleObjectSelectionViewController

@synthesize mainTableView;
@synthesize closeButtonTitle;
@synthesize selectList;
@synthesize selectIcons;
@synthesize delegate;
@synthesize dialogTitle;
@synthesize selectedItem;
@synthesize key;
@synthesize tableViewStyle;
@synthesize tableBackgroundSelectedView;

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
    
    self.tableViewStyle = UITableViewCellStyleValue1;
    
    //
    // Todo: test the nil behavior.
    //
    if (selectList == nil || [selectList count] <= 0)
    {
        //
        // You have to hard-code the dimensions of the label.  
        // Maybe there's a better way.
        //
        UILabel *noTrannysLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 300, 100)];
        
        noTrannysLabel.text = @"There are no items to display.";
        noTrannysLabel.backgroundColor = [UIColor clearColor];
        noTrannysLabel.lineBreakMode = UILineBreakModeWordWrap;
        noTrannysLabel.numberOfLines = 2;
        
        [self.view addSubview:noTrannysLabel];
        [noTrannysLabel release];
        
    }
    
    if (dialogTitle != nil)
    {
        self.navigationItem.title = dialogTitle;
    }
    
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
    self.selectList = nil;
    self.selectIcons = nil;
    self.delegate = nil;
    self.dialogTitle = nil;
    self.selectedItem = nil;
    self.key = nil;
    self.closeButtonTitle = nil;
    self.tableBackgroundSelectedView = nil;
    
    [super dealloc];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [selectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:self.tableViewStyle reuseIdentifier:CellIdentifier] autorelease];
        
        //UITableViewCellStyleDefault
    }
    
    // Configure the cell...
    NSObject *item = [selectList objectAtIndex:indexPath.row];
    NSString *displayText = [item description];
    NSString *selectedItemText = @"";
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getTextOfItem:withKey:)])
    {
        displayText = [delegate getTextOfItem:item withKey:key];
        selectedItemText = [delegate getTextOfItem:selectedItem withKey:key];
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        displayText = (NSString *)item;
        selectedItemText = (NSString *)selectedItem;
    }
    
    [[cell textLabel] setText:displayText];
    
    if ([displayText isEqualToString:selectedItemText])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getDetailTextOfItem:withKey:)])
    {
        [[cell detailTextLabel] setText:[delegate getDetailTextOfItem:item withKey:key]];
    }
    
    if (indexPath.row < [self.selectIcons count])
    {
        cell.imageView.image = [UIImage imageNamed:[selectIcons objectAtIndex:indexPath.row]];
    }
    
    if (self.tableBackgroundSelectedView != nil)
    {
        [cell setSelectedBackgroundView:self.tableBackgroundSelectedView];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *item = [selectList objectAtIndex:indexPath.row];
    
    if (self.delegate)
    {
        [self.delegate simpleObjectDialogDismissed:item withKey:key];
    }
    else
    {
        NSLog(@"Yikes, no delegate implemented. This dialog will never go away. Bad programming!");
    }
    
}

#pragma mark - User Actions

- (IBAction)doneClicked:(id)sender 
{
    if (self.delegate)
    {
        [self.delegate simpleObjectDialogDismissed:self.selectedItem withKey:key];
    }
    else
    {
        NSLog(@"Yikes, no delegate implemented. This dialog will never go away. Bad programming!");
    }
}
@end
