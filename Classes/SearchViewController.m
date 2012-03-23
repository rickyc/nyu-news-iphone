//
//  SearchViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 6/25/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController
@synthesize searchbar;

- (void)loadView{
	[super loadView];
	
	searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
	searchbar.delegate = self;
	searchbar.tintColor = [GlobalMethods getColor:@"dark"];
	searchbar.showsCancelButton = YES;
	searchbar.placeholder = @"Search";
	
	articlesTable.tableHeaderView = searchbar;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"NYU WSN";
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	headerBackground.hidden = YES;
	
	[searchbar resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	headerBackground.hidden = NO;
	self.navigationItem.title = @"NYU WSN";
}

#pragma mark -
#pragma mark searchbar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[FlurryAPI logEvent:[NSString stringWithFormat:@"Search - %@",searchBar.text]];
	
	feedURL = [[NSString alloc] initWithFormat:@"http://urlforapi/search.xml?q=%@", searchBar.text];
	
	// rework this
	page = 1;
	latestArticles = [[NSMutableArray alloc] init];
		
	[activityIndicator startAnimating];
	[NSThread detachNewThreadSelector:@selector(getArticles:) toTarget:self withObject:nil];

    [searchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchbar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[searchbar resignFirstResponder];
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

- (void)dealloc {
    [super dealloc];
}

@end