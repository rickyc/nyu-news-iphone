//
//  NYUWSNAppDelegate.h
//  NYU WSN
//
//  Created by Ricky Cheng on 7/27/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NYUWSNAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	NSMutableData *receivedData;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableData *receivedData;

- (void)savePushDataToServer:(NSString*)deviceToken;

@end