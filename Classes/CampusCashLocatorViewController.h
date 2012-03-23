//
//  CampusCashLocatorViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Three20/Three20.h"

@class CampusCashSelectionTableViewController;

@interface CampusCashLocatorViewController : UIViewController <MKMapViewDelegate> {
	CampusCashSelectionTableViewController* _campusCashViewController;
	MKMapView* _mapView;
	NSMutableArray* _annotations;
}

@end
