//
//  SectionHeaderView.m
//  NYU Registrar
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "SectionHeaderView.h"

@implementation SectionHeaderView
@synthesize titleLabel;

- (void)setTitleLabel:(NSString *)s {
	[titleLabel release];
	titleLabel = [s copy];
	[self setNeedsDisplay]; 
}

-(void)drawInContext:(CGContextRef)context {					  
	UIImage *bg = [UIImage imageNamed:@"section_header.png"];
	[bg drawAtPoint:CGPointMake(0,0)];
	[[UIColor whiteColor] set];
	[titleLabel drawAtPoint:CGPointMake(10,1) withFont:[UIFont boldSystemFontOfSize:16]];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	

}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	

}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	

}

- (void)dealloc {
	[titleLabel release];
    [super dealloc];
}

@end