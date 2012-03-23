//
//  MapViewController.m
//  NYU News
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController
@synthesize currentLocation, annotations;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       annotations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *annoteIdentifier = @"DefaultPinIdentifier";
	MKPinAnnotationView *annotationView = nil;

	if ([annotation isMemberOfClass:[AnnoteObject class]]) {
		annotationView = (MKPinAnnotationView*)[annotationView dequeueReusableCellWithIdentifier:annoteIdentifier];
		
		if(annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annoteIdentifier];			
		}

		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;	
		annotationView.pinColor = MKPinAnnotationColorPurple;
			
		return [annotationView autorelease];
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	id <MKAnnotation> aa = [[views objectAtIndex:0] annotation];
	[mapView selectAnnotation:aa animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mapView.delegate = self;
	
	for(AnnoteObject *annote in annotations) {
		[mapView addAnnotation:annote];
		[mapView selectAnnotation:annote animated:YES];
		currentLocation = annote.coordinate;
	}
	
	MKCoordinateRegion region;
	region.center = currentLocation;
	MKCoordinateSpan span;	
	span.latitudeDelta = .005;
	span.longitudeDelta = .005;
	region.span = span;
	
	[mapView setRegion:region animated:YES];
}

- (void)addAnnotation:(CLLocationCoordinate2D)coord andTitle:(NSString*)title andSubtitle:(NSString*)subtitle {
	AnnoteObject *annote = [[AnnoteObject alloc] initWithCoordinate:coord];
	annote.title = title;
	annote.subtitle = subtitle;
	[annotations addObject:annote];
	[annote release];
}

- (IBAction)toggleCoreLocation:(id)sender {
	mapView.showsUserLocation = YES;
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	
	[locationManager startUpdatingLocation];
}

- (IBAction)toggleMapControls:(id)sender {
	UISegmentedControl *control = (UISegmentedControl*)sender;
	NSInteger selectedItem = [control selectedSegmentIndex];
	
	if(selectedItem == 0)
		[mapView setMapType:MKMapTypeStandard];
	else if(selectedItem == 1)
		[mapView setMapType:MKMapTypeSatellite];
	else
		[mapView setMapType:MKMapTypeHybrid];
}

#pragma mark corelocation
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	MKCoordinateRegion region;
	region.center = mapView.userLocation.coordinate;
	
	MKCoordinateSpan span;
	span.latitudeDelta = .005;
	span.longitudeDelta = .005;
	region.span = span;
	
	[mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

}

#pragma mark -
#pragma mark reversegeocoder
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{

}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
	[mapView removeAnnotation:[[mapView annotations] objectAtIndex:0]];
	[mapView addAnnotation:placemark];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[annotations release];
    [super dealloc];
}

@end
