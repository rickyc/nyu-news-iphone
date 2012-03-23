//
//  GlobalMethods.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import "GlobalMethods.h"

@implementation GlobalMethods

+ (NSString*)convertSQLToLongDate:(NSString*)sqlDate {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *cDate = [dateFormatter dateFromString:sqlDate];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	NSString *nDate = [dateFormatter stringFromDate:cDate];
	[dateFormatter release];
	
	return nDate;	
}

+ (UIColor*)getColor:(NSString*)string {
	UIColor *color = [UIColor blackColor];
	
	if([string isEqualToString:@"dark"])		color = [UIColor blackColor]; //[UIColor colorWithRed:.184 green:.216 blue:.224 alpha:1.0];
	else if([string isEqualToString:@"medium"]) color = [UIColor colorWithRed:.459 green:.612 blue:.663 alpha:1.0];
	else if([string isEqualToString:@"light"])	color = [UIColor colorWithRed:.796 green:.933 blue:.949 alpha:1.0];
	else if([string isEqualToString:@"header"]) color = [UIColor colorWithRed:.086 green:.243 blue:.459 alpha:1.0];

	return color;
}

+ (BOOL)fileExistsAtPath:(NSString*)path {
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString*)getWritablePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"saved_articles.plist"];
}

+ (NSString*)getPathByUniqueIdentifier:(NSString*)uniqueID {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",uniqueID,nil]];
}

+ (void)writeData:(NSArray*)data toPath:(NSString*)path {
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
	[tempArray writeToFile:path atomically:YES];
	[tempArray release];
}

// DEPRECATED
+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 65; // change value
	
    CGImageRef imgRef = image.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
			
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return imageCopy;
}

+ (BOOL)isNetworkAvailable {
	NSString *theURL = [NSString stringWithFormat:@"http://www.nyunews.com/"];
	theURL = [theURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:theURL]];
	NSURLResponse *resp = nil;
	NSError *err = nil;
	
	[NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
	
	// no errors means network available
	return (err == nil);
}

#warning (TODO) RFCT
+ (BOOL)adsEnabled {
	return YES;
}

+ (NSString *)flattenHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
	}
    
    return html;
}

@end

