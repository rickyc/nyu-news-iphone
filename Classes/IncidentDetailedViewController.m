//
//  IncidentDetailedViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 12/27/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "IncidentDetailedViewController.h"
#import "AnnoteObject.h"

#define kSummary 5

@implementation IncidentDetailedViewController
@synthesize data, detailedTableView;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	detailedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416) style:UITableViewStyleGrouped];
	detailedTableView.dataSource = self;
	detailedTableView.delegate = self;
	[self.view addSubview:detailedTableView];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
		return 1;
	else
		return 6;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DefaultCell";
    static NSString *CellIdentifier2 = @"MapCell";
    static NSString *CellIdentifier3 = @"SummaryCell";
    
	int row = indexPath.row;
	int section = indexPath.section;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
   
    if(section == 0 && row == 0) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3] autorelease];

		MKMapView *map = [[MKMapView alloc] initWithFrame:CGRectMake(20,15,280,200)];
		[map setUserInteractionEnabled:NO];
		[map setDelegate:self];
		[map setMapType:MKMapTypeStandard];	

		CLLocationCoordinate2D location = { [[data objectForKey:@"lat"] floatValue], [[data objectForKey:@"lon"] floatValue] };
		MKCoordinateRegion region;
		region.center = location;
		
		MKCoordinateSpan span;
		span.latitudeDelta = 0.001;
		span.longitudeDelta = 0.001;
		region.span = span;
		
		AnnoteObject *annote = [[AnnoteObject alloc] initWithCoordinate:location];
		annote.title = [data objectForKey:@"location"];
		[map addAnnotation:annote];
		[annote release];
		
		[map setRegion:region animated:YES];
		[cell addSubview:map];
		[map release];
	} else if(section == 1) {		
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];		
		cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
		
		if(row == 0) {
			cell.detailTextLabel.text = [data objectForKey:@"category"];
			cell.textLabel.text = @"Category:";
		} else if(row == 1) {
			cell.detailTextLabel.text = [data objectForKey:@"location"];
			cell.textLabel.text = @"Location:";
		} else if(row == 2) {	
			cell.textLabel.text = @"Incident #:";
			cell.detailTextLabel.text = [data objectForKey:@"number"];
		} else if(row == 3) {
			cell.textLabel.text = @"Reported:";
			cell.detailTextLabel.text = [GlobalMethods convertSQLToLongDate:[data objectForKey:@"reported"]];		
		} else if(row == 4) {
			cell.textLabel.text = @"Status:";
			cell.detailTextLabel.text = [data objectForKey:@"status"];
		} else if(row == kSummary) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];

			UITextView *summary = [[UITextView alloc] initWithFrame:CGRectMake(20,15,280,160)];
			summary.text = [data objectForKey:@"summary"];
			summary.font = [UIFont systemFontOfSize:14];
			summary.userInteractionEnabled = NO;
			[cell addSubview:summary];
			[summary release];
		}
	}
		
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0 && indexPath.row == 0) {
		return 230;
	} else if(indexPath.row == kSummary) {
		return 180;
	}
	
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Annotation Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isMemberOfClass:[AnnoteObject class]]) {
		MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
		
		if(annotationView == nil)
			annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];			
		
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;	
		annotationView.pinColor = MKPinAnnotationColorPurple;
		
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

#pragma mark -
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
	[data release];
    [super dealloc];
}

@end
