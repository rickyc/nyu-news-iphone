//
//  FacebookLoginViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/7/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "FacebookSession.h"

static NSString* kFacebookApiKey = @"";
static NSString* kFacebookApiSecret = @"";
static NSString* kGetSessionProxy = nil; // @"<YOUR SESSION CALLBACK)>";

@implementation FacebookSession
@synthesize article;

- (id)init {
	if (self = [super init]) { 
		if (kGetSessionProxy) {
			_session = [[FBSession sessionForApplication:kFacebookApiKey getSessionProxy:kGetSessionProxy delegate:self] retain];
		} else {
			_session = [[FBSession sessionForApplication:kFacebookApiKey secret:kFacebookApiSecret delegate:self] retain];
		}
		
		FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:_session] autorelease];
		[dialog show];
	}
	
	return self;
}

- (void)viewDidLoad {
	[_session resume];
}

#pragma mark other facebook methods
- (void)askPermission:(id)target {
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.permission = @"status_update";
	[dialog show];
}

#pragma mark FBDialogDelegate
- (void)dialogDidSucceed:(FBDialog *)dialog {
	if([dialog isMemberOfClass:[FBPermissionDialog class]]) {
		[self publishFeed];
	}
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	DLog(@"Error(%d) %@", error.code, error.localizedDescription);
}

- (void)publishFeed {
	DLog(@"data =>  %@",article);
	NSString *teaser = [[article valueForKey:@"teaser"] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
	NSString *data = [[NSString alloc] initWithFormat:@"{\"header\" : \"%@\", \"url\" : \"%@\", \"teaser\" : \"%@\"}",
					  [article valueForKey:@"header"],[article valueForKey:@"browser_link"], teaser];
	
	FBStreamDialog* dialog = [[[FBStreamDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.userMessagePrompt = @"NYU WSN";
	dialog.attachment = data;
	[dialog show];
	
	[data release];
}

- (void)setStatus:(id)target {
	NSString *statusString = @"NYU WSN - iPhone";
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							statusString, @"status",
							@"true", @"status_includes_verb",
							nil];
	[[FBRequest requestWithDelegate:self] call:@"facebook.users.setStatus" params:params];
}

#pragma mark FBSessionDelegate
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	DLog(@"User with id %lld logged in.", uid);
	
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name from user where uid == %lld", session.uid];
	
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void)sessionDidNotLogin:(FBSession*)session {
	DLog(@"did not log in");
}

- (void)sessionDidLogout:(FBSession*)session {
	DLog(@"logged out");
}

#pragma mark FBRequestDelegate
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([request.method isEqualToString:@"facebook.fql.query"]) {
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSString* name = [user objectForKey:@"name"];
		DLog(@"%@", [NSString stringWithFormat:@"Logged in as %@", name]);
		[self publishFeed];
	} else if ([request.method isEqualToString:@"facebook.users.setStatus"]) {
		NSString* success = result;
		if ([success isEqualToString:@"1"]) {
			DLog(@"%@", [NSString stringWithFormat:@"Status successfully set"]); 
		} else {
			DLog(@"%@", [NSString stringWithFormat:@"Problem setting status"]); 
		}
	} 
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	DLog(@"Error(%d) %@", error.code, error.localizedDescription);
}

- (void)dealloc {
	[_session release];
    [super dealloc];
}

@end
