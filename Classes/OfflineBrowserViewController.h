//
//  OfflineBrowserViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/6/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OfflineBrowserViewController : UIViewController {
	UIWebView *browser;
	NSString *filePath;
}

@property(nonatomic, retain) UIWebView *browser;
@property(nonatomic, retain) NSString *filePath;

@end