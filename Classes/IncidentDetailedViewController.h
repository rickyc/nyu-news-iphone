//
//  IncidentDetailedViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 12/27/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface IncidentDetailedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate> {
	NSDictionary *data;
	UITableView *detailedTableView;
}

@property(nonatomic, retain) NSDictionary *data;
@property(nonatomic, retain) UITableView *detailedTableView;

@end