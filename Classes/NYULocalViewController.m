//
//  NYULocalViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 1/15/10.
//  Copyright 2010 Family. All rights reserved.
//

#import "NYULocalViewController.h"
#import "ArticleViewController.h"
#import "ArticleTableViewCell.h"
#import "SectionHeaderView.h"

@implementation NYULocalViewController
@synthesize articlesTable, latestArticles, articleViewController;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	articlesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	articlesTable.dataSource = self;
	articlesTable.delegate = self;
	articlesTable.backgroundColor = [UIColor blackColor];
	[self.view addSubview:articlesTable];
	
	self.navigationItem.title = @"NYU Local";
	[self loadRSSFeed];
}

- (void)getAds {
    
}

- (void)loadRSSFeed {
	NSString *feedURL = @"http://nyulocal.com/feed/";
	NSString *xmlData = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:feedURL]];
	
//	DLog(@"xml data => %@",xmlData);
	
	latestArticles = [[NSMutableArray alloc] init];
    CXMLDocument *rssParser = [[CXMLDocument alloc] initWithXMLString:xmlData options:0 error:nil];
	[xmlData release];

    NSArray *resultNodes = [rssParser nodesForXPath:@"//item" error:nil];
	
	if([resultNodes count] == 0)
		return nil;

	DLog(@"node => %@",resultNodes);
	
	NSString *currentDate = @"";
	NSMutableArray *articlesAry = [[NSMutableArray alloc] init];
	
	NSInteger nodeIndex = 0;
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		NSString *header = [GlobalMethods flattenHTML:[self getValueFromKey:@"title" fromElement:resultElement]];
		NSString *url = [self getValueFromKey:@"link" fromElement:resultElement];
		NSString *published = [self getValueFromKey:@"pubDate" fromElement:resultElement];
		NSString *cat = [self getValueFromKey:@"category" fromElement:resultElement];
		NSString *u_id = [self getValueFromKey:@"guid" fromElement:resultElement];
		NSString *description = [GlobalMethods flattenHTML:[self getValueFromKey:@"description" fromElement:resultElement]];
		NSString *content = [self renameFunctionName:resultElement atIndex:nodeIndex];
		
		// replace default date
		if([currentDate isEqualToString:@""]) currentDate = published;
		
		// dates are not equal means a new section
		if(![[currentDate substringToIndex:10] isEqualToString:[published substringToIndex:10]]) {
			NSArray *keys = [[NSArray alloc] initWithObjects:@"date", @"articles",nil];
			NSArray *values = [[NSArray alloc] initWithObjects:[self modifyLongToShortDate:currentDate],articlesAry,nil];
			NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
			[latestArticles addObject:dictionary];
			
			[articlesAry release];
			
			// set new date
			currentDate = published;
			articlesAry = [[NSMutableArray alloc] init];
			
			// release objects
			[dictionary release];
			[values release];
			[keys release];
		}
		
		// ----
		NSArray *keys = [[NSArray alloc] initWithObjects:@"header",@"byline",@"browser_link",@"published",@"cat",@"teaser",@"content",@"id",@"thumb",nil];
		NSArray *values = [[NSArray alloc] initWithObjects:header,@"NYU Local",url,published,cat,description,content,u_id,@"None",nil];
		
		NSDictionary *dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
		[articlesAry addObject:dict];
		
		[keys release];
		[values release];
		[dict release];
		
		// increment counter
		nodeIndex += 1;
	}	
	
	NSArray *keys = [[NSArray alloc] initWithObjects:@"date", @"articles",nil];
	NSArray *values = [[NSArray alloc] initWithObjects:[self modifyLongToShortDate:currentDate], articlesAry,nil];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
	[latestArticles addObject:dictionary];
	
	[articlesAry release];
	
	// release objects
	[dictionary release];
	[values release];
	[keys release];
	[rssParser release];
	
	DLog(@"dictionary2 => %@",latestArticles);
	
	[articlesTable reloadData];
	[self getAds];
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element {
	if([[element elementsForName:key] count] == 0) return nil;
	NSString *value = [[[element elementsForName:key] objectAtIndex:0] stringValue];
	value =[value stringByReplacingOccurrencesOfString:@"‚Ä¶" withString:@"..."];
	value = [value stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
	return value == nil ? @"" : value;
}

- (NSString*)renameFunctionName:(CXMLElement*)element atIndex:(NSInteger)index {
	NSDictionary *mappings = [NSDictionary dictionaryWithObject:@"http://purl.org/rss/1.0/modules/content/" forKey:@"content"];
	return [[[element nodesForXPath:@"//content:encoded" namespaceMappings:mappings error:nil] objectAtIndex:index] stringValue];
}

- (NSString*)modifyLongToShortDate:(NSString*)date {
	return [date substringToIndex:[date length]-15]; //6
}

#pragma mark -
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return 78;
	
	NSDictionary *article = [[[latestArticles objectAtIndex:indexPath.section] objectForKey:@"articles"] objectAtIndex:indexPath.row];
	NSInteger headerHeight = [self getHeightOfText:[article objectForKey:@"header"] withFont:[UIFont boldSystemFontOfSize:14] andBoundingWidth:310];
	NSInteger teaserHeight = [self getHeightOfText:[article objectForKey:@"teaser"] withFont:[UIFont systemFontOfSize:12] andBoundingWidth:310];
	NSInteger sectionHeight = headerHeight + teaserHeight + 15;
	return sectionHeight > 78 ? 78 : sectionHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DLog(@"section => %d",[latestArticles count]);
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return 1;
	return [latestArticles count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return 1;    
	return [[[latestArticles objectAtIndex:section] objectForKey:@"articles"] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return nil;
	
	SectionHeaderView *sectionView = [[SectionHeaderView alloc] init];
	sectionView.titleLabel = [[latestArticles objectAtIndex:section] objectForKey:@"date"];
	
	return [sectionView autorelease];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// default cell, no contents available
	if(xmlCompletelyLoaded && [latestArticles count] == 0) {
		static NSString *CellIdentifier2 = @"DefaultCell";
		
		UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		}
		
		cell.textLabel.text = @"No Results";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		return cell;
	}
	
    static NSString *CellIdentifier = @"Cell";
    
    ArticleTableViewCell *cell = ( ArticleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[ArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
   
	NSDictionary *article = [[[latestArticles objectAtIndex:indexPath.section] objectForKey:@"articles"] objectAtIndex:indexPath.row];
	DLog(@"article2 => %@",article);
	[cell setData:article];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// if it is dispaying no results, do not allow the user to press the button
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return;    
	
//	headerBackground.hidden = YES;
	self.navigationItem.title = @"NYU Local";
	
	ArticleViewController *avc = [[ArticleViewController alloc] init];
	avc.articleID = indexPath;
	avc.articles = latestArticles;
	avc.hidesBottomBarWhenPushed = YES;
	articleViewController = [avc retain];
	[avc release];
	[self.navigationController pushViewController:articleViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	DLog(@"footer section => %d",section);
	if(section == 0) {
		
	}
	
	return nil;
}

- (CGFloat)getHeightOfText:(NSString*)text withFont:(UIFont*)font andBoundingWidth:(CGFloat)width {
	CGSize boundingSize = CGSizeMake(width, CGFLOAT_MAX);
	CGSize requiredSize = [text sizeWithFont:font constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat requiredHeight = requiredSize.height;
	
	return requiredHeight;
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
