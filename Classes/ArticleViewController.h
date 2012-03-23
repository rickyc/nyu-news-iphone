//
//  ArticleViewController.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BitlyRequest.h"
#import "FacebookSession.h"
#import "MBProgressHUD.h"

@interface ArticleViewController : UIViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate, MBProgressHUDDelegate> {
	FacebookSession *facebookRequest;
	BitlyRequest *bitly;
	MBProgressHUD *HUD;
	
	UIWebView *webArticleView;
	UIToolbar *toolbar;
	UIToolbar *networkToolbar;
	UIToolbar *articleToolbar;
	NSIndexPath *articleID;
	NSArray *articles;
	NSInteger textSize;
	
	UIActivityIndicatorView *activityIndicator;
	UIBarButtonItem *saveBtn;
}

@property(nonatomic, retain) UIWebView *webArticleView;
@property(nonatomic, retain) BitlyRequest *bitly;
@property(nonatomic, retain) NSArray *articles;
@property(nonatomic, retain) NSIndexPath *articleID;
@property(nonatomic, assign) NSInteger textSize;
@property(nonatomic, retain) UIToolbar *toolbar;
@property(nonatomic, retain) UIToolbar *networkToolbar;
@property(nonatomic, retain) UIToolbar *articleToolbar;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UIBarButtonItem *saveBtn;

- (void)displayComposerSheet;
- (void)generateTitle;
- (void)generateArticle;
- (void)fadeView:(UIView*)viewToFade withFilter:(NSString*)filter;
- (void)enableControls:(BOOL)_bool;
- (void)showLoader:(SEL)task;

@end