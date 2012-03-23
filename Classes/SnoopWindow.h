//
//  SnoopWindow.h
//  iPhoneIncubator
//
//  Created by Nick Dalton on 9/25/09.
//  Copyright 360mind 2009. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface SnoopWindow : UIWindow {
	NSTimeInterval startTouchTime;
	CGPoint previousTouchPosition1, previousTouchPosition2;
	CGPoint startTouchPosition1, startTouchPosition2;
	UIWebView *webView;
}

@property (nonatomic, assign) UIWebView *webView;

- (void)sendEvent:(UIEvent *)event;

@end
