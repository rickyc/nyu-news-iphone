//
//  MoreSectionsViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "MoreSectionsViewController.h"
#import "BrowserViewController.h"
#import "MapViewController.h"
#import "ContactsViewController.h"
#import "TwitterRequest.h"
#import "OfflineBrowserViewController.h"
#import "CampusMapViewController.h"
#import "SavedArticlesViewController.h"
#import "SearchViewController.h"
#import "CampusCashLocatorViewController.h"

@implementation MoreSectionsViewController
@synthesize sectionsTable, sectionsArray, headerBackground;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	sectionsTable.dataSource = self;
	sectionsTable.delegate = self;
	[self.view addSubview:sectionsTable];
}

- (void)viewDidLoad {
	if(headerBackground == nil) {
		headerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,44)];
		headerBackground.image = [UIImage imageNamed:@"logo.png"];
		[self.navigationController.navigationBar insertSubview:headerBackground atIndex:0];
	}
	
	self.navigationController.navigationBar.tintColor = [GlobalMethods getColor:@"dark"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"sections" ofType:@"plist"];
	sectionsArray = [[NSArray alloc] initWithContentsOfFile:path];
	[sectionsTable reloadData];	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = @"";
	headerBackground.hidden = NO;	
}

- (void)viewWillDisappear:(BOOL)animated {
	headerBackground.hidden = YES;
	self.navigationItem.title = @"NYU WSN";
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sectionsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"section_silver.png"]];

	NSDictionary *dict = [sectionsArray objectAtIndex:indexPath.row];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60,0,240,44)];
	label.text = [dict valueForKey:@"header"];
	label.font = [UIFont boldSystemFontOfSize:20];
	label.backgroundColor = [UIColor clearColor];
	[cell addSubview:label];
	[label release];
	
	cell.imageView.image = [UIImage imageNamed:[dict valueForKey:@"image"]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *dict = [sectionsArray objectAtIndex:indexPath.row];
	NSString *label = [dict valueForKey:@"header"];
	
	[FlurryAPI logEvent:label];
	
	if([label isEqualToString:@"Location"]) {
		CLLocationCoordinate2D courseCoord;
		courseCoord.latitude = 40.733795;
		courseCoord.longitude = -73.990958;
		
		NSString *address = [[NSString alloc] initWithString:@"838 Broadway\n5th Floor\nNew York, NY 10003 "];
		
		// load map view
		MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:[NSBundle mainBundle]];
		mapViewController.hidesBottomBarWhenPushed = YES;
		mapViewController.navigationItem.title = @"Location";
		[mapViewController addAnnotation:courseCoord andTitle:@"Washington Square News" andSubtitle:address];
		[self.navigationController pushViewController:mapViewController animated:YES];
		
		// release objects
		[mapViewController release];
		[address release];
	} else if([label isEqualToString:@"WSN Mobile"]) {
		BrowserViewController *browserViewController = [[BrowserViewController alloc] init];
		browserViewController.url = @"http://www.nyunews.com";
		browserViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:browserViewController animated:YES];
		browserViewController.browser.frame = CGRectMake(0,0,320,416);
		[browserViewController release];
	} else if([label isEqualToString:@"WSN Blog"]) {
		BrowserViewController *browserViewController = [[BrowserViewController alloc] init];
		browserViewController.url = @"http://blogs.nyunews.com";
		browserViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:browserViewController animated:YES];
		browserViewController.browser.frame = CGRectMake(0,0,320,416);
		[browserViewController release];
	} else if([label isEqualToString:@"Contact Information"]) {
		ContactsViewController *contactsViewController = [[ContactsViewController alloc] init];
		contactsViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:contactsViewController animated:YES];
		[contactsViewController release];
	} else if([label isEqualToString:@"WSN Twitter"]) {
		BrowserViewController *browserViewController = [[BrowserViewController alloc] init];
		browserViewController.url = @"http://www.twitter.com/nyunews";
		browserViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:browserViewController animated:YES];
		browserViewController.browser.frame = CGRectMake(0,0,320,416);
		[browserViewController release];
	} else if([label isEqualToString:@"About WSN"]) {
		OfflineBrowserViewController *obvc = [[OfflineBrowserViewController alloc] init];
		obvc.filePath = [[NSBundle mainBundle] pathForResource:@"about_us" ofType:@"html"];
		[self.navigationController pushViewController:obvc animated:YES];
		[obvc release];
	} else if([label isEqualToString:@"Work for WSN"]) {
		OfflineBrowserViewController *obvc = [[OfflineBrowserViewController alloc] init];
		obvc.filePath = [[NSBundle mainBundle] pathForResource:@"work_for_us" ofType:@"html"];
		[self.navigationController pushViewController:obvc animated:YES];
		[obvc release];
	} else if([label isEqualToString:@"Advertising"]) {
		OfflineBrowserViewController *obvc = [[OfflineBrowserViewController alloc] init];
		obvc.filePath = [[NSBundle mainBundle] pathForResource:@"advertise" ofType:@"html"];
		[self.navigationController pushViewController:obvc animated:YES];
		[obvc release];
	} else if([label isEqualToString:@"Campus Map"]) {
		CampusMapViewController *campusMapViewController = [[CampusMapViewController alloc] init];
		campusMapViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:campusMapViewController animated:YES];
		[campusMapViewController release];
	} else if([label isEqualToString:@"Campus Cash Locator"]) {
		CampusCashLocatorViewController* _campusCashLocatorViewController = [[CampusCashLocatorViewController alloc] init];
		_campusCashLocatorViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:_campusCashLocatorViewController animated:YES];
		[_campusCashLocatorViewController release];		
	} else if([label isEqualToString:@"Saved Articles"]) {
		SavedArticlesViewController *savedArticlesViewController = [[SavedArticlesViewController alloc] init];
		savedArticlesViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:savedArticlesViewController animated:YES];
		[savedArticlesViewController release];
	} else if([label isEqualToString:@"Bugs & Comments"]) {
		[self displayComposerSheet];
	} else if([label isEqualToString:@"Search"]) {
		SearchViewController *svc = [[SearchViewController alloc] init];
		[self.navigationController pushViewController:svc animated:YES];
		[svc release];
	}
}

#pragma mark -
- (void) status_updateCallback:(NSData *) content {
	DLog(@"%@",[[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding]);
}

#pragma mark -
#pragma mark Compose Mail
// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	NSString *subject = @"WSN Bug Report";
	[picker setSubject:subject];
	[subject release];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"webteam@nyunews.com"];
	[picker setToRecipients:toRecipients];
	
    NSString *model = [[UIDevice currentDevice] model];
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];

	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"For bugs, please state the issue and list the steps in order to reproduce the problem.\n\n\nDevice: %@ (%@)",
						   model, systemVersion];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[headerBackground release];
	[sectionsArray release];
	[sectionsTable release];
    [super dealloc];
}

@end

