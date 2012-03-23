//
//  TouchImageView.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageGalleryViewController.h"

@interface TouchImageView : UIImageView {
	NSInteger image_id;
	ImageGalleryViewController *imageGalleryViewController;
}

@property(nonatomic,assign) NSInteger image_id;
@property(nonatomic,retain) ImageGalleryViewController *imageGalleryViewController;

@end
