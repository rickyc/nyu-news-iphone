//
//  ContactsViewController.h
//  NYUWSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailedContactViewController.h"

@interface ContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
	DetailedContactViewController *detailedContactViewController;
	UITableView *contactsTable;
	UISearchBar *searchBar;
	UISearchDisplayController *searchDisplayController;
	NSArray *contacts;
	NSMutableArray *filteredContacts;
}

@property(nonatomic, retain) DetailedContactViewController *detailedContactViewController;
@property(nonatomic, retain) UITableView *contactsTable;
@property(nonatomic, retain) UISearchBar *searchBar;
@property(nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property(nonatomic, retain) NSArray *contacts;
@property(nonatomic, retain) NSMutableArray *filteredContacts;

@end
