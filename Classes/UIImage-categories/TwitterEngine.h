//
//  TwitterAPI.h
//  Starling
//
//  Created by Ricky Cheng on 8/6/10.
//  Copyright 2010 Family. All rights reserved.
//

#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@interface TwitterEngine : NSObject <SA_OAuthTwitterControllerDelegate> {
	SA_OAuthTwitterEngine				*_engine;
	id delegate;
	SEL callback;
}

@property (nonatomic) id delegate;
@property (nonatomic) SEL callback;

- (BOOL)authenticate:(UIViewController*)viewController withDelegate:(id)_delegate andCallback:(SEL)_callback;
- (void)postMessage:(NSString*)message;

@end
