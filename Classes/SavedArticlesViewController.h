//
//  SavedArticlesViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 9/3/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleViewController.h"

@interface SavedArticlesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *savedArticlesTable;
	ArticleViewController *articleViewController;
	UIImageView *headerBackground;
}

@property(nonatomic, retain) UITableView *savedArticlesTable;
@property(nonatomic, retain) ArticleViewController *articleViewController;
@property(nonatomic, retain) UIImageView *headerBackground;

@end
