//
//  BitlyRequest.m
//  NYUWSN
//
//  Created by Ricky Cheng on 8/6/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "BitlyRequest.h"

@implementation BitlyRequest
@synthesize username, apiKey;

- (id)init {
	[super init];
	self.username = @"USERNAME";
	self.apiKey = @"API_KEY";
	
	return self;
}

- (NSString *)stringWithUrl:(NSURL *)url {
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
	
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (id)objectWithUrl:(NSURL *)url {
	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [self stringWithUrl:url];
	
	// Parse the JSON into an Object
	return [jsonParser objectWithString:jsonString error:NULL];
}

- (NSString*)shortenURL:(NSString*)url {
	NSString *apiURL = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=%@&apiKey=%@",url,username,apiKey];
	NSDictionary *feed = (NSDictionary*)[self objectWithUrl:[NSURL URLWithString:apiURL]];
	
	return [[[feed valueForKey:@"results"] valueForKey:url] valueForKey:@"shortUrl"];
}

@end
