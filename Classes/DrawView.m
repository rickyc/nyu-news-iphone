//
//  DrawView.m
//  NYU WSN
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

-(void)drawInContext:(CGContextRef)context {
	// Default is to do nothing!
}

-(void)drawRect:(CGRect)rect {
	// Since we use the CGContextRef a lot, it is convienient for our demonstration classes to do the real work
	// inside of a method that passes the context as a parameter, rather than having to query the context
	// continuously, or setup that parameter for every subclass.
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

@end
