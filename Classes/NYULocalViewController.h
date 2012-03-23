//
//  NYULocalViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 1/15/10.
//  Copyright 2010 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchXML.h"

@class ArticleViewController;

@interface NYULocalViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *articlesTable;
	NSMutableArray *latestArticles;
	UIImageView *headerBackground;
	ArticleViewController *articleViewController;

	BOOL xmlCompletelyLoaded;
}

@property (nonatomic, retain) UITableView *articlesTable;
@property (nonatomic, retain) NSMutableArray *latestArticles;
@property (nonatomic, retain) ArticleViewController *articleViewController;

- (void)loadRSSFeed;
- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element;
- (CGFloat)getHeightOfText:(NSString*)text withFont:(UIFont*)font andBoundingWidth:(CGFloat)width;

@end
