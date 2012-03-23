//
//  NewsViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 7/27/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "NewsViewController.h"
#import "ArticleTableViewCell.h"
#import "ArticleXMLParser.h"
#import "SectionHeaderView.h"
#import "ArticleViewController.h"
#import "EGORefreshTableHeaderView.h"

#define kReleaseToReloadStatus 0
#define kPullToReloadStatus 1
#define kLoadingStatus 2

@class NYUWSNAppDelegate;
@class SearchViewController;

@implementation NewsViewController
@synthesize articlesTable, latestArticles, preloaderView, activityIndicator, articleViewController, feedURL, xmlCompletelyLoaded, 
paginationParse, page, headerBackground, initialLoad, uniqueIdentifer;

@synthesize contentView = _contentView;
@synthesize adBannerView = _adBannerView;
@synthesize adBannerViewIsVisible = _adBannerViewIsVisible;

- (id)initWithFeed:(NSString*)feed {
	[super init];
	self.feedURL = feed;
	return self;
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	// activity indicator
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
		
	// UIActivityIndicator, adds it to right navigation button
	UIBarButtonItem *navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	[navigationRightItem release];

	articlesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	articlesTable.dataSource = self;
	articlesTable.delegate = self;
	[self.view addSubview:articlesTable];
	
	// modify
	refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - articlesTable.bounds.size.height, 320.0f, articlesTable.bounds.size.height)];
	refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
	[articlesTable addSubview:refreshHeaderView];
	articlesTable.showsVerticalScrollIndicator = YES;
	[refreshHeaderView release];
	
	// not the search class, preload
	if (![self isKindOfClass:[SearchViewController class]]) {
		initialLoad = YES;
		[self startPreloader];
	}
}

- (void)startPreloader {
	preloaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	[self.view addSubview:preloaderView];
	
	// news background & loading view
	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	backgroundImage.image = [UIImage imageNamed:@"news_background.png"];
	[preloaderView addSubview:backgroundImage];
	[backgroundImage release];
	
	UILabel *loading = [[UILabel alloc] initWithFrame:CGRectMake(130,self.view.frame.size.height/2 - 23,320,25)];
	loading.backgroundColor = [UIColor clearColor];
	loading.text = @"Loading...";
	[preloaderView addSubview:loading];
	[loading release];
	
	loadingActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100,self.view.frame.size.height/2-20,25,25)];
	[loadingActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray]; 
	[loadingActivity sizeToFit];
	[loadingActivity startAnimating];
	[preloaderView addSubview:loadingActivity];
}

- (void)stopPreloader {
	[preloaderView removeFromSuperview];
	[loadingActivity stopAnimating];
}

- (void) viewWillAppear:(BOOL)animated {
	//[self refresh];
    [self fixupAdView:[UIDevice currentDevice].orientation];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self createAdBannerView];
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30 target: self selector: @selector(fadeOutAd:) userInfo:nil repeats:NO];
	latestArticles = [[NSMutableArray alloc] init];

	DLog(@"feed url => %@", feedURL);
}

// Fades out the ad for thirty seconds.
- (void)fadeOutAd:(NSTimer*)timer {
	_adBannerViewIsVisible = NO;
	[self fixupAdView:[UIDevice currentDevice].orientation];
}

- (void)viewDidAppear:(BOOL)animated {
	if(![GlobalMethods isNetworkAvailable]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connectivity" message:@"An error has occurred. Please check your network settings and try again." 
													   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self loadSavedArticles];
	} else {
		[self loadArticlesHelper];
	}
}

- (void)loadSavedArticles {
	[self stopPreloader];

	if(uniqueIdentifer != nil) {
		NSString *writableDBPath = [GlobalMethods getPathByUniqueIdentifier:uniqueIdentifer];

		if ([GlobalMethods fileExistsAtPath:writableDBPath])
			latestArticles = [[NSMutableArray alloc] initWithContentsOfFile:writableDBPath];
		
		// if more than fifty articles start removing old ones
		if([self articleCount] > 50)
			[latestArticles removeObjectAtIndex:[latestArticles count]-1];
		
		[articlesTable reloadData];
	}
}

- (NSInteger)articleCount {
	NSInteger count = 0;
	if (latestArticles == nil)
		return 0;
	
	for(NSDictionary *dict in latestArticles)
		count += [[dict objectForKey:@"articles"] count];
	return count;
}

