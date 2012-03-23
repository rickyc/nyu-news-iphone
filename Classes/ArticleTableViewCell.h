//
//  ArticleTableViewCell.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface ArticleTableViewCell : ABTableViewCell {
	NSString *header;
	NSString *teaser;
	NSString *imageURL;
	
	NSMutableData *receivedData;
	NSURLConnection *imageConnection;
}

@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSURLConnection *imageConnection;
@property(nonatomic, copy) NSString *header;
@property(nonatomic, copy) NSString *teaser;
@property(nonatomic, copy) NSString *imageURL;


- (void)setData:(NSDictionary *)data;

@end