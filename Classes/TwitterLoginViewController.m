//
//  TwitterLoginViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/20/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "TwitterLoginViewController.h"
#import "TwitterRequest.h"

@implementation TwitterLoginViewController
@synthesize loginTable, username, password;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	loginTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416) style:UITableViewStyleGrouped];
	loginTable.dataSource = self;
	loginTable.delegate = self;
	loginTable.bounces = NO;
	[self.view addSubview:loginTable];
	
	UITextView *subtitle = [[UITextView alloc] initWithFrame:CGRectMake(5,112,310,120)];
	subtitle.text = @"Enter your twitter username and password to login. If you do not have an account, you may register one for free at twitter.com.";
	subtitle.backgroundColor = [UIColor clearColor];
	subtitle.font = [UIFont systemFontOfSize:13];
	subtitle.textAlignment = UITextAlignmentCenter;
	subtitle.userInteractionEnabled = NO;
	[self.view addSubview:subtitle];
	[subtitle release];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter_bird.png"]];
	imageView.center = CGPointMake(160,280);
	[self.view addSubview:imageView];
	[imageView release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// if username or password is blank
	if(username.text == nil || password.text == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"All fields are required." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else { 
		// hides keyboard
		[textField resignFirstResponder];
		
		// attempts to login
		TwitterRequest *tRequest = [[TwitterRequest alloc] init];
		tRequest.username = [username text];
		tRequest.password = [password text];
		[tRequest login:self requestSelector:@selector(loginCallBack:) andErrorSelector:@selector(errorCallBack:)];
		[tRequest release];
	}
	
	return YES;
}

- (void)loginCallBack:(NSData*)content {
	DLog(@"success? => %@",[[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding]);
	
	// saves the username and password
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:username.text forKey:@"twitter_username"];
	[prefs setObject:password.text forKey:@"twitter_password"];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Login" message:@"You have successfully logged in. To post a message please click on the twitter icon again."
												   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)errorCallBack:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"An error has occurred. Please check your username and password and try again." 
												   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSInteger row = indexPath.row;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22,14,170,20)];
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	titleLabel.textColor = [UIColor darkTextColor];
	
	UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake(120,14,170,20)];
	valueField.returnKeyType = UIReturnKeyDone;
	valueField.delegate = self;
	
	if(row == 0) {
		titleLabel.text = @"Username:";
		username = [valueField retain];
		username.text = [prefs objectForKey:@"twitter_username"] != nil ? [prefs objectForKey:@"twitter_username"] : @"";
	} else {
		titleLabel.text = @"Password:";
		valueField.secureTextEntry = YES;
		password = [valueField retain];
		password.text = [prefs objectForKey:@"twitter_password"] != nil ? [prefs objectForKey:@"twitter_password"] : @"";
	}

	[cell addSubview:titleLabel];
	[cell addSubview:valueField];
	
	[titleLabel release];
	[valueField release];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSInteger row = indexPath.row;
	
	if(row == 0){ 
		[username becomeFirstResponder];
	} else {
		[password becomeFirstResponder];
	}
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
	[password release];
	[username release];
	[loginTable release];	
    [super dealloc];
}


@end
