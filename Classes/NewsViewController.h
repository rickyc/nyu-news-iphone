//
//  NewsViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 7/27/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

@class ArticleViewController;
@class EGORefreshTableHeaderView;

@interface NewsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
UISearchBarDelegate, ADBannerViewDelegate> {
	UITableView *articlesTable;
	NSMutableArray *latestArticles;
	NSString *feedURL;
	NSString *uniqueIdentifer;
	UIActivityIndicatorView *activityIndicator;
	
	UIView *preloaderView;
	UIActivityIndicatorView *loadingActivity;
	
	UIImageView *headerBackground;
	
	ArticleViewController *articleViewController;
	
	BOOL initialLoad;
	BOOL xmlCompletelyLoaded;
	BOOL paginationParse;
	NSInteger page;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL reloading;  // should be pulled from datasource
	
	UIView *_contentView;
	id _adBannerView;
	BOOL _adBannerViewIsVisible;
}

@property(nonatomic, retain) UITableView *articlesTable;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UIView *preloaderView;
@property(nonatomic, retain) UIImageView *headerBackground;
@property(nonatomic, retain) ArticleViewController *articleViewController;
@property(nonatomic, retain) NSArray *latestArticles;
@property(nonatomic, retain) NSString *feedURL;
@property(nonatomic, retain) NSString *uniqueIdentifer;
@property(nonatomic, assign) BOOL initialLoad;
@property(nonatomic, assign) BOOL xmlCompletelyLoaded;
@property(nonatomic, assign) BOOL paginationParse;
@property(nonatomic, assign) NSInteger page;

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

- (void)startPreloader;
- (id)initWithFeed:(NSString*)feed;
- (void)getArticles:(NSNumber*)appendToBottom;
- (void)persistData;
- (NSInteger)articleCount;

- (void)loadSavedArticles;
- (void)loadArticlesHelper;
- (void)appendArticlesToTop;
- (void)dataSourceDidFinishLoadingNewData;
- (void)mergeOldArticlesWithNewArticles:(NSArray*)source;
- (void)createAdBannerView;
- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;

@end

@protocol UITableViewReloadDataSource
- (void)reloadTableViewDataSource;
@end