- (void)loadArticlesHelper {
	// first check if a unique ID exists
	if(uniqueIdentifer != nil && initialLoad) {
		// next check if there are previously saved articles
		NSString *writableDBPath = [GlobalMethods getPathByUniqueIdentifier:uniqueIdentifer];
		initialLoad = NO;
		
		// if the file does not exist, then create the file
		if (![GlobalMethods fileExistsAtPath:writableDBPath]) {
			[activityIndicator startAnimating];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[self performSelectorOnMainThread:@selector(getArticles:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
		} else {
			[self loadSavedArticles];
			[refreshHeaderView toggleActivityView];
			[NSThread detachNewThreadSelector:@selector(refreshArticles:) toTarget:self withObject:nil];
		}
	}
}

// appends article to a list of articles that already exists 
- (void)refreshArticles:(id)sender {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	ArticleXMLParser *parser = [[ArticleXMLParser alloc] init];
	
	if([latestArticles count] == 0) {
		[self getArticles:[NSNumber numberWithBool:NO]];
	} else {
		NSDictionary *result = [[parser getArrayFromRSSFeed:[NSString stringWithFormat:@"%@&num=1",feedURL]] objectAtIndex:0];
		NSString *refreshed_article_id = [[[result objectForKey:@"articles"] objectAtIndex:0] objectForKey:@"id"];
		NSString *current_latest_id = [[[[latestArticles objectAtIndex:0] objectForKey:@"articles"] objectAtIndex:0] objectForKey:@"id"];
		
		if(![refreshed_article_id isEqualToString:current_latest_id]) {
			[self appendArticlesToTop];
		}
		
		[self dataSourceDidFinishLoadingNewData];
	}
	
	[pool release];
}

- (void)appendArticlesToTop {
	ArticleXMLParser *parser = [[ArticleXMLParser alloc] init];
	NSMutableArray *result = [parser getArrayFromRSSFeed:[NSString stringWithFormat:@"%@&num=11",feedURL]];
	NSString *current_latest_id = [[[[latestArticles objectAtIndex:0] objectForKey:@"articles"] objectAtIndex:0] objectForKey:@"id"];
	NSString *current_latest_date = [[latestArticles objectAtIndex:0] objectForKey:@"date"];

	// if chomper is set to true, then everything that comes after it will be erased
	BOOL chomper = NO;
	
	NSMutableArray *source = [[NSMutableArray alloc] initWithArray:result];
	int idx=0;
	
	for(NSDictionary *item in result) {
		NSString *date = [item objectForKey:@"date"];

		if(chomper)
			[source removeObject:item];
		
		// dates are equal then append to same array
		if([date isEqualToString:current_latest_date]) {
			// loops through each article to locate if the latest one already exists in our table view
			NSMutableArray *articles = [[item objectForKey:@"articles"] copy];
			for(NSDictionary *article in articles) {
				NSString *article_id = [article objectForKey:@"id"];
				if([article_id isEqualToString:current_latest_id])
					chomper = YES;
				
				if(chomper)
					[[[source objectAtIndex:idx] objectForKey:@"articles"] removeObject:article];
			}
		}
		
		idx += 1;
	}
	
	[self mergeOldArticlesWithNewArticles:source];

	[articlesTable reloadData];
	[self persistData];

	DLog(@"append 2 top => %@",source);
}

// ---------------------------------------------------------------------------------------------------------------------
// when code becomes hacks it makes me sad =(      \/ - worse mess ever
- (BOOL)dateExistsInLatest:(NSString*)date {
	for (NSDictionary *dict in latestArticles) {
		if([date isEqualToString:[dict objectForKey:@"date"]])
			return YES;
	}
	return NO;
}

- (NSDictionary*)getDictionaryWithDate:(NSString*)date {
	for (NSDictionary *dict in latestArticles) {
		if([date isEqualToString:[dict objectForKey:@"date"]])
			return dict;
	}
	return nil;
}

// merge two article data sources together
- (void)mergeOldArticlesWithNewArticles:(NSArray*)source {
	for(int i=[source count]-1;i>=0;i--) {
		NSDictionary *newDict = [source objectAtIndex:i];
		
		if([[newDict objectForKey:@"articles"] count] != 0) {
			// if there is a duplicate date, a merge has to occur
			if([self dateExistsInLatest:[newDict objectForKey:@"date"]]) {
				NSDictionary *oldDict = [self getDictionaryWithDate:[newDict objectForKey:@"date"]];
				[[newDict objectForKey:@"articles"] addObjectsFromArray:[oldDict objectForKey:@"articles"]];
				[oldDict setValue:[newDict objectForKey:@"articles"] forKey:@"articles"];
			} else {
				[latestArticles insertObject:newDict atIndex:0];
			}
		}
		// end
	}
}
// ---------------------------------------------------------------------------------------------------------------------

// This appends 10 articles to the back of the table
- (void)getArticles:(NSNumber*)appendToBottom {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ArticleXMLParser *parser = [[ArticleXMLParser alloc] init];
	
	
	NSString *oldest_article_id = @"";
	if([appendToBottom boolValue]) {
		NSArray *oldestArticles = [[latestArticles objectAtIndex:[latestArticles count]-1] objectForKey:@"articles"];
		DLog(@"debuger => %@",oldestArticles);
		oldest_article_id = [[oldestArticles objectAtIndex:[oldestArticles count]-1] objectForKey:@"id"];
	}
	
	NSString *URL = [appendToBottom boolValue] ? [NSString stringWithFormat:@"%@&id=%@",feedURL,oldest_article_id] : feedURL;
	
	DLog(@"new url? => %@",URL);
	
	// last articles date
	NSMutableArray *results = [parser getArrayFromRSSFeed:URL];
	NSString *newestArticleDate = [[results objectAtIndex:0] objectForKey:@"date"];
	
	// when new articles are loaded, check the dates to see if the articles should append to the previous section or begin
	// a new section
	if([latestArticles count] > 0) {
		NSString *latestArticleDate = [[latestArticles objectAtIndex:latestArticles.count-1] objectForKey:@"date"];
		if([latestArticleDate isEqualToString:newestArticleDate]) {
			NSMutableDictionary *previousArticleDict = [latestArticles objectAtIndex:latestArticles.count-1];
			NSArray *previousArticles = [previousArticleDict objectForKey:@"articles"];
			NSArray *newestArticles = [[results objectAtIndex:0] objectForKey:@"articles"];
			[previousArticleDict setValue:[previousArticles arrayByAddingObjectsFromArray:newestArticles] forKey:@"articles"];
			
			// remove the appending article data from the current results array
			[results removeObjectAtIndex:0];
		}
	}
	
	// if there are no more results, stop trying to load more data
	if(results == nil) xmlCompletelyLoaded = YES;
		
	// append new section to the articles array
	[latestArticles setArray:[latestArticles arrayByAddingObjectsFromArray:[results retain]]];
	[parser release];
	
	// remove the preloader after the data has been loaded
	[self stopPreloader];
	
	[articlesTable reloadData];
	paginationParse = NO;
	[activityIndicator stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self persistData];
	
	[pool release];
}

- (void)persistData {
	if([latestArticles count] > 0)
		[GlobalMethods writeData:latestArticles toPath:[GlobalMethods getPathByUniqueIdentifier:uniqueIdentifer]];
}

#pragma mark -
- (CGFloat)getHeightOfText:(NSString*)text withFont:(UIFont*)font andBoundingWidth:(CGFloat)width {
	CGSize boundingSize = CGSizeMake(width, CGFLOAT_MAX);
	CGSize requiredSize = [text sizeWithFont:font constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat requiredHeight = requiredSize.height;
	
	return requiredHeight;
}

#pragma mark -
#pragma mark Table view methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return 78;
	
	NSDictionary *article = [[[latestArticles objectAtIndex:indexPath.section] objectForKey:@"articles"] objectAtIndex:indexPath.row];
	if([[article objectForKey:@"images"] count] == 0) {
		NSInteger headerHeight = [self getHeightOfText:[article objectForKey:@"header"] withFont:[UIFont boldSystemFontOfSize:14] andBoundingWidth:310];
		NSInteger teaserHeight = [self getHeightOfText:[article objectForKey:@"teaser"] withFont:[UIFont systemFontOfSize:12] andBoundingWidth:310];
		NSInteger sectionHeight = headerHeight + teaserHeight + 15;
		return sectionHeight > 78 ? 78 : sectionHeight;
	}
	
	return 78;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DebugLog(@"section => %d",[latestArticles count]);
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
//		cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
		
		return cell;
	}
	   
	float h = [articlesTable contentSize].height;
	float y = [articlesTable contentOffset].y;

//	DLog(@"(%f, %f) | page => %i",h,y,page);
	// if the scrolling surpasses the table height, load extra entries
	if(!xmlCompletelyLoaded && !paginationParse && y > h-367) {
		paginationParse = YES;
	//	page += 1;
		
		[activityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(getArticles:) toTarget:self withObject:[NSNumber numberWithBool:YES]];
	}
		
    static NSString *CellIdentifier = @"Cell";
    
    ArticleTableViewCell *cell = ( ArticleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSDictionary *article = [[[latestArticles objectAtIndex:indexPath.section] objectForKey:@"articles"] objectAtIndex:indexPath.row];
//	DLog(@"article => %@",article);
	[cell setData:article];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// if it is dispaying no results, do not allow the user to press the button
	if(xmlCompletelyLoaded && [latestArticles count] == 0) return;    
	
	headerBackground.hidden = YES;
	self.navigationItem.title = @"NYU WSN";
	
	ArticleViewController *avc = [[ArticleViewController alloc] init];
	avc.articleID = indexPath;
	avc.articles = latestArticles;
	avc.hidesBottomBarWhenPushed = YES;
	articleViewController = [avc retain];
	[avc release];
	[self.navigationController pushViewController:articleViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return nil;
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

#pragma mark -
#pragma mark pulldown to refresh
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	if (scrollView.isDragging) {
		if (refreshHeaderView.isFlipped && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kPullToReloadStatus];
		} else if (!refreshHeaderView.isFlipped && scrollView.contentOffset.y < -65.0f && !reloading) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kReleaseToReloadStatus];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (scrollView.contentOffset.y <= - 65.0f && !reloading) {
		if([articlesTable.dataSource respondsToSelector:@selector(reloadTableViewDataSource)]){
			reloading = YES;
			[(id)articlesTable.dataSource reloadTableViewDataSource];
			[refreshHeaderView toggleActivityView];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2];
			articlesTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
			[UIView commitAnimations];
		}
	}
}

- (void)dataSourceDidFinishLoadingNewData {
	reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[articlesTable setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView flipImageAnimated:NO]; //  reset view
	[refreshHeaderView toggleActivityView];	//  reset view
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

- (void)reloadTableViewDataSource{
	if ([latestArticles count] == 0) {
		// corner case
		[self performSelectorOnMainThread:@selector(getArticles:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
		[self dataSourceDidFinishLoadingNewData];
	} else {
		// main purpose of the pull to refresh
		[NSThread detachNewThreadSelector:@selector(refreshArticles:) toTarget:self withObject:nil];
	}
//	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (void)doneLoadingTableViewData{
//	[self dataSourceDidFinishLoadingNewData];
}

#pragma mark -
#pragma mark iAd
- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    return (UIInterfaceOrientationIsLandscape(orientation)) ? 32 : 50;
}

- (int)getBannerHeight {
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] 
							  initWithFrame:CGRectZero] autorelease];
        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
														  ADBannerContentSizeIdentifier320x50, 
														  ADBannerContentSizeIdentifier480x32, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier480x32];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier320x50];            
        }

		[_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, self.view.frame.size.height + [self getBannerHeight])];
        [_adBannerView setDelegate:self];
		
		//self.articlesTable.tableHeaderView = _adBannerView;
        [self.view addSubview:_adBannerView];
		self.articlesTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,50)];
    }
}

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (_adBannerView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier480x32];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier320x50];
        }          
        [UIView beginAnimations:@"fixupViews" context:nil];
		
        if (_adBannerViewIsVisible) {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 318;
            [_adBannerView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.origin.y = [self getBannerHeight:toInterfaceOrientation];
            contentViewFrame.size.height = self.view.frame.size.height - [self getBannerHeight:toInterfaceOrientation];
            _contentView.frame = contentViewFrame;
        } else {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = self.view.frame.size.height + [self getBannerHeight:toInterfaceOrientation];
            [_adBannerView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height;
            _contentView.frame = contentViewFrame;            
        }
        [UIView commitAnimations];
    }   
}

#pragma mark ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_adBannerViewIsVisible) {
        _adBannerViewIsVisible = YES;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (_adBannerViewIsVisible) {        
        _adBannerViewIsVisible = NO;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

#pragma mark -
- (void)dealloc {
	self.contentView = nil;
	self.adBannerView = nil;
	
	[headerBackground release];
	[loadingActivity release];
	[preloaderView release];
	[feedURL release];
	[uniqueIdentifer release];
	[articleViewController release];
	[latestArticles release];
	[activityIndicator release];
	[articlesTable release];
    [super dealloc];
}

@end
