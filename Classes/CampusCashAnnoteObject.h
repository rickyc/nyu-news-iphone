//
//  CampusCashAnnoteObject.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Family. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnoteObject.h"

@interface CampusCashAnnoteObject : AnnoteObject {
	UIImage* _categoryPinImage;
	NSString* _imageURL;
	NSDictionary* _data;
	BOOL _hidden;
}

@property (nonatomic, retain) UIImage* categoryPinImage;
@property (nonatomic, retain) NSDictionary* data;
@property (nonatomic, retain) NSString* imageURL;
@property (nonatomic, assign) BOOL hidden;

@end
