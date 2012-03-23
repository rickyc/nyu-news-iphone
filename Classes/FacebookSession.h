//  FacebookLoginViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/7/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBConnect.h"

@interface FacebookSession : UIViewController <FBDialogDelegate, FBSessionDelegate, FBRequestDelegate> {
	FBSession *_session;
	NSDictionary *article;
}

@property(nonatomic, retain) NSDictionary *article;

- (void)login;
- (void)publishFeed;

@end