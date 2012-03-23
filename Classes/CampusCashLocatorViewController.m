//
//  CampusCashLocatorViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Family. All rights reserved.
//

#import "CampusCashLocatorViewController.h"
#import "CampusCashAnnoteObject.h"
#import "CustomAnnoteView.h"
#import "DetailedCampusCashViewController.h"
#import "CampusCashSelectionTableViewController.h"
#import "Utilities.h"

@implementation CampusCashLocatorViewController

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,420)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	_campusCashViewController = [[CampusCashSelectionTableViewController alloc] init];

	_annotations = [[NSMutableArray alloc] init];
	
	_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,320,420)];
	_mapView.delegate = self;
	_mapView.showsUserLocation = YES;
	[self.view addSubview:_mapView];
	
	MKCoordinateRegion region;
	
	CLLocationCoordinate2D _centerCoord = {40.730216, -73.995106};
	
	region.center = _centerCoord;
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.005f;
	span.longitudeDelta = 0.005f;
	region.span = span;
	
	[_mapView setRegion:region animated:YES];
	
	// search
	UIBarButtonItem* _searchCriteria = [[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://20-gear2.png") style:UIBarButtonItemStyleBordered 
														 target:self action:@selector(toggleSearchCriteria:)];
	self.navigationItem.rightBarButtonItem = _searchCriteria;
	self.navigationItem.title = @"Campus Cash";	
}

- (void)viewDidAppear:(BOOL)animated {
	[_mapView removeAnnotations:_mapView.annotations];
	[_annotations removeAllObjects];
	[self parsePList];
	[self populateMap];
}

- (void)populateMap {
	for(CampusCashAnnoteObject* _annote in _annotations) {
		[_mapView addAnnotation:_annote];
	}
}

- (void)parsePList {
	NSDictionary* _campusDictionary = [Utilities retrieveCachedPlistFromTTPath:@"wsn://campus-cash.plist"];
	if (_campusDictionary == nil) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"campus-cash" ofType:@"plist"];
		_campusDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
	} else {
		[Utilities downloadAndCacheFileFromURL:[NSString stringWithFormat:@"%@/iphone/nyu/wsn/campus-cash.plist",kRootURL] withTTPath:@"wsn://campus-cash.plist"];
	}

	NSArray* _keys = [[_campusDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	for (int i=0;i<[_keys count];i++) {
		BOOL _displayDataForKey = [[_campusCashViewController.criteriaData objectAtIndex:i] boolValue];
		if (!_displayDataForKey) continue;
		
		NSString* key = [_keys objectAtIndex:i];
		NSDictionary *dict = [_campusDictionary objectForKey:key];
		
		NSDictionary* locations = [dict objectForKey:@"locations"];
		NSString* _annotationImage = [dict objectForKey:@"annotation-image"];
		
		for (NSDictionary* _location in locations) {
			CLLocationCoordinate2D _coord;
			_coord.latitude = [[_location valueForKey:@"latitude"] doubleValue];
			_coord.longitude = [[_location valueForKey:@"longitude"] doubleValue];
			
			NSString* _merchantName = [_location objectForKey:@"merchant_name"];
			NSString* _address = [_location objectForKey:@"address"];
			NSString* _imageURL = [_location objectForKey:@"image_url"];
								   							
			// add annotation
			CampusCashAnnoteObject* _annote = [[CampusCashAnnoteObject alloc] initWithCoordinate:_coord];
			_annote.title = _merchantName;
			_annote.subtitle = _address;
			_annote.data = [_location retain];
			_annote.imageURL = _imageURL;
			_annote.categoryPinImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_annotationImage]];
			[_annotations addObject:_annote];
			TT_RELEASE_SAFELY(_annote);
		}
	}
}

- (void)toggleSearchCriteria:(id)sender {
	[self.navigationController pushViewController:_campusCashViewController animated:YES];
}

#pragma mark -
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	CampusCashAnnoteObject* _annote = (CampusCashAnnoteObject*)annotation;
	
	if ([annotation isMemberOfClass:[CampusCashAnnoteObject class]]) {
		CustomAnnoteView* annotationView = (CustomAnnoteView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
		
		if(annotationView == nil) {
			annotationView = [[[CustomAnnoteView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];			
		}

		if (_annote.imageURL != nil) {
			TTImageView* _iv = [[TTImageView alloc] initWithFrame:CGRectMake(0,0,32,32)];
			_iv.URL = _annote.imageURL;
			annotationView.leftCalloutAccessoryView = _iv;
			TT_RELEASE_SAFELY(_iv);
		}
		
		//annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		annotationView.image = _annote.categoryPinImage;
		
		return annotationView;
	}
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	CGRect visibleRect = [mapView annotationVisibleRect];
	for(MKAnnotationView *view in views) {
		CGRect endFrame = view.frame;
		
		CGRect startFrame = endFrame;
		startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
		view.frame = startFrame;
		
		[UIView beginAnimations:@"drop" context:NULL];
		view.frame = endFrame;
		[UIView commitAnimations];
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	DetailedCampusCashViewController *idvc = [[DetailedCampusCashViewController alloc] init];
	idvc.data = ((AnnoteObject*)view.annotation).data;
	[self.navigationController pushViewController:idvc animated:YES];
	[idvc release];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
