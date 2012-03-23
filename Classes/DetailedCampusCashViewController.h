//
//  DetailedCampusCashViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@interface DetailedCampusCashViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView* _tableView;
	NSDictionary* _data;
}

@property (nonatomic, retain) NSDictionary* data;

- (void)addContactToAddressBook;

@end
