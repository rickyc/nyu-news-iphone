//
//  GlobalMethods.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRootURL @"http://someserverurl"
#define TMP [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.ricky.nyuwsn/"]

@interface GlobalMethods : NSObject 

+ (NSString*)convertSQLToLongDate:(NSString*)sqlDate;
+ (UIColor*)getColor:(NSString*)string;
+ (NSString*)getWritablePath;
+ (NSString*)getPathByUniqueIdentifier:(NSString*)filename;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
+ (NSString *)flattenHTML:(NSString *)html;
+ (BOOL)isNetworkAvailable;
+ (BOOL)fileExistsAtPath:(NSString*)path;
+ (BOOL)adsEnabled;
+ (void)writeData:(NSArray*)data toPath:(NSString*)path;

@end
