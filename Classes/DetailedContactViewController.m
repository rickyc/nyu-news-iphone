//
//  DetailedContactViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/13/09.
//  Copyright 2009 Washington Square News. All rights reserved.
//

#import "DetailedContactViewController.h"

@implementation DetailedContactViewController
@synthesize contactTableView, contactInformation;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];

	contactTableView = 	[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
	contactTableView.dataSource = self;
	contactTableView.delegate = self;
	[self.view addSubview:contactTableView];
}

- (void)viewWillAppear:(BOOL)animated {
	[contactTableView reloadData];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
	NSInteger row = indexPath.row;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	cell.textLabel.textColor = [UIColor darkTextColor];
	
	cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
	cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
	
	// title, email, name
	if(row == 0) {
		cell.textLabel.text = @"Name:";
		cell.detailTextLabel.text = [contactInformation valueForKey:@"name"];
	} else if(row == 1) {
		cell.textLabel.text = @"Title:";
		NSMutableString *titleString = [[NSMutableString alloc] initWithString:[contactInformation valueForKey:@"title"]];
		
		if([titleString length] > 31) {
			[titleString setString:[NSString stringWithFormat:@"%@...",[titleString substringToIndex:31]]];
		}
		
		cell.detailTextLabel.text = titleString;
	} else if(row == 2) {
		cell.textLabel.text = @"Email:";
		NSString *email = [contactInformation valueForKey:@"email"];
		cell.detailTextLabel.text = [email isEqualToString:@""] ? @"N/A" : email;
	} else if(row == 3) {
		cell.textLabel.text = @"Telephone:";
		cell.detailTextLabel.text = [contactInformation valueForKey:@"telephone"];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSInteger row = indexPath.row;

	if(row == 2) {
		[self displayComposerSheet];
	} else if(row == 3) {
		NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[contactInformation valueForKey:@"telephone"]]];
		
		if([[UIApplication sharedApplication] canOpenURL:telURL])
			[[UIApplication sharedApplication] openURL:telURL];
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, this feature is not supported on this device." delegate:self 
												  cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark -
#pragma mark Compose Mail
// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	NSString *subject = @"Washington Square News";
	[picker setSubject:subject];
	[subject release];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:[contactInformation valueForKey:@"email"]];
	[picker setToRecipients:toRecipients];

	// Fill out the email body text	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {
	[self dismissModalViewControllerAnimated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,60)];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setBackgroundColor:[UIColor clearColor]];
	[button setFrame:CGRectMake(9.0f, 10.0f, 302.0f, 44.0f)];
	[button setTitle:@"Add to Contacts" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(addContactToAddressBook:) forControlEvents:UIControlEventTouchUpInside];
	
	[v addSubview:button];
	
	return [v autorelease];
}

- (void)addContactToAddressBook:(id)sender {
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABPersonCreate();

	NSArray *name = [[contactInformation valueForKey:@"name"] componentsSeparatedByString:@" "];
	
	ABRecordSetValue(person, kABPersonFirstNameProperty, [name objectAtIndex:0], nil);
	
	if([name count] >= 3)
		ABRecordSetValue(person, kABPersonMiddleNameProperty, [name objectAtIndex:1], nil);
	
	ABRecordSetValue(person, kABPersonLastNameProperty, [name objectAtIndex:[name count]-1], nil);
	
	// add email
	ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(email, [contactInformation valueForKey:@"email"], kABWorkLabel, nil);
	ABRecordSetValue(person, kABPersonEmailProperty, email, nil);
	CFRelease(email);
	
	// add company
	ABRecordSetValue(person, kABPersonOrganizationProperty, @"Washington Square News", nil);
	
	// add website	
    ABMutableMultiValueRef url = ABMultiValueCreateMutable(kABStringPropertyType);
    ABMultiValueAddValueAndLabel(url, @"http://nyunews.com", kABPersonHomePageLabel, nil);
    ABRecordSetValue(person, kABPersonURLProperty, url, nil);
    CFRelease(url);

	// add address
	ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	
	NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
	[addressDictionary setObject:@"7 E. 12th St" forKey:(NSString *) kABPersonAddressStreetKey];
	[addressDictionary setObject:@"New York" forKey:(NSString *)kABPersonAddressCityKey];
	[addressDictionary setObject:@"NY" forKey:(NSString *)kABPersonAddressStateKey];
	[addressDictionary setObject:@"10003" forKey:(NSString *)kABPersonAddressZIPKey];

	ABMultiValueAddValueAndLabel(address, addressDictionary, kABWorkLabel, NULL);
	ABRecordSetValue(person, kABPersonAddressProperty, address, nil);
	CFRelease(address);
	[addressDictionary release];
	
	// add telephone
	ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);        
	ABMultiValueAddValueAndLabel(multiPhone, [contactInformation valueForKey:@"telephone"], kABPersonPhoneMainLabel, NULL);        
	ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,nil);        
	CFRelease(multiPhone);
	
	// begins saving the contact into the address book
	ABAddressBookAddRecord(addressBook, person, nil);
	BOOL saved = ABAddressBookSave(addressBook, nil);
	
	// display a confirmation whether or not saving the contact was successful
	if(saved) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"The contact was successfully added to your address book." delegate:self 
											  cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, an error has occurred. The contact could not be added to your address book." 
													   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
		
	CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty); 
	CFStringRef lastName  = ABRecordCopyValue(person, kABPersonLastNameProperty); 
	
	if([name count] >= 3) {
		CFStringRef middleName = ABRecordCopyValue(person, kABPersonMiddleNameProperty); 
		CFRelease(middleName);
	}
		
	CFRelease(firstName);
	CFRelease(lastName);
	CFRelease(person);
	CFRelease(addressBook);
}

#pragma mark  -
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
	[contactInformation release];
	[contactTableView release];
    [super dealloc];
}


@end
