//
//  FAQViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FAQViewController.h"


@implementation FAQViewController
@synthesize tableView;
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
- (void) submitQuestion {
	NSLog(@"Button submit triggered");
	/*
	if (!consultTrainer) {
		consultTrainer = [[ ConsultTrainerForm alloc] initWithNibName:@"ConsultTrainerForm" bundle:nil];
	}
	
	[self.view.window addSubview:consultTrainer.view];
	// animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];*/
	
	
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear:animated];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	delegate = [[UIApplication sharedApplication] delegate];
	UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:@"Submit question" style:UIBarButtonItemStyleBordered target:self action:@selector(submitQuestion)] ;
	self.navigationItem.rightBarButtonItem = button;
	[button release];
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
	[delegate release];
	[tableView release];
    [super dealloc];
}


@end
