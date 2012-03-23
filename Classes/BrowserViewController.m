//
//  BrowserViewController.m
//  NYU Registrar
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "BrowserViewController.h"

@implementation BrowserViewController
@synthesize browser, url, activityIndicator;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	browser = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,372)];
	browser.multipleTouchEnabled = YES;
	browser.userInteractionEnabled = YES;
	browser.scalesPageToFit = YES;
	browser.delegate = self;
	[self.view addSubview:browser];
}

- (void)viewDidAppear:(BOOL)animated {
	[browser loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView { 
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	// UIActivityIndicator, adds it to right navigation button
	UIBarButtonItem *navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	[navigationRightItem release];
	
	if([GlobalMethods isNetworkAvailable])
		[activityIndicator startAnimating];
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connectivity" message:@"An error has occurred. Please check your network settings and try again." 
													   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicator stopAnimating];
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
	[activityIndicator release];
	[url release];
	[browser release];
    [super dealloc];
}


@end
