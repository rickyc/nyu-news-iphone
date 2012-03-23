//
//  CustomAnnoteView.h
//  Deal Compass
//
//  Copyright 2010 Naked Apartments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnoteView : MKAnnotationView {
	NSObject* data;
}

@property (nonatomic, retain) NSObject *data;

@end
