//
//  MapViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import "CampusMapViewController.h"

@implementation CampusMapViewController
@synthesize currentLocation, annotations, searchbar;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480-44)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	// mapview
	map = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,320,372)];
	[self.view addSubview:map];

	// corelocation button
	corelocationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"corelocation.png"] style:UIBarButtonItemStyleBordered 
																			 target:self action:@selector(toggleCoreLocation:)];
	corelocationButton.enabled = YES;
	
	// map controls (normal, satellite, hybrid) view
	mapControls = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Map", @"Satellite", @"Hybrid", nil]];
	mapControls.segmentedControlStyle = UISegmentedControlStyleBar;
	mapControls.tintColor = [UIColor colorWithRed:.451 green:.188 blue:.529 alpha:1.0];
	mapControls.momentary = NO;
	mapControls.frame = CGRectMake(0,0,244,30);	
	[mapControls addTarget:self action:@selector(toggleMapControls:) forControlEvents:UIControlEventValueChanged];
	[mapControls setSelectedSegmentIndex:0];
	
	// bar button to add the segemented control into
	UIBarButtonItem *mapControlButton = [[UIBarButtonItem alloc] initWithCustomView:mapControls];
	
	// tool bar
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,416-44,320,44)];
	toolbar.barStyle = UIBarStyleBlackOpaque;
	[toolbar setItems:[NSArray arrayWithObjects:corelocationButton, mapControlButton, nil]];
	[self.view addSubview:toolbar];

	// search bar on top
	searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
	searchbar.delegate = self;
	searchbar.tintColor = [GlobalMethods getColor:@"dark"];
	[searchbar sizeToFit];

	self.navigationItem.titleView = searchbar;
	annotations = [[NSMutableArray alloc] init];
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	[searchbar resignFirstResponder];
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
//		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		return [annotationView autorelease];
	}
	
	return annotationView;
}

- (void)populateAnnotationList {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"campus_map" ofType:@"plist"];
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
	
	for(NSString *key in [dictionary allKeys]) {
		NSDictionary *location = [dictionary objectForKey:key];
		
		CLLocationCoordinate2D courseCoord;
		courseCoord.latitude = [[location valueForKey:@"latitude"] doubleValue];
		courseCoord.longitude = [[location valueForKey:@"longitude"] doubleValue];
		
		[self addAnnotation:courseCoord andTitle:key andSubtitle:[location valueForKey:@"address"]];		
	}
	
	[dictionary release];
}

- (void)populateMap {	
	for(AnnoteObject *annote in annotations) {
		[map addAnnotation:annote];
		//	[mapView selectAnnotation:annote animated:YES];
		currentLocation = annote.coordinate;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	map.delegate = self;
	
	[self populateAnnotationList];
	[self populateMap];
			
	MKCoordinateRegion region;
	
	CLLocationCoordinate2D nyu;
	nyu.latitude = 40.727974f;
	nyu.longitude = -73.996911f;
	
	region.center = nyu;
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.005f;
	span.longitudeDelta = 0.005f;
	region.span = span;
	
	[map setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	[searchbar resignFirstResponder];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	id <MKAnnotation> aa = [[views objectAtIndex:0] annotation];
	[mapView selectAnnotation:aa animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	DLog(@"%@", searchText);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[map removeAnnotations:[map annotations]];
	[self populateMap];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[map removeAnnotations:[map annotations]];
	[self populateMap];
	
	if(![searchBar.text isEqualToString:@""]) {
		for(AnnoteObject *annote in annotations) {
			NSRange result = [annote.title rangeOfString:searchBar.text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
										 
			if(result.location == NSNotFound) {
				[map removeAnnotation:annote];
			}
		}
	}
    [searchBar resignFirstResponder];
}

- (void)addAnnotation:(CLLocationCoordinate2D)coord andTitle:(NSString*)title andSubtitle:(NSString*)subtitle {
	AnnoteObject *annote = [[AnnoteObject alloc] initWithCoordinate:coord];
	annote.title = title;
	annote.subtitle = subtitle;
	[annotations addObject:annote];
	[annote release];
}

- (void)toggleCoreLocation:(id)sender {
	map.showsUserLocation = YES;

	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

	[locationManager startUpdatingLocation];
}

- (void)toggleMapControls:(id)sender {
	UISegmentedControl *control = (UISegmentedControl*)sender;
	NSInteger selectedItem = [control selectedSegmentIndex];
	
	if(selectedItem == 0)
		[map setMapType:MKMapTypeStandard];
	else if(selectedItem == 1)
		[map setMapType:MKMapTypeSatellite];
	else
		[map setMapType:MKMapTypeHybrid];
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	DLog(@"searching => %@", searchText);
}

#pragma mark corelocation
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	MKCoordinateRegion region;
	region.center = newLocation.coordinate;
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.005f;
	span.longitudeDelta = 0.005f;
	region.span = span;
	
	[map setRegion:region animated:YES];
	[manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

}

#pragma mark -
#pragma mark reversegeocoder
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{

}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
	[map removeAnnotation:[[map annotations] objectAtIndex:0]];
	[map addAnnotation:placemark];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[annotations release];
    [super dealloc];
}

@end
