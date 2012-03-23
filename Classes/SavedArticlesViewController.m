//
//  SavedArticlesViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 9/3/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import "SavedArticlesViewController.h"
#import "ArticleTableViewCell.h"
#import "ArticleViewController.h"

@implementation SavedArticlesViewController
@synthesize savedArticlesTable, articleViewController, headerBackground;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	savedArticlesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	savedArticlesTable.dataSource = self;
	savedArticlesTable.delegate = self;
	[self.view addSubview:savedArticlesTable];
}

- (void)viewDidLoad {
	if(headerBackground == nil) {
		headerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,44)];
		headerBackground.image = [UIImage imageNamed:@"logo.png"];
		[self.navigationController.navigationBar insertSubview:headerBackground atIndex:0];
	}
	
	self.navigationController.navigationBar.tintColor = [GlobalMethods getColor:@"dark"];
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = @"";
	headerBackground.hidden = NO;	
}

- (void)viewWillDisappear:(BOOL)animated {
	headerBackground.hidden = YES;
	self.navigationItem.title = @"NYU WSN";
}

- (void) viewDidAppear:(BOOL)animated {
	[savedArticlesTable reloadData];
}

#pragma mark Table view methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 78;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	NSInteger count = [savedArticlesDictionary count];
	[savedArticlesDictionary release];
    return count > 0 ? count : 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
    if([savedArticlesDictionary count] == 0) {
		[savedArticlesDictionary release];
		static NSString *CellIdentifier2 = @"Cell2";
		
		UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		}
		
		cell.textLabel.text = @"No Favorites";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		return cell;
	}
	
	// default saved articles cell
	static NSString *CellIdentifier = @"Cell";
    
    ArticleTableViewCell *cell = (ArticleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSString *key = [[[savedArticlesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row]; 
	NSDictionary *article = [savedArticlesDictionary objectForKey:key];
							 
	[cell setData:article];
	
    return cell;
}

- (NSArray*)dictionaryToArticlesArray {
	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

	NSMutableArray *articlesArray = [[NSMutableArray alloc] init];
	
	for(NSString *key in [[savedArticlesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
		[articlesArray addObject:[savedArticlesDictionary objectForKey:key]];
	}
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:articlesArray] forKeys:[NSArray arrayWithObject:@"articles"]];
	
	[savedArticlesDictionary release];
	return [NSArray arrayWithObject:dict];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
    if([savedArticlesDictionary count] > 0) {		
		ArticleViewController *avc = [[ArticleViewController alloc] init];
		avc.articleID = indexPath;
		avc.articles = [self dictionaryToArticlesArray];
		avc.hidesBottomBarWhenPushed = YES;
		articleViewController = [avc retain];
		[avc release];
		[self.navigationController pushViewController:avc animated:YES];
	}
	[savedArticlesDictionary release];
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
	[articleViewController release];
	[savedArticlesTable release];
    [super dealloc];
}

@end
