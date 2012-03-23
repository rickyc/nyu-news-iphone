//
//  NYUWSNAppDelegate.m
//  NYU WSN
//
//  Created by Ricky Cheng on 7/27/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import "NYUWSNAppDelegate.h"

@implementation NYUWSNAppDelegate
@synthesize window, tabBarController, receivedData;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// sets the status bar to black
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque]; 
	
	// creates a tint color for the tab bar
	CGRect frame = CGRectMake(0.0, 0.0, 320, 48);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v setBackgroundColor:[GlobalMethods getColor:@"dark"]];
    [v setAlpha:0.5];
    [self.tabBarController.tabBar insertSubview:v atIndex:0];
    [v release];
		
	[window addSubview:[tabBarController view]];

	// support for multitasking
	UIDevice* device = [UIDevice currentDevice];
	BOOL backgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
    
	// activate pinchmedia analytics
	NSString *applicationCode = @"";
	[FlurryAPI startSession:applicationCode];

	// create the temporary folder for caching images	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:TMP])
		[fileManager createDirectoryAtPath:TMP withIntermediateDirectories:YES attributes:nil error:nil];

	// create the plist to save articles in
	NSString *writableDBPath = [GlobalMethods getWritablePath];
	
	// if the file does not exist, then create the file
	if (![fileManager fileExistsAtPath:writableDBPath]) {
		NSMutableDictionary *dictprevious = [NSMutableDictionary new];
		[dictprevious writeToFile:writableDBPath atomically:YES];
		[dictprevious release];
	}
	
	// start push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	
    [window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog(@"worked - deviceToken: %@", deviceToken);
	[self savePushDataToServer:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {     
    DLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	if (userInfo) {
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Message" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert" ] delegate:self cancelButtonTitle:@"Dismiss"otherButtonTitles:nil];
		[av show];
		[av release];
	}
}

// post
- (void)savePushDataToServer:(NSString*)deviceToken {
	NSString *url = @"http://urlforserver/uuid.php";

	NSString *uuid = [[UIDevice currentDevice] uniqueIdentifier];	
	NSString *model = [[UIDevice currentDevice] model];
	NSString *version= [[UIDevice currentDevice] systemVersion];
					  
	NSString *post = [NSString stringWithFormat:@"uuid=%@&token=%@&device=%@&version=%@",uuid,deviceToken,model,version];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy 
															timeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	if(!connection)
		DLog(@"no connection, error");
	receivedData = [[NSMutableData data] retain];
	
	[request release];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DLog(@"error msg => %@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {  
    [receivedData setLength:0];
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {  
    [receivedData appendData:data];  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
  	NSMutableString *dataString = [[[NSMutableString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] autorelease];
	DLog(@"data - %@",dataString);
}

// Add this method if it doesn't exist:
- (void)applicationWillTerminate:(UIApplication *)application {
	// remove the temporary folder
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	[fileManager removeItemAtPath:tempPath error:nil];
}

- (void)dealloc {
	[tabBarController release];
    [window release];
    [super dealloc];
}

@end