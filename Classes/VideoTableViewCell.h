//
//  VideoTableViewCell.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface VideoTableViewCell : ABTableViewCell {
	NSString *header;
	NSString *subtitle;
	NSString *imageURL;
	
	NSMutableData *receivedData;
	NSURLConnection *imageConnection;
}

@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSURLConnection *imageConnection;
@property(nonatomic, copy) NSString *header;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, copy) NSString *imageURL;


- (void)setData:(NSDictionary *)data;

@end