//
//  SnoopWindow.m
//  iPhoneIncubator
//
//  Created by Nick Dalton on 9/25/09.
//  Copyright 360mind 2009. All rights reserved.
//
//

#import "SnoopWindow.h"
#import "Constants.h"

#define SWIPE_DRAG_HORIZ_MIN 40
#define SWIPE_DRAG_VERT_MAX 40
#define ZOOM_DRAG_MIN 20


@implementation SnoopWindow

@synthesize webView;

#pragma mark -
#pragma mark Helper functions for generic math operations on CGPoints

CGFloat CGPointDot(CGPoint a,CGPoint b) {
	return a.x*b.x+a.y*b.y;
}

CGFloat CGPointLen(CGPoint a) {
	return sqrtf(a.x*a.x+a.y*a.y);
}

CGPoint CGPointSub(CGPoint a,CGPoint b) {
	CGPoint c = {a.x-b.x,a.y-b.y};
	return c;
}

CGFloat CGPointDist(CGPoint a,CGPoint b) {
	CGPoint c = CGPointSub(a,b);
	return CGPointLen(c);
}

CGPoint CGPointNorm(CGPoint a) {
	CGFloat m = sqrtf(a.x*a.x+a.y*a.y);
	CGPoint c;
	c.x = a.x/m;
	c.y = a.y/m;
	return c;
}


- (void)sendEvent:(UIEvent *)event {
	NSArray *allTouches = [[event allTouches] allObjects];
	UITouch *touch = [[event allTouches] anyObject];
	UIView *touchView = [touch view];
//	NSLog(@"touch view => %@",touchView);
	
	if(event.type == UIEventSubtypeMotionShake) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOOK object:nil];
		return;
	}
	
	if (touchView && [touchView isDescendantOfView:webView]) {
		//
		// touchesBegan
		//
		if (touch.phase==UITouchPhaseBegan) {
			startTouchPosition1 = [touch locationInView:self];
			startTouchTime = touch.timestamp;
			
			if ([[event allTouches] count] > 1) {
				startTouchPosition2 = [[allTouches objectAtIndex:1] locationInView:self];
				previousTouchPosition1 = startTouchPosition1;
				previousTouchPosition2 = startTouchPosition2;
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTED object:touch];
			}
		}
        
		
		//
		// touchesMoved
		//
		if (touch.phase==UITouchPhaseMoved) {
			if ([[event allTouches] count] > 1) {
				CGPoint currentTouchPosition1 = [[allTouches objectAtIndex:0] locationInView:self];
				CGPoint currentTouchPosition2 = [[allTouches objectAtIndex:1] locationInView:self];

				CGFloat currentFingerDistance = CGPointDist(currentTouchPosition1, currentTouchPosition2);
				CGFloat previousFingerDistance = CGPointDist(previousTouchPosition1, previousTouchPosition2);
				if (fabs(currentFingerDistance - previousFingerDistance) > ZOOM_DRAG_MIN) {
					NSNumber *movedDistance = [NSNumber numberWithFloat:currentFingerDistance - previousFingerDistance];
					if (currentFingerDistance > previousFingerDistance) {
						DLog(@"zoom in");
						[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ZOOM_IN object:movedDistance];
					} else {
						DLog(@"zoom out");
						[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ZOOM_OUT object:movedDistance];
					}
				}
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MOVED object:touch];
		}

		//
		// touchesEnded
		///
		if (touch.phase==UITouchPhaseEnded) {
			CGPoint currentTouchPosition = [touch locationInView:self];
			
			// Check if it's a swipe
			DLog(@"%d %f %d %f time: %g",fabsf(startTouchPosition1.x - currentTouchPosition.x) >= SWIPE_DRAG_HORIZ_MIN ? 1 : 0,
				 fabsf(startTouchPosition1.y - currentTouchPosition.y),
				 fabsf(startTouchPosition1.x - currentTouchPosition.x) > fabsf(startTouchPosition1.y - currentTouchPosition.y)  ? 1 : 0, touch.timestamp - startTouchTime, touch.timestamp - startTouchTime);
			if (fabsf(startTouchPosition1.x - currentTouchPosition.x) >= SWIPE_DRAG_HORIZ_MIN &&
				fabsf(startTouchPosition1.y - currentTouchPosition.y) <= SWIPE_DRAG_VERT_MAX &&
				fabsf(startTouchPosition1.x - currentTouchPosition.x) > fabsf(startTouchPosition1.y - currentTouchPosition.y) &&
				touch.timestamp - startTouchTime < .7
				) {
				// It appears to be a swipe.
				if (startTouchPosition1.x < currentTouchPosition.x) {
					DLog(@"swipe right");
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SWIPE_RIGHT object:touch];
				} else {
					DLog(@"swipe left");
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SWIPE_LEFT object:touch];
				}
			}
			startTouchPosition1 = CGPointMake(-1, -1);
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENDED object:touch];
		}
	}

	[super sendEvent:event];
}

@end
