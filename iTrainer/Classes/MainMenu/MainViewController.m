//
//  MainViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#include "iTrainerAppDelegate.h"

@implementation MainViewController

@synthesize menuTitle, menuView, dietButton;
@synthesize delegate, workOutViewController, faqViewController, workoutButton;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void) viewWillAppear: (BOOL) animated {
	self.navigationController.title = NSLocalizedString( @"Training", "");
	self.navigationItem.title = NSLocalizedString( @"Training", "");
	
	CATransition * animation = [CATransition animation];
	animation.type = kCATransitionMoveIn;
	animation.subtype = kCATransitionFromTop;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.duration = 0.3;
	[self.view addSubview:menuView];
	[menuView.layer addAnimation:animation forKey:@"Animating menu"];
	[delegate.navMainMenuController setNavigationBarHidden:NO animated:animated];
	[delegate.navMainMenuController setToolbarHidden:YES animated:animated];
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear: (BOOL) animated {
	CATransition * animation = [CATransition animation];
	animation.type = kCATransitionMoveIn;
	animation.subtype = kCATransitionFromTop;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.duration = 0.3;
	[menuView removeFromSuperview];
	[menuView.layer addAnimation:animation forKey:@"Animating menu"];
	[super viewWillDisappear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.png"]]];
	delegate = [[UIApplication sharedApplication] delegate];
	menuTitle = [delegate.appData objectForKey:@"RootMenu"];

	//menuView.frame = CGRectMake(0.0, 480.0, 320.0, 248.0);
	[menuView removeFromSuperview];
	
	[workoutButton setImage: [UIImage imageNamed:@"workout-on.png"] forState: UIControlStateSelected];
	[dietButton setImage:[UIImage imageNamed:@"diet-plan-on.png"] forState:UIControlStateSelected];
	NSLog(@"Mainview: Loaded" );
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
	[workOutViewController release];
	[faqViewController release];
	[menuTitle release];
	[delegate release];
	[dietPlan release];
	[menuView release];
	[workoutButton release];
	[dietButton release];
	NSLog(@"Mainview: Destroyed");
	[super dealloc];
}

- (void) pushWorkoutView {
	[self.navigationController pushViewController:workOutViewController animated:YES];
}

- (void) PushWorkoutView {
	if (!workOutViewController) {
		workOutViewController = [[WorkoutView alloc] initWithNibName:@"WorkoutView" bundle:nil];
		[self performSelector:@selector(pushWorkoutView) withObject: nil afterDelay: 0.25];
	} else
	// push view controller
	[self performSelector:@selector(pushWorkoutView) withObject: nil afterDelay: 0.5];
	
}

- (void) PushFAQView {
	// menu faq
	if (!faqViewController) {
		faqViewController = [[FAQViewController alloc] initWithNibName:@"FAQViewController" bundle:[NSBundle mainBundle]];
	}
	[delegate.navMainMenuController pushViewController:faqViewController animated:YES];
}

- (void) PushDietView {
	if (!dietPlan) {
		dietPlan = [[DietPlan alloc] initWithNibName:@"DietPlan" bundle:[NSBundle mainBundle]];
	}
	[delegate.navMainMenuController pushViewController:dietPlan animated:YES];
}

- (IBAction) workoutMenuClicked : (id) sender {

	[self PushWorkoutView];
}
- (IBAction) dietPlanClicked: (id) sender {
	[self PushDietView];
}
- (IBAction) consultTrainerClicked: (id) sender {
	[self PushFAQView];
}


@end
