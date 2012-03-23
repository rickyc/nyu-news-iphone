//
//  MultimediaViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/13/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageGalleryViewController.h"
#import "VideoFeedsViewController.h"
#import "CrimeLogViewController.h"
#import "DecoderViewController.h"
#import "NYULocalViewController.h"

@interface MultimediaViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *multimediaTableView;
	UIImageView *headerBackground;
	NSInteger shakeCount;
	NSTimer *easterEggTimer;
}

@property(nonatomic, retain) UITableView *multimediaTableView;
@property(nonatomic, retain) UIImageView *headerBackground;
@property(nonatomic, retain) NSTimer *easterEggTimer;

@end