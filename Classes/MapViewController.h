//
//  MapViewController.h
//  NYU News
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AnnoteObject.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate> {
	IBOutlet MKMapView *mapView;
	IBOutlet UIBarButtonItem *locateMeButton;
	IBOutlet UISegmentedControl *mapControls;
	
	CLLocationManager *locationManager;
	CLLocationCoordinate2D currentLocation;
	NSMutableArray *annotations;
}

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, retain) NSMutableArray *annotations;

- (IBAction)toggleCoreLocation:(id)sender;
- (IBAction)toggleMapControls:(id)sender;
- (void)addAnnotation:(CLLocationCoordinate2D)coord andTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
