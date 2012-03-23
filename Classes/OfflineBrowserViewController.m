//
//  OfflineBrowserViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/6/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "OfflineBrowserViewController.h"

@implementation OfflineBrowserViewController
@synthesize browser, filePath;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,372)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	browser = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,372)];
	browser.scalesPageToFit = YES;
	browser.userInteractionEnabled = YES;
	browser.multipleTouchEnabled = YES;
	browser.dataDetectorTypes = UIDataDetectorTypeAll;
	[self.view addSubview:browser];
}

- (void) viewDidLoad {
	NSError *error = nil;
	NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	
	DLog(@"html ? => %@",html);
	[browser loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
