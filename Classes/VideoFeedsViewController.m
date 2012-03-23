//
//  VideoFeedsViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/13/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "VideoFeedsViewController.h"
#import "SVideoPlayerViewController.h"
#import "VideoTableViewCell.h"

@implementation VideoFeedsViewController
@synthesize videosTableView, videos, videoPlayer, activityIndicator;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	videosTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	videosTableView.dataSource = self;
	videosTableView.delegate = self;
	[self.view addSubview:videosTableView];
	
	// activity indicator
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	// UIActivityIndicator, adds it to right navigation button
	UIBarButtonItem *navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	[navigationRightItem release];
	
	self.navigationItem.title = @"Videos";
}

- (void)viewDidAppear:(BOOL)animated {
	[activityIndicator startAnimating];
	[FlurryAPI logEvent:@"Video Feeds"];
	
	[self performSelectorOnMainThread:@selector(getVideosData:) withObject:nil waitUntilDone:YES];
}

- (void)getVideosData:(id)sender {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *xmlData = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://urlforapi/videos.xml"]];
	
	videos = [[NSMutableArray alloc] init];
	
    CXMLDocument *rssParser = [[CXMLDocument alloc] initWithXMLString:xmlData options:0 error:nil];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//video" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		NSString *updated = [self getValueFromKey:@"updated" fromElement:resultElement];
		NSString *byline = [self getValueFromKey:@"byline" fromElement:resultElement];
		NSString *video = [self getValueFromKey:@"vid" fromElement:resultElement];
		NSString *comments = [self getValueFromKey:@"comments" fromElement:resultElement]; // boolean
		NSString *browser_link = [self getValueFromKey:@"browser_link" fromElement:resultElement];
		NSString *content = [self getValueFromKey:@"content" fromElement:resultElement];
		NSString *header = [self getValueFromKey:@"header" fromElement:resultElement];
		NSString *teaser = [self getValueFromKey:@"teaser" fromElement:resultElement];
		NSString *published = [self getValueFromKey:@"published" fromElement:resultElement];
		NSString *video_id = [self getValueFromKey:@"id" fromElement:resultElement];
		NSString *thumb = [self getValueFromKey:@"thumb" fromElement:resultElement];
		
		NSArray *keys = [[NSArray alloc] initWithObjects:@"updated",@"byline",@"video",@"comments",@"content",@"header",@"teaser",@"published",@"id",@"thumb",nil];
		NSArray *values = [[NSArray alloc] initWithObjects:updated,byline,video,comments,content,header,teaser,published,video_id,thumb,nil];
		NSDictionary *dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
		
		[videos addObject:dict];
		
		[keys release];
		[values release];
		[dict release];
	}
	
//	DLog(@"dict => %@", videos);
	[activityIndicator stopAnimating];
	[videosTableView reloadData];
	
	[rssParser release];	
	[pool release];
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element {
	if([[element elementsForName:key] count] == 0) return nil;
	NSString *value = [[[element elementsForName:key] objectAtIndex:0] stringValue];
	return value == nil ? @"" : value;
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [videos count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    VideoTableViewCell *cell = (VideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSDictionary *dict = [videos objectAtIndex:indexPath.row];
	[cell setData:dict];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(videoPlayer == nil)
		videoPlayer = [[SVideoPlayerViewController alloc] init];

	NSDictionary *dict = [videos objectAtIndex:indexPath.row];
	NSString *videoTitle = [[NSString alloc] initWithFormat:@"Video Played - %@",[dict valueForKey:@"header"]];
	[FlurryAPI logEvent:videoTitle];
	[videoTitle release];
	
	[videoPlayer playVideo:[dict objectForKey:@"video"]];
	[self presentModalViewController:videoPlayer animated:NO];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
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
	[activityIndicator release];
	[videoPlayer release];
	[videos release];
	[videosTableView release];
	[super dealloc];
}


@end
