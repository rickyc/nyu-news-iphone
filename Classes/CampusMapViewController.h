//
//  MapViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AnnoteObject.h"

@interface CampusMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate, UISearchBarDelegate> {
	MKMapView *map;
	UIBarButtonItem *corelocationButton;
	UISegmentedControl *mapControls;
	UISearchBar *searchbar;
	UIToolbar *toolbar;
	
	CLLocationManager *locationManager;
	CLLocationCoordinate2D currentLocation;
	NSMutableArray *annotations;
}

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) UISearchBar *searchbar;

- (void)toggleCoreLocation:(id)sender;
- (void)toggleMapControls:(id)sender;
- (void)addAnnotation:(CLLocationCoordinate2D)coord andTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
