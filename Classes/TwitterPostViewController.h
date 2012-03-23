//
//  TwitterPostViewController.h
//  NYU_WSN
//
//  Created by Ricky Cheng on 8/30/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TwitterPostViewController : UIViewController <UITextViewDelegate> {
	UITextView *message;
	UIBarButtonItem *characterCounter;
}

@property(nonatomic, retain) UITextView *message;
@property(nonatomic, retain) UIBarButtonItem *characterCounter;

@end