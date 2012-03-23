//
//  ArticleXMLParser.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import "ArticleXMLParser.h"

@implementation ArticleXMLParser

- (NSMutableArray*)getArrayFromRSSFeed:(NSString*)feedURL {
	NSString *xmlData = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:feedURL]];
	
//	DLog(@"xml url => %@",feedURL);
//	DLog(@"xml data => %@",xmlData);
	
	NSMutableArray *latestArticles = [[NSMutableArray alloc] init];
    CXMLDocument *rssParser = [[CXMLDocument alloc] initWithXMLString:xmlData options:0 error:nil];
	[xmlData release];

	NSRange range = [feedURL rangeOfString:@"search.xml"];
	NSString *nodePath = (range.location == NSNotFound) ? @"//article" : @"//searchresult";
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    NSArray *resultNodes = [rssParser nodesForXPath:nodePath error:nil];
	
	if([resultNodes count] == 0) {
		// RFCT CODE | WRITE A REAL ERROR LOGGER
		NSURL *url = [NSURL URLWithString:@"http://serverurl/log.php?error=feederror"];
		NSString *data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
		DLog(@"data => %@", data);
		return nil;
	}
	
	NSString *currentDate = @"";
	NSMutableArray *articlesAry = [[NSMutableArray alloc] init];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		NSString *subheader = [self getValueFromKey:@"subheader" fromElement:resultElement];
		NSString *updated = [self getValueFromKey:@"updated" fromElement:resultElement];
		NSString *byline = [self getValueFromKey:@"byline" fromElement:resultElement];
		NSString *staffline = [self getValueFromKey:@"staffline" fromElement:resultElement];
		NSString *comments = [self getValueFromKey:@"comments" fromElement:resultElement]; // bool
		NSString *browser_link = [self getValueFromKey:@"browser_link" fromElement:resultElement];
		NSString *content = [self getValueFromKey:@"content" fromElement:resultElement];
		NSString *header = [self getValueFromKey:@"header" fromElement:resultElement];
		NSString *teaser = [self getValueFromKey:@"teaser" fromElement:resultElement];
		NSString *published = [self getValueFromKey:@"published" fromElement:resultElement];
		NSString *article_id = [self getValueFromKey:@"id" fromElement:resultElement]; // int
		NSString *thumbnail = [self getValueFromKey:@"thumb" fromElement:resultElement];
		
		// replace default date
		if([currentDate isEqualToString:@""]) currentDate = published;
		
		// dates are not equal means a new section
		if(![[currentDate substringToIndex:10] isEqualToString:[published substringToIndex:10]]) {
			NSArray *keys = [[NSArray alloc] initWithObjects:@"date", @"articles",nil];
			NSArray *values = [[NSArray alloc] initWithObjects:[GlobalMethods convertSQLToLongDate:currentDate],articlesAry,nil];
			NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
			[latestArticles addObject:dictionary];
			
			[articlesAry release];
			
			// set new date
			currentDate = published;
			articlesAry = [[NSMutableArray alloc] init];
			
			// release objects
			[dictionary release];
			[values release];
			[keys release];
		}
		
		// parse article images
		NSMutableArray *images = [[NSMutableArray alloc] init];
		NSArray *imagesXML = [[[resultElement elementsForName:@"images"] objectAtIndex:0] elementsForName:@"item"];

		for(CXMLElement *item in imagesXML) {
			NSString *image_url = [self getValueFromKey:@"t300_url" fromElement:item]; 
	//		NSString *thumbnail = [self getValueFromKey:@"t_url" fromElement:item]; 
			NSString *caption = [self getValueFromKey:@"caption" fromElement:item];
			NSString *content_id = [self getValueFromKey:@"content_id" fromElement:item];
			NSString *credit = [self getValueFromKey:@"credit" fromElement:item];

			NSArray *keys = [[NSArray alloc] initWithObjects:@"url", @"caption", @"content_id", @"credit",nil];
			NSArray *values = [[NSArray alloc] initWithObjects:image_url,caption,content_id,credit,nil];
			NSDictionary *imageDictionary = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
			[images addObject:imageDictionary];
			[imageDictionary release];
			[values release];
			[keys release];
		}

		// DLog(@"images => %@",images);
		// ----
		NSArray *keys = [[NSArray alloc] initWithObjects:@"subheader",@"updated",@"byline",@"staffline",@"comments",@"browser_link",
						 @"header",@"teaser",@"published",@"id",@"thumb",@"images",@"content",nil];
		NSArray *values = [[NSArray alloc] initWithObjects:subheader,updated,byline,staffline,comments,browser_link,header,teaser,published,
						   article_id,thumbnail,images,content,nil];
		
//		DLog(@"keys => %@",keys);
//		DLog(@"values => %@",values);
		
		NSDictionary *dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
		[articlesAry addObject:dict];
		
		[keys release];
		[values release];
		[dict release];
	}	
	
	// final addition
	// -----------
	NSArray *keys = [[NSArray alloc] initWithObjects:@"date", @"articles",nil];
	NSArray *values = [[NSArray alloc] initWithObjects:[GlobalMethods convertSQLToLongDate:currentDate], articlesAry,nil];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
	[latestArticles addObject:dictionary];
	
	[articlesAry release];
	
	// release objects
	[dictionary release];
	[values release];
	[keys release];
	// -------------
		
//	DLog(@"dictionary => %@",latestArticles);
	[rssParser release];
	
	return [latestArticles autorelease];
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element {
	if([[element elementsForName:key] count] == 0) return nil;
	NSString *value = [[[element elementsForName:key] objectAtIndex:0] stringValue];
	return value == nil ? @"" : value;
}

- (void)dealloc {
	[super dealloc];
}

@end
