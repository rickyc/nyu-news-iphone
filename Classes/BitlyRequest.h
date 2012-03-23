//
//  BitlyRequest.h
//  NYUWSN
//
//  Created by Ricky Cheng on 8/6/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

@interface BitlyRequest : NSObject {
	NSString *username;
	NSString *apiKey;
}

@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *apiKey;

- (NSString *)stringWithUrl:(NSURL *)url;
- (id) objectWithUrl:(NSURL *)url;
- (NSString*)shortenURL:(NSString*)url;

@end