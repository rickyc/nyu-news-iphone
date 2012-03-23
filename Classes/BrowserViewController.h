//
//  BrowserViewController.h
//  NYU Registrar
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *browser;
	NSString *url;
	UIActivityIndicatorView *activityIndicator;
}

@property(nonatomic, retain) UIWebView *browser;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end
