//
//  AnnoteObject.m
//  NYU WSN
//
//  Created by Ricky Cheng on 6/23/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import "AnnoteObject.h"


@implementation AnnoteObject
@synthesize coordinate, subtitle, title, data;


-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate = c;
	return self;
}

@end