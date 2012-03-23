//
//  AnnoteObject.h
//  NYU WSN
//
//  Created by Ricky Cheng on 6/23/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnoteObject : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString* subtitle;
	NSString* title;
	NSDictionary* data;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDictionary *data;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end