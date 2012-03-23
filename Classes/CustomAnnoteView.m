//
//  CustomAnnoteView.m
//  Deal Compass
//
//  Copyright 2010 Naked Apartments. All rights reserved.
//

#import "CustomAnnoteView.h"

@implementation CustomAnnoteView
@synthesize data;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation {
	super.annotation = annotation;
}

- (void)dealloc {
	[data release];
	[super dealloc];
}

@end
