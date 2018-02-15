/*

File: TransitionView.m
Abstract: A convenience class that allows to replace a subview by another one
using one of the built-in CoreAnimation transitions.

Version: 1.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <QuartzCore/QuartzCore.h>
#import "TransitionView.h"
#define DEFAULT_SCREEN_WIDE 320
#define DEFAULT_SCREEN_HIGH 460
#define CGPointZeroLeft CGPointMake(-320, 0)
#define CGPointZeroRight CGPointMake(320, 0)
#define CGFrameLeft CGRectMake(-320.0, 0.0, 320, 460)
#define CGFrameRight CGRectMake(320.0, 0.0, 320, 460)
#define CGFrameZero CGRectMake(0.0, 0.0, 320, 460)
#define kAnimationKey @"transitionViewAnimation"
@interface TransitionView ()
// Private Methods

-(void)dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event;
-(void)dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position;
-(void)dispatchTouchEndEvent:(UIView *)theView toPosition:(CGPoint)position;
- (double ) getDistanceFromPoint: (CGPoint) fromPoint toPoint: (CGPoint) point;
@end
@implementation TransitionView

@synthesize delegate, transitioning, nextView;

// Method to replace a given subview with another using a specified transition type, direction, and duration
- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView  {


	/*
	// If a transition is in progress, do nothing
	if(transitioning) {
		return;
	}*/
	
	NSArray *subViews = [self subviews];
	NSUInteger index;
	
	if ([oldView superview] == self) {
		// Find the index of oldView so that we can insert newView at the same place
		for(index = 0; [subViews objectAtIndex:index] != oldView; ++index) {}
		[oldView removeFromSuperview];
	}
	
	// If there's a new view and it doesn't already have a superview, insert it where the old view was
	if (newView && ([newView superview] == nil))
		[self insertSubview:newView atIndex:index];
	/*
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	// Set the type and if appropriate direction of the transition,
	[animation setType:kCATransitionPush];
	[animation setSubtype: isMovingLeft? kCATransitionFromLeft : kCATransitionFromRight];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kAnimationKey];*/
}


// Not used in this example, but may be useful in your own project
- (void)cancelTransition {
	// Remove the animation -- cleanup performed in animationDidStop:finished:
	[[self layer] removeAnimationForKey:kAnimationKey];
}


- (void)animationDidStart:(CAAnimation *)animation {
	transitioning = YES;
	// Record the current value of userInteractionEnabled so it can be reset in animationDidStop:finished:
	wasEnabled = self.userInteractionEnabled;
	
	// If user interaction is not already disabled, disable it for the duration of the animation
	if (wasEnabled) {
		self.userInteractionEnabled = NO;
    }
    
	// Inform the delegate if the delegate implements the corresponding method
	if([delegate respondsToSelector:@selector(transitionViewDidStart:)]) {
		[delegate transitionViewDidStart:self];
    }
}


- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	transitioning = NO;
	// Reset the original value of userInteractionEnabled
	if (wasEnabled) {
		self.userInteractionEnabled = YES;
	}
    
	// Inform the delegate if it implements the corresponding method
	if (finished) {
		if ([delegate respondsToSelector:@selector(transitionViewDidFinish:)]) {
			[delegate transitionViewDidFinish:self];
        }
	}
	else {
		if ([delegate respondsToSelector:@selector(transitionViewDidCancel:)]) {
			[delegate transitionViewDidCancel:self];
        }
	}
}


- (void) dealloc {
	[super dealloc];
}
// Checks to see which view, or views, the point is in and then calls a method to perform the opening animation,
// which  makes the piece slightly larger, as if it is being picked up by the user.
-(void)dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event {
	NSLog([NSString stringWithFormat:@"Touch began at point (%f, %f)", touchPoint.x, touchPoint.y]);
	previousLocation = touchPoint;
	relativePreviousPoint = touchPoint;
	
	// initialize conditions for touching effects
	layer = [self layer];
	//layer.anchorPoint = CGPointZero;
	//layer.position = CGPointZero;
	relativeInitialPoint = layer.position;
	initializedMovingLeft = FALSE;
	isMovingLeft = FALSE;
	isMovingRight = FALSE;
	nextView = nil;
	nextLayer = nil;
	NSLog([NSString stringWithFormat:@"Initial point: (%f , %f)", layer.position.x, layer.position.y]);
}


