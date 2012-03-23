//
//  Utilities.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/17/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import "Utilities.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"
#import "Three20/Three20.h"
#import <QuartzCore/QuartzCore.h>

@implementation Utilities
+ (void)downloadAndCacheFileFromURL:(NSString*)url withTTPath:(NSString*)ttpath {
	NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	[[TTURLCache sharedCache] storeData:data forURL:ttpath];
}

+ (NSData*)retrieveCachedFileFromTTPath:(NSString*)ttpath {
	return [[TTURLCache sharedCache] dataForURL:ttpath];
}

+ (NSDictionary*)retrieveCachedPlistFromTTPath:(NSString*)ttpath {
	NSData* data = [self retrieveCachedFileFromTTPath:ttpath];
	
	NSString *errorDescription = nil;
	NSPropertyListFormat format;
	NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable 
																	 format:&format errorDescription:&errorDescription];
	return plist;
}

//////////////////////////////////////////////////////////////////
// md5 hash
+ (NSString *)md5Hash:(NSString *)clearText {
	const char *cStr = [clearText UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

// DEPRECATED
+ (void)cacheImage:(NSString*)imageURLString {
    NSURL *imageURL = [NSURL URLWithString: imageURLString];

    // Generate a unique path to a resource representing the image you want
    NSString *filename = [self md5Hash:imageURLString];
    NSString *uniquePath = [TMP stringByAppendingPathComponent:filename];
	
	// PATH => /var/folders/KT/ etc.
	DLog(@"unique path => %@",uniquePath);
	
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath]) {
        // The file doesn't exist, we should get a copy of it

        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
        UIImage *image = [[UIImage alloc] initWithData:data];
		image = [image imageWithAlpha];
        image = [[image roundedCornerImage:12 borderSize:0] retain];
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([imageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound) {
			DLog(@"writing image");
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if([imageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
			[imageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound) {
            [UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath atomically: YES];
        }
		
		[image release];
		[data release];
	}
}

// new
+ (void)cacheImageWithData:(NSData*)imageData andURL:(NSString*)imageURL {
    NSString *uniquePath = [self getCachedImagePath:imageURL];
	UIImage *image = [[UIImage alloc] initWithData:imageData];
	image = [image imageWithAlpha];
	image = [[image roundedCornerImage:12 borderSize:0] retain];
	
	if([imageURL rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound) {
		[UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
	}
	else if([imageURL rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
			[imageURL rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound) {
		[UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath atomically: YES];
	}
}

+ (NSString*)getCachedImagePath:(NSString *)imageURLString {
	NSString *filename = [self md5Hash:imageURLString];
    return [TMP stringByAppendingPathComponent:filename];
}

+ (BOOL)isImageCached:(NSString*)imageURL {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self getCachedImagePath:imageURL]];
}

+ (UIImage *)getCachedImage:(NSString *)imageURLString {
	// Generate a unique path to a resource representing the image you want
	NSString *filename = [self md5Hash:imageURLString];
    NSString *uniquePath = [TMP stringByAppendingPathComponent:filename];
	
    UIImage *image;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath:uniquePath]) {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    } else {
        // get a new one
        [self cacheImage:imageURLString];
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
	
    return image;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


@end
