//
//  DetailedCampusCashViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/26/10.
//  Copyright 2010 Washington Square News. All rights reserved.
//

#import "DetailedCampusCashViewController.h"
#import "BrowserViewController.h"
#import <AddressBook/AddressBook.h>

@implementation DetailedCampusCashViewController
@synthesize data = _data;

#pragma mark -
#pragma mark View lifecycle
- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor clearColor];
	self.view = contentView;
	[contentView release];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416) style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (section == 0 || section == 2) ? 1 : 4;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CampusCashCell";
    
	NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// image
	if (row == 0 && section == 0) {
		TTImageView* _iv = [[TTImageView alloc] initWithFrame:CGRectMake(40, 15, 220, 100)];
		_iv.defaultImage = TTIMAGE(@"bundle://campuscash.png");
		_iv.URL = [_data objectForKey:@"image_url"];
		[cell addSubview:_iv];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	if (section == 1) {
		if (row == 0) {
			cell.textLabel.text = @"Merchant:";
			cell.detailTextLabel.text = [_data objectForKey:@"merchant_name"];
		} else if (row == 1) {
			cell.textLabel.text = @"Address:";
			cell.detailTextLabel.text = [_data objectForKey:@"address"];
		} else if (row == 2) {
			cell.textLabel.text = @"Website:";
			cell.detailTextLabel.text = [[_data objectForKey:@"website"] isEqualToString:@""] ? @"N/A" : [_data objectForKey:@"website"];
		} else if (row == 3) {
			cell.textLabel.text = @"Phone:";
			cell.detailTextLabel.text = [[_data objectForKey:@"phone"] isEqualToString:@""] ? @"N/A" : [_data objectForKey:@"phone"];
		}
	}
	
	
	if (section == 2) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"] autorelease];
		cell.textLabel.text = @"Add to Contacts";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;
	
	if (row == 0 && section == 0) return 120;
	
	return 44;
}

- (void)addContactToAddressBook {
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABPersonCreate();
	
	ABRecordSetValue(person, kABPersonOrganizationProperty, [_data objectForKey:@"merchant_name"], nil);

	// add website	
    ABMutableMultiValueRef url = ABMultiValueCreateMutable(kABStringPropertyType);
    ABMultiValueAddValueAndLabel(url, [_data objectForKey:@"website"], kABPersonHomePageLabel, nil);
    ABRecordSetValue(person, kABPersonURLProperty, url, nil);
    CFRelease(url);
	
	// add address
	ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	
	NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
	[addressDictionary setObject:[_data objectForKey:@"address"] forKey:(NSString *) kABPersonAddressStreetKey];
	[addressDictionary setObject:@"New York" forKey:(NSString *)kABPersonAddressCityKey];
	[addressDictionary setObject:@"NY" forKey:(NSString *)kABPersonAddressStateKey];
	
	ABMultiValueAddValueAndLabel(address, addressDictionary, kABWorkLabel, NULL);
	ABRecordSetValue(person, kABPersonAddressProperty, address, nil);
	CFRelease(address);
	[addressDictionary release];
	
	// add telephone
	ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);        
	ABMultiValueAddValueAndLabel(multiPhone, [_data objectForKey:@"phone"], kABPersonPhoneMainLabel, NULL);        
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
		
	CFRelease(person);
	CFRelease(addressBook);
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1) {
		if (indexPath.row == 2) {
			NSString* _url = [_data objectForKey:@"website"];
			if (![_url isEqualToString:@""]) {
				BrowserViewController* _bvc = [[BrowserViewController alloc] init];
				_bvc.url = _url;
				[self.navigationController pushViewController:_bvc animated:YES];
				[_bvc release];
			}
		} else if (indexPath.row == 3) {
			NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[_data objectForKey:@"phone"]]];
		
			if([[UIApplication sharedApplication] canOpenURL:telURL])
				[[UIApplication sharedApplication] openURL:telURL];
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, this feature is not supported on this device." delegate:self 
													  cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
	} else if (indexPath.section == 2) {
		[self addContactToAddressBook];
	}
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end

