//
//  ContactsViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "ContactsViewController.h"

@implementation ContactsViewController
@synthesize contactsTable, searchBar, searchDisplayController, contacts, filteredContacts, detailedContactViewController;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	contactsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contactsTable.dataSource = self;
	contactsTable.delegate = self;
	[self.view addSubview:contactsTable];
	
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
	searchBar.delegate = self;
	searchBar.tintColor = [GlobalMethods getColor:@"dark"];
	searchBar.translucent = YES;
	contactsTable.tableHeaderView = searchBar;
	
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsDataSource = self;
	searchDisplayController.searchResultsDelegate = self;
	
	self.navigationItem.title = @"Staff List";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"plist"];
	contacts = [[NSArray alloc] initWithContentsOfFile:path];
	DLog(@"contacts => %@",contacts);
	[contactsTable reloadData];
	
	filteredContacts = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSArray *tContacts = (tableView == searchDisplayController.searchResultsTableView) ? filteredContacts : contacts;
    return [tContacts count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *tContacts = (tableView == searchDisplayController.searchResultsTableView) ? filteredContacts : contacts;
	return [[[tContacts objectAtIndex:section] objectForKey:@"members"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    NSArray *tContacts = (tableView == searchDisplayController.searchResultsTableView) ? filteredContacts : contacts;
	
	NSDictionary *staff = [[[tContacts objectAtIndex:indexPath.section] objectForKey:@"members"] objectAtIndex:indexPath.row];
	cell.textLabel.text = [staff objectForKey:@"name"];
	cell.detailTextLabel.text = [staff objectForKey:@"title"];
	
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *tContacts = (tableView == searchDisplayController.searchResultsTableView) ? filteredContacts : contacts;
	return [[tContacts objectAtIndex:section] objectForKey:@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"search clicked?");
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSArray *tContacts = (tableView == searchDisplayController.searchResultsTableView) ? filteredContacts : contacts;
	NSDictionary *staff = [[[tContacts objectAtIndex:indexPath.section] objectForKey:@"members"] objectAtIndex:indexPath.row];
	
	if(detailedContactViewController == nil)
		detailedContactViewController = [[DetailedContactViewController alloc] init];
	detailedContactViewController.contactInformation = staff;
	
	[self.navigationController pushViewController:detailedContactViewController animated:YES];
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	DLog(@"searching => %@",searchText);

	[filteredContacts removeAllObjects];
	
	for(NSDictionary *category in contacts) {
		
		BOOL results = NO;
		NSMutableArray *filteredMembersAry = [[NSMutableArray alloc] init];
		for (NSDictionary *staff in [category objectForKey:@"members"]) {
			NSComparisonResult result = [[staff objectForKey:@"name"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
																		range:NSMakeRange(0, [searchText length])];
			if(result == NSOrderedSame) {
				results = YES;
				DLog(@"staff => %@", staff);
				[filteredMembersAry addObject:staff];
			}
		}
		
		// if there was a match
		if(results) {
			NSArray *keys = [[NSArray alloc] initWithObjects:@"title",@"members",nil];
			NSArray *values = [[NSArray alloc] initWithObjects:[category objectForKey:@"title"],filteredMembersAry,nil];
			NSDictionary *category = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
			[filteredContacts addObject:category];
			
			[keys release];
			[values release];
			[category release];
			[filteredMembersAry release];
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	DLog(@"search string => %@",searchString);
    [self filterContentForSearchText:searchString scope:[[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[self filterContentForSearchText:[searchBar text] scope:[[searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)dealloc {
	[detailedContactViewController release];
	[filteredContacts release];
	[searchDisplayController release];
	[searchBar release];
	[contactsTable release];
	[contacts release];
    [super dealloc];
}

@end

