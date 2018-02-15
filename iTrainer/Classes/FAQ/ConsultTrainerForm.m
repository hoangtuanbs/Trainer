//
//  ConsultTrainerForm.m
//  iTrainer
//
//  Created by Tuan VU on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConsultTrainerForm.h"


@implementation ConsultTrainerForm

@synthesize textView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super becomeFirstResponder];
	textView .delegate = self;
    [super viewDidLoad];
}


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

- (void) removeView {
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
	// remove current view 
	[self.view removeFromSuperview];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView2 {
	[textView resignFirstResponder];
	[self removeView];
}

- (BOOL)textViewShouldReturn:(UITextView*)textField
{
	[textView resignFirstResponder];
	[self removeView];
	return YES;
}
@end
