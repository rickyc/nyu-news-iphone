//
//  TouchImageView.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "TouchImageView.h"

@implementation TouchImageView
@synthesize image_id, imageGalleryViewController;

- (id)initWithFrame:(CGRect)frame {
	[super initWithFrame:frame];
	[self setUserInteractionEnabled:YES];
	[self setMultipleTouchEnabled:YES];
	[self becomeFirstResponder];
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[imageGalleryViewController pushArticle:image_id];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	int tapCount = [[touches anyObject] tapCount];

	DLog(@"touch ended");
	UIMenuController *menu = [UIMenuController sharedMenuController];
	
	if (tapCount == 1  && [menu isMenuVisible]) {
		[menu setMenuVisible:NO animated:YES];
	} else if(tapCount == 2) {
		[menu setTargetRect:CGRectMake(0, 0, 100, 10) inView:self];
		[menu setMenuVisible:YES animated:YES];
	}
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark Menu commands and validation
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
		return YES;
	} else {
		return NO;
	}

	return YES;
}


/*
 These methods are declared by the UIResponderStandardEditActions informal protocol.
 */
- (void)copy:(id)sender {

}

- (void)cut:(id)sender {

}


- (void)paste:(id)sender {

}

- (void)dealloc {
	[imageGalleryViewController release];
    [super dealloc];
}

@end
