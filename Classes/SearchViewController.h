//
//  SearchViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 6/25/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h";

@interface SearchViewController : NewsViewController <UISearchBarDelegate> {
	UISearchBar *searchbar;
}

@property(nonatomic, retain) UISearchBar *searchbar;

@end