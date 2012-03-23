//
//  SectionHeaderView.h
//  NYU Registrar
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"

@interface SectionHeaderView : DrawView {
	NSString *titleLabel;
}

-(void)drawInContext:(CGContextRef)context;

@property(nonatomic, copy) NSString *titleLabel;

@end