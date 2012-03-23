//
//  CategoriesViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "CategoriesViewController.h"

@implementation CategoriesViewController
@synthesize categoriesTable, categoriesDictionary, newsViewController;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	categoriesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	categoriesTable.dataSource = self;
	categoriesTable.delegate = self;
	[self.view addSubview:categoriesTable];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if(headerBackground == nil) {
		headerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,44)];
		headerBackground.image = [UIImage imageNamed:@"logo.png"];
		[self.navigationController.navigationBar insertSubview:headerBackground atIndex:0];
	}
	
	self.navigationController.navigationBar.tintColor = [GlobalMethods getColor:@"dark"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
	categoriesDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
	[categoriesTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = @"";
	headerBackground.hidden = NO;	
}

- (void)viewWillDisappear:(BOOL)animated {
	headerBackground.hidden = YES;
	self.navigationItem.title = @"NYU WSN";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [categoriesDictionary count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"section_silver.png"]];
	
	NSString *key = [[[categoriesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row]; 
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60,0,200,44)];
	label.text = [categoriesDictionary objectForKey:key];
	label.font = [UIFont boldSystemFontOfSize:20];
	label.backgroundColor = [UIColor clearColor];
	[cell addSubview:label];
	[label release];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_cat.png",key]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *key = [[[categoriesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row]; 
	NSString *feed = [[NSString alloc] initWithFormat:@"http://url/feed.xml?section=%@",key];

	// analytics
	[FlurryAPI logEvent:[NSString stringWithFormat:@"Categories - %@",key]];

	NewsViewController *nvc = [[NewsViewController alloc] initWithFeed:feed];
	nvc.navigationItem.title = [categoriesDictionary objectForKey:key];
	nvc.uniqueIdentifer = key;
	newsViewController = nvc;
	[self.navigationController pushViewController:newsViewController animated:YES];
	
	[feed release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[categoriesTable release];
	[categoriesDictionary release];
	[newsViewController release];
    [super dealloc];
}


@end
