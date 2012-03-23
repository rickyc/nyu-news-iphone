//
//  CampusCashSelectionTableViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Family. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CampusCashSelectionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView* _tableView;
	NSMutableArray* _criteriaData;
}

@property (nonatomic, retain) NSMutableArray* criteriaData;

@end
