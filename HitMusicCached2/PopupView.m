//
//  PopupView.m
//  HitMusic
//
//  Created by Tuan VU on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PopupView.h"
#import "HitMusicAppDelegate.h"
#import <QuartzCore/CoreAnimation.h>
@implementation PopupView
@synthesize meterImageView, needleImageView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		UIImage *needleImage = [[UIImage imageNamed:@"needle.png"] autorelease];
		//needleImageView = [[UIImageView alloc] initWithImage:needleImage];
		needleImageView.imageView.image = needleImage;
		//needleImageView.image = needleImage; 
		
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark Custom methods 
- (void) moveNeedle:(int)leftRight {	
	int from = leftRight == 1 ? 1.5 : 2;
	int to	 = leftRight == 1 ? 2	: 1.5;
	CALayer *layer = [needleImageView layer];
	layer.anchorPoint = CGPointMake(0.5, 0.5);
	//layer.frame = CGRectMake(225.0, 85.0, 81.0, 32.0);
	
	CABasicAnimation *rotateAnimation = [CABasicAnimation animation];
	rotateAnimation.keyPath = @"transform.rotation.z";
	rotateAnimation.fromValue = [NSNumber numberWithFloat:from * M_PI];
	rotateAnimation.toValue = [NSNumber numberWithFloat:to * M_PI];
	rotateAnimation.duration = 2;
	rotateAnimation.removedOnCompletion = NO;
	// leaves presentation layer in final state; preventing snap-back to original state
	rotateAnimation.fillMode = kCAFillModeForwards;
	rotateAnimation.repeatCount = 0;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	// add the animation to the selection layer. This causes it to begin animating
	[layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
}

- (void) removeView {
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
	// remove current view 
	[self.view removeFromSuperview];
}
@end
