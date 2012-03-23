//
//  CrimeLogViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 12/27/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "CrimeLogViewController.h"

extern NSString *const GMAP_ANNOTATION_SELECTED;

@implementation CrimeLogViewController
@synthesize map, incidents, annotations, receivedData, page;

NSString *const GMAP_ANNOTATION_SELECTED = @"ANSELECTED";

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	annotations = [[NSCountedSet alloc] init];
	
	map = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	[map setDelegate:self];
	[map setMapType:MKMapTypeStandard];
	
	CLLocationCoordinate2D nyc = {40.733210,-73.993263};
	
	MKCoordinateRegion region;
	region.center = nyc;
	 
	MKCoordinateSpan span;
	span.latitudeDelta = 0.017058;
	span.longitudeDelta = 0.0127466;
	region.span = span;
	
	[map setRegion:region animated:YES];
	
	[self.view addSubview:map];
}

- (void)viewDidLoad {
	self.navigationItem.title = @"Crime Logs";
	[self loadData];
}

- (void)loadData {
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://urlforapi/crime.xml"]];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (conn)
		receivedData = [[NSMutableData data] retain];	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { 
    [receivedData setLength:0];  
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data { 
	[receivedData appendData:data];  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
	NSMutableString *dataString = [[NSMutableString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//	DLog(@"data => %@",dataString);
	incidents = [self parseXMLData:dataString];
	
	for (NSDictionary *incident in incidents) {
		AnnoteObject *annote = [self createAnnotation:incident];
		[map addAnnotation:[annote retain]];
	}
	
	[dataString release];
}

- (NSArray*)parseXMLData:(NSString*)xmlData {
	CXMLDocument *rssParser = [[CXMLDocument alloc] initWithXMLString:xmlData options:0 error:nil];
	
	NSString *nodePath = @"//incident";
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    NSArray *resultNodes = [rssParser nodesForXPath:nodePath error:nil];
	
	if([resultNodes count] == 0)
		return nil;
	
	NSMutableArray *incidentsAry = [[NSMutableArray alloc] init];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		NSString *category = [self getValueFromKey:@"category" fromElement:resultElement];
		NSString *status = [self getValueFromKey:@"status" fromElement:resultElement];
		NSString *lat = [self getValueFromKey:@"lat" fromElement:resultElement];
		NSString *lon = [self getValueFromKey:@"lon" fromElement:resultElement];
		NSString *number = [self getValueFromKey:@"number" fromElement:resultElement];
		NSString *summary = [self getValueFromKey:@"summary" fromElement:resultElement];
		NSString *reported = [self getValueFromKey:@"reported" fromElement:resultElement];
		NSString *location = [self getValueFromKey:@"location" fromElement:resultElement];
		NSString *date = [self getValueFromKey:@"date" fromElement:resultElement];
		NSString *incident_id = [self getValueFromKey:@"id" fromElement:resultElement];
		
		NSArray *keys = [[NSArray alloc] initWithObjects:@"category",@"status",@"lat",@"lon",@"number",@"summary",
						 @"reported",@"location",@"date",@"incidentid",nil];
		NSArray *values = [[NSArray alloc] initWithObjects:category,status,lat,lon,number,summary,reported,location,date,
						   incident_id,nil];
		
		//		DLog(@"keys => %@",keys);
		//		DLog(@"values => %@",values);
		
		NSDictionary *dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
		[incidentsAry addObject:dict];
		
		[keys release];
		[values release];
		[dict release];
	}	
	[rssParser release];
	
	return [incidentsAry autorelease];
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element {
	if([[element elementsForName:key] count] == 0) return nil;
	NSString *value = [[[element elementsForName:key] objectAtIndex:0] stringValue];
	return value == nil ? @"" : value;
}

- (AnnoteObject*)createAnnotation:(NSDictionary*)data {
	CLLocationCoordinate2D coord = {[[data objectForKey:@"lat"] floatValue],[[data objectForKey:@"lon"] floatValue]};
	AnnoteObject *annote = [[AnnoteObject alloc] initWithCoordinate:coord];
	annote.title = [data objectForKey:@"category"];
	annote.subtitle = [data objectForKey:@"summary"];
	annote.data = data;
	
	return [annote autorelease];
}

#pragma mark -
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isMemberOfClass:[AnnoteObject class]]) {
		MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
		
		if(annotationView == nil) {
			annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];			
		}
		
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;	
		annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		return [annotationView autorelease];
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
	IncidentDetailedViewController *idvc = [[IncidentDetailedViewController alloc] init];
	idvc.data = ((AnnoteObject*)view.annotation).data;
	[self.navigationController pushViewController:idvc animated:YES];
	[idvc release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[super dealloc];
}

@end