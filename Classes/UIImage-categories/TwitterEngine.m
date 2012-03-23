//
//  TwitterAPI.m
//  Starling
//
//  Created by Ricky Cheng on 8/6/10.
//  Copyright 2010 Family. All rights reserved.
//

#import "TwitterEngine.h"
#import "SA_OAuthTwitterEngine.h"

@implementation TwitterEngine
@synthesize delegate, callback;

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:@"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username {
//	TTDPRINT(@"Authenicated for %@", username);
	[delegate performSelector:callback withObject:@"YES"];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
//	TTDPRINT(@"Authentication Failed!");
	[delegate performSelector:callback withObject:@"NO"];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
//	TTDPRINT(@"Authentication Canceled.");
	[delegate performSelector:callback withObject:@"NO"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
//	TTDPRINT(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
//	TTDPRINT(@"Request %@ failed with error: %@", requestIdentifier, error);
}

//=============================================================================================================================
#pragma mark ViewController Stuff
- (void)dealloc {
	[_engine release];
//	TT_RELEASE_SAFELY(_engine);
    [super dealloc];
}

- (BOOL)authenticate:(UIViewController*)viewController withDelegate:(id)_delegate andCallback:(SEL)_callback {
	if (!_engine) {
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	//	[_engine clearAccessToken];

		_engine.consumerKey = @"";
		_engine.consumerSecret = @"";
	}
	
	delegate = _delegate;
	callback = _callback;
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine 
										delegate:self forOrientation:viewController.interfaceOrientation];
	
	if (!_engine.isAuthorized) {
		[viewController presentModalViewController: controller animated:YES];
	}

	return _engine.isAuthorized;
}

- (void)postMessage:(NSString*)message {
	[_engine sendUpdate:message];
}


- (void)getUserInformationForSelf {
	[self getUserInformationForUser:[_engine username]];
}

- (void)getUserInformationForUser:(NSString*)username {
	[_engine getUserInformationFor:username];
}

@end
