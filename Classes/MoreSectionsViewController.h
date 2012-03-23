//
//  MoreSectionsViewController.h
//  NYUWSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MoreSectionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
	UITableView *sectionsTable;
	NSArray *sectionsArray;
	UIImageView *headerBackground;
}

@property(nonatomic, retain) UITableView *sectionsTable;
@property(nonatomic, retain) NSArray *sectionsArray;
@property(nonatomic, retain) UIImageView *headerBackground;

- (void)displayComposerSheet;

@end