// Checks to see which view, or views, the point is in and then sets the center of each moved view to the new postion.
// If views are directly on top of each other, they move together.
-(void)dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position {
	// This is reference point to the screen, not the point
	CGPoint currentTouchPoint = CGPointMake( position.x +( layer.position.x - relativeInitialPoint.x), position.y + layer.position.y - relativeInitialPoint.y);
	if ((layer.position.x < relativeInitialPoint.x)&& (!isMovingLeft)) {
		//if (nextView) { 
		//	[nextView removeFromSuperview];
		//}
		if ([delegate respondsToSelector:@selector(viewShouldMoveLeft)]) {
			nextView = (UIView*) [delegate viewShouldMoveLeft];
			if (nextView) {
				nextLayer = [nextView layer];
				//nextLayer.anchorPoint = CGPointZero;
				nextLayer.frame = CGFrameRight;
				//nextLayer.position = CGPointMake( relativeInitialPoint.x - DEFAULT_SCREEN_WIDE, 
				//relativeInitialPoint.y );
				
				NSLog([NSString stringWithFormat:@"Moving left from: (%f , %f)", nextLayer.position.x, nextLayer.position.y]);
				[self addSubview:nextView];
			}
			else nextLayer = nil;
        }
		isMovingLeft = TRUE;
		isMovingRight = FALSE;
	}
	if ((layer.position.x > relativeInitialPoint.x)&& (!isMovingRight)) {
		//if (nextView) {
		//	[nextView removeFromSuperview];
		//}
		if ([delegate respondsToSelector:@selector(viewShouldMoveRight)]) {
			nextView = (UIView*) [delegate viewShouldMoveRight];
			if (nextView) {
				//nextLayer.anchorPoint = CGPointZero;
				//nextLayer.position = CGPointZero;
				nextLayer = [nextView layer];
				nextLayer.frame = CGFrameLeft;
				//nextLayer.position = CGPointMake( relativeInitialPoint.x + DEFAULT_SCREEN_WIDE,  relativeInitialPoint.y +20);
				[self addSubview:nextView];
				NSLog([NSString stringWithFormat:@"Moving right from: (%f , %f)", nextLayer.position.x, nextLayer.position.y]);
			}
			else nextLayer = nil;
        }
		isMovingRight = TRUE;
		isMovingLeft = FALSE;
	}
	//NSLog([NSString stringWithFormat:@"Touch move to point (%f, %f) with movement: %f", position.x, position.y, position.x - previousLocation.x]);
	CGFloat displacement = (currentTouchPoint.x - previousLocation.x);
	CGPoint currentPoint = CGPointMake (layer.position.x+ displacement, 
										layer.position.y);

	//CGPoint nextCurrentPont = CGPointMake (nextLayer.position.x+(currentTouchPoint.x - previousLocation.x), 
	//									   nextLayer.position.y);
	//NSLog([NSString stringWithFormat:@"Layer moved to (%f, %f)", currentTouchPoint.x, currentTouchPoint.y]);
	if (layer.position.x!= currentPoint.x) {
		//[UIView beginAnimations:nil context:nil];
		//[ UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
		//[ UIView setAnimationDuration: 0.1f ];
		layer.position = currentPoint;
		if (nextLayer) {
			//NSLog([NSString stringWithFormat:@"Next layer is located at: (%f + %f, %f)", nextLayer.position.x, displacement, nextLayer.position.y]);
 
			nextLayer.frame = CGRectMake(nextLayer.frame.origin.x + displacement/3, nextLayer.frame.origin.y, DEFAULT_SCREEN_WIDE, DEFAULT_SCREEN_HIGH) ;
		}
		NSLog([NSString stringWithFormat:@"Next layer is located at: (%f , %f)", nextLayer.frame.origin.x, nextLayer.frame.origin.y]);


		//[UIView commitAnimations];
	}
		
	previousLocation = currentTouchPoint;
}

// Checks to see which view, or views,  the point is in and then calls a method to perform the closing animation,
// which is to return the piece to its original size, as if it is being put down by the user.
-(void)dispatchTouchEndEvent:(UIView *)theView toPosition:(CGPoint)position {
	BOOL replace ;
	if (abs(previousLocation.x - relativePreviousPoint.x) >30) {
		replace = TRUE;
	} 
	else {
		replace = FALSE;
	}

	
	if (!replace) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
		[UIView setAnimationDuration: 0.3f ];
		layer.frame = CGFrameZero;
		nextLayer.frame = isMovingLeft  ? CGFrameRight : CGFrameLeft;
		[UIView commitAnimations];
	} else {

		
		CATransition * animation = [CATransition animation];
		[animation setType: kCATransitionMoveIn];
		[animation setSubtype:(isMovingLeft)? kCATransitionFromRight : kCATransitionFromLeft];
		[animation setDuration:0.3f];
		//[animation setTimingFunction:kCAMediaTimingFunctionEaseInEaseOut];

		//nextLayer.frame = CGFrameZero;
		layer.frame = isMovingLeft  ? CGFrameLeft : CGFrameRight;
		[layer addAnimation:animation forKey:@"Any"];
		[nextLayer addAnimation:animation forKey:@"Any 2"];
		//NSArray *subViews = [self subviews];
		//NSUInteger index;
		
	
		// Find the index of oldView so that we can insert newView at the same place
		//for(index = 0; [subViews objectAtIndex:index] != nextView; ++index) {}
		//	[[subViews objectAtIndex:index -1] removeFromSuperview];		
	}

	isMovingLeft = FALSE; 
	isMovingRight = FALSE;
	NSLog([NSString stringWithFormat:@"Next layer is located at: (%f , %f)", nextLayer.frame.origin.x, nextLayer.frame.origin.y]);
	

	NSLog([NSString stringWithFormat:@"Touch ended at point (%f, %f)", position.x, position.y]);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	for (UITouch *touch in touches) {
		// Send to the dispatch method, which will make sure the appropriate subview is acted upon
		[self dispatchFirstTouchAtPoint:[touch locationInView:self] forEvent:nil];
	}	
} 

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

// Handles the end of a touch event.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// Enumerates through all touch object
	for (UITouch *touch in touches) {
		// Sends to the dispatch method, which will make sure the appropriate subview is acted upon
		[self dispatchTouchEndEvent:[touch view] toPosition:[touch locationInView:self]];
	}
}


// Handles the continuation of a touch.
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
	// Enumerates through all touch objects
	for (UITouch *touch in touches) {
		// Send to the dispatch method, which will make sure the appropriate subview is acted upon
		[self dispatchTouchEvent:[touch view] toPosition:[touch locationInView:self]];
	}
}

- (double ) getDistanceFromPoint: (CGPoint) fromPoint toPoint: (CGPoint) point {
	return sqrt(fromPoint.x * fromPoint.x + point.y*point.y);	
}


@end
