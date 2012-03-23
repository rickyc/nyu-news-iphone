//
//  CampusCashSelectionTableViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Family. All rights reserved.
//

#import "CampusCashSelectionTableViewController.h"


@implementation CampusCashSelectionTableViewController
@synthesize criteriaData = _criteriaData;

- (id) init {
	if (self = [super init]) {
		
		_criteriaData = [[NSMutableArray alloc] init];
		
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"campus-cash" ofType:@"plist"];
		NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
		
		for (NSString* _key in dictionary)
			[_criteriaData addObject:[NSNumber numberWithBool:YES]];
	}
	
	return self;
}

#pragma mark -
#pragma mark Initialization
- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"campus-cash" ofType:@"plist"];
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [dictionary count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"campus-cash" ofType:@"plist"];
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSArray* keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString* _key = [keys objectAtIndex:indexPath.row];
	NSString* _annoteImage = [[dictionary objectForKey:_key] objectForKey:@"annotation-image"];

	cell.textLabel.text = _key;
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_annoteImage]];
	cell.accessoryType = [_criteriaData objectAtIndex:indexPath.row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	BOOL _currenlyChecked = [[_criteriaData objectAtIndex:indexPath.row] boolValue];
	[_criteriaData insertObject:[NSNumber numberWithBool:!_currenlyChecked] atIndex:indexPath.row];
	
	// flip the checkmark
	[tableView cellForRowAtIndexPath:indexPath].accessoryType = _currenlyChecked ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

