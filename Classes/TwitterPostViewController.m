//
//  TwitterPostViewController.m
//  NYU_WSN
//
//  Created by Ricky Cheng on 8/30/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "TwitterPostViewController.h"
#import "TwitterRequest.h"

@implementation TwitterPostViewController
@synthesize message, characterCounter;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];

	// keyboard 216px
	message = [[UITextView alloc] initWithFrame:CGRectMake(0,44,320,156)];
	message.font = [UIFont systemFontOfSize:16];
	message.delegate = self;
	message.keyboardAppearance = UIKeyboardAppearanceAlert;
	message.keyboardType = UIKeyboardTypeDefault;
	[self.view addSubview:message];
	[message becomeFirstResponder];
	
	// toolbar
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,200,320,44)];
	toolbar.tintColor = [GlobalMethods getColor:@"dark"];
	[self.view addSubview:toolbar];

	UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearTweet:)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	characterCounter = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:self action:nil];
	
	[toolbar setItems:[NSArray arrayWithObjects:trash, flexibleSpace, characterCounter, nil]];
	[trash release];
	[flexibleSpace release];
	[toolbar release];
	
	// navigation bar
	UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
	navigationBar.tintColor = [GlobalMethods getColor:@"dark"];
	[self.view addSubview:navigationBar];

	UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Tweet"];
	[navigationBar pushNavigationItem:navigationItem animated:NO];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeTweet:)];
	navigationItem.leftBarButtonItem = closeButton;
	[closeButton release];
	
	UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postTweet:)];
	navigationItem.rightBarButtonItem = postButton;
	[postButton release];
	
	[navigationItem release];
	[navigationBar release];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	return range.length == 1 || textView.text.length < 140;
}

- (void)clearTweet:(id)sender {
	message.text = @"";
}

- (void)closeTweet:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)postTweet:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *username = [prefs objectForKey:@"twitter_username"];
	NSString *password = [prefs objectForKey:@"twitter_password"];
	
	TwitterRequest *tRequest = [[TwitterRequest alloc] init];
	tRequest.username = username;
	tRequest.password = password;
	[tRequest statuses_update:message.text delegate:self requestSelector:@selector(postCallBack:) andErrorSelector:@selector(errorCallBack:)];
	[tRequest release];
	
	[self closeTweet:nil];
}

- (void)postCallBack:(NSData*)content {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Post" message:@"Your message has successfully been posted."
												   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)textViewDidChange:(UITextView *)textView {
	characterCounter.title = [NSString stringWithFormat:@"%i", 140 - [[message text] length]];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return YES;
}

- (void)errorCallBack:(NSError*)error {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:nil forKey:@"twitter_username"];
	[prefs setObject:nil forKey:@"twitter_password"];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"An error has occurred. Please check your username and password and try again." 
												   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
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
	[characterCounter release];
	[message release];
    [super dealloc];
}

@end
