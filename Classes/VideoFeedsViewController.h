//
//  VideoFeedsViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/13/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVideoPlayerViewController.h"
#import "TouchXML.h"

@interface VideoFeedsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	SVideoPlayerViewController *videoPlayer;
	UITableView *videosTableView;
	NSMutableArray *videos;
	UIActivityIndicatorView *activityIndicator;
}

@property(nonatomic, retain) SVideoPlayerViewController *videoPlayer;
@property(nonatomic, retain) UITableView *videosTableView;
@property(nonatomic, retain) NSMutableArray *videos;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element;

@end