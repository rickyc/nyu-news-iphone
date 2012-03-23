//
//  CategoriesViewController.h
//  NYUWSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h"

@interface CategoriesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *categoriesTable;
	NSDictionary *categoriesDictionary;
	NewsViewController *newsViewController;
	UIImageView *headerBackground;
}

@property(nonatomic, retain) UITableView *categoriesTable;
@property(nonatomic, retain) NSDictionary *categoriesDictionary;
@property(nonatomic, retain) NewsViewController *newsViewController;
@property(nonatomic, retain) UIImageView *headerBackground;

@end