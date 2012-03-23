//
//  CrimeLogViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 12/27/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AnnoteObject.h"
#import "TouchXML.h"
#import "IncidentDetailedViewController.h"

@interface CrimeLogViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
	NSMutableArray *annotations;
	NSArray *incidents;
	NSMutableData *receivedData;
	NSInteger page;
}

@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) NSArray *incidents;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, assign) NSInteger page;

- (void)loadData;
- (NSArray*)parseXMLData:(NSString*)xmlData;
- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element;
- (AnnoteObject*)createAnnotation:(NSDictionary*)data;

@end