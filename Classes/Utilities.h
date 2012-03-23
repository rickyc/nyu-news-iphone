//
//  Utilities.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/17/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>  

@interface Utilities : NSObject 

// Methods
+ (void)downloadAndCacheFileFromURL:(NSString*)url withTTPath:(NSString*)ttpath;
+ (NSData*)retrieveCachedFileFromTTPath:(NSString*)ttpath;
+ (NSDictionary*)retrieveCachedPlistFromTTPath:(NSString*)ttpath;
+ (void)cacheImage:(NSString *)imageURLString;
+ (void)cacheImageWithData:(NSData*)imageData andURL:(NSString*)imageURL;
+ (UIImage *)getCachedImage:(NSString *)imageURLString;
+ (NSString*)getCachedImagePath:(NSString *)imageURLString;
+ (BOOL)isImageCached:(NSString*)imageURL;

@end