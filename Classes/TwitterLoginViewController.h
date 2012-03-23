//
//  TwitterLoginViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/20/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterLoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITableView *loginTable;
	UITextField *username;
	UITextField *password;
}

@property(nonatomic, retain) UITableView *loginTable;
@property(nonatomic, retain) UITextField *username;
@property(nonatomic, retain) UITextField *password;

@end
