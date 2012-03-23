//
//  ArticleTableViewCell.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "Utilities.h"

@implementation VideoTableViewCell
@synthesize header, subtitle, imageURL, receivedData, imageConnection;

- (void)setHeader:(NSString *)s {
	[header release];
	header = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setSubtitle:(NSString *)s {
	[subtitle release];
	subtitle = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setImageURL:(NSString *)s {
	[imageURL release];
	imageURL = [s copy];
	[self setNeedsDisplay];
}

- (void)setData:(NSDictionary *)data {
	[self setHeader:[data objectForKey:@"header"]];
	[self setSubtitle:[data objectForKey:@"byline"]];
	[self setImageURL:[data objectForKey:@"thumb"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    CGRect b = [self bounds];
    b.size.height -= 1; // leave room for the separator line
    b.origin.x = 0;
    [contentView setFrame:b];
    [super layoutSubviews];
}

// DOCUMENT METHOD
- (CGFloat)getHeightOfText:(NSString*)text withFont:(UIFont*)font andBoundingWidth:(CGFloat)width {
	CGSize boundingSize = CGSizeMake(width, CGFLOAT_MAX);
	CGSize requiredSize = [text sizeWithFont:font constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat requiredHeight = requiredSize.height;
	
	return requiredHeight;
}

- (void)drawContentView:(CGRect)r {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *textColor = [UIColor blackColor];
	UIColor *backgroundColor = [UIColor whiteColor];
	
	[backgroundColor set];
	
	if(self.highlighted) {
		backgroundColor = [UIColor clearColor];
		textColor = [UIColor whiteColor];
	} 
	
	CGContextFillRect(context, r);
	
	[textColor set];
	
	// default values assumes there is an image
	UIImage *image;
	
	if([Utilities isImageCached:imageURL]) {
		image = [Utilities getCachedImage:imageURL];
	} else {
		image = [UIImage imageNamed:@"Placeholder.png"];
		
		receivedData = [[NSMutableData alloc] init];
		imageConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]] delegate:self];
	}
	[image drawAtPoint:CGPointMake(6,6)];
	
	UIFont *font = [UIFont boldSystemFontOfSize:14];
	[header drawInRect:CGRectMake(115,5,180,40) withFont:font lineBreakMode:UILineBreakModeWordWrap];
	
	font = [UIFont systemFontOfSize:12];
	[subtitle drawInRect:CGRectMake(115,42,180,40) withFont:font lineBreakMode:UILineBreakModeWordWrap];

}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DLog(@"error => %@",error);
	receivedData = nil;
	imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	UIImage *image = [[UIImage alloc] initWithData:receivedData];
	[Utilities cacheImageWithData:receivedData andURL:imageURL];	
	receivedData = nil;
	[image release];
	
	// Release the connection now that it's finished
	imageConnection = nil;
	
	[self setNeedsDisplay];
}

- (void)dealloc {
	[imageURL release];
	[subtitle release];
	[header release];
    [super dealloc];
}


@end
