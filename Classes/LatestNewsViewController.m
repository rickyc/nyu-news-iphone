//
//  LatestNewsViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//
#import "LatestNewsViewController.h"

@implementation LatestNewsViewController

- (void)loadView {
	[super loadView];
	feedURL = @"http://urlforapi/feed.xml";
	uniqueIdentifer = @"latest_news";
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(headerBackground == nil) {
		headerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,44)];
		headerBackground.image = [UIImage imageNamed:@"logo.png"];
		[self.navigationController.navigationBar insertSubview:headerBackground atIndex:0];
	}
	
	self.navigationController.navigationBar.tintColor = [GlobalMethods getColor:@"dark"];
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = @"";
	headerBackground.hidden = NO;
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