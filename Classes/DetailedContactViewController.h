//
//  DetailedContactViewController.h
//  NYUWSN
//
//  Created by Ricky Cheng on 8/13/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DetailedContactViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
	UITableView *contactTableView;
	NSDictionary *contactInformation;
}

@property(nonatomic, retain) UITableView *contactTableView;
@property(nonatomic, retain) NSDictionary *contactInformation;

- (void)displayComposerSheet;

@end
