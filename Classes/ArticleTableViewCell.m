//
//  ArticleTableViewCell.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import "Utilities.h"

@implementation ArticleTableViewCell
@synthesize header, teaser, imageURL, receivedData, imageConnection;

- (void)setHeader:(NSString *)s {
	[header release];
	header = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setTeaser:(NSString *)s {
	[teaser release];
	teaser = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setImageURL:(NSString *)s {
	[imageURL release];
	imageURL = [s copy];
	[self setNeedsDisplay];
}

- (void)setData:(NSDictionary *)data {
	[self setHeader:[data objectForKey:@"header"]];
	[self setTeaser:[data objectForKey:@"teaser"]];
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

	UIColor *headerColor = [GlobalMethods getColor:@"header"];
	UIColor *textColor = [UIColor blackColor];
	UIColor *backgroundColor = [UIColor clearColor];
	
	[backgroundColor set];
	
	if(self.highlighted) {
		textColor = [UIColor whiteColor];
		headerColor = [UIColor whiteColor];
	} else {
		UIImage *background = [UIImage imageNamed:@"article_cell_background.png"];
		[background drawInRect:CGRectMake(0,0,320,r.size.height)];
	}
	
	CGContextFillRect(context, r);
	[headerColor set];

	// default values assumes there is an image
	CGFloat boundingBoxWidth = 230;
	CGFloat leftMargin = 80;
	
	// 65x65px image
	if([imageURL isEqualToString:@"None"]) {
		boundingBoxWidth = 310;
		leftMargin = 6;
	} else {
		UIImage *image;

		if([Utilities isImageCached:imageURL]) {
			image = [Utilities getCachedImage:imageURL];
		} else {
			image = [UIImage imageNamed:@"Placeholder.png"];
			
			receivedData = [[NSMutableData alloc] init];
			imageConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]] delegate:self];
		}
		
		[image drawAtPoint:CGPointMake(6,6)];
	}
	
	UIFont *font = [UIFont boldSystemFontOfSize:14];
	CGFloat height = [self getHeightOfText:header withFont:font andBoundingWidth:boundingBoxWidth];
	[header drawInRect:CGRectMake(leftMargin,6,boundingBoxWidth,height) withFont:font lineBreakMode:UILineBreakModeWordWrap];

	CGFloat remainingHeight = 78 - height - 5;
	[textColor set];
	font = [UIFont systemFontOfSize:12];

	[teaser drawInRect:CGRectMake(leftMargin,height+6,boundingBoxWidth,remainingHeight) withFont:font lineBreakMode:UILineBreakModeWordWrap];
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DLog(@"Error => %@",error);
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
	[teaser release];
	[header release];
    [super dealloc];
}


@end
