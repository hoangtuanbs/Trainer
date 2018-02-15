//
//  ChangeDietPlan.m
//  iTrainer
//
//  Created by Tuan VU on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChangeDietPlan.h"

@interface ChangeDietPlan ()

- (void) updateStatus;
@end

@implementation ChangeDietPlan
@synthesize dietSwitch, normalSwitch, parentView, normalLabel, dietLabel;
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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);
	NSLog(@"Welcome Text: %@", NSLocalizedString(@"Workout", @""));
	[normalLabel setText:NSLocalizedString(@"Normal diet plan", "")];
	[dietLabel setText:NSLocalizedString(@"Diet plan", "")];
	
	delegate = [[UIApplication sharedApplication] delegate];
	[self updateStatus];
	NSLog(@"ChangeDietPlan: Created");
    [super viewDidLoad];
}


- (void) viewWillAppear: (BOOL) animation {
	[self updateStatus];

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
	[dietSwitch release];
	[normalSwitch release];
	[normalLabel release];
	[dietLabel release];
	NSLog(@"ChangeDietPlan: Destroyed");
    [super dealloc];
}

- (void) updateStatus {
	if (delegate.dataSource.user.dietPlan == 0) {
		[normalSwitch setOn:TRUE];
		[dietSwitch setOn:FALSE];
	} else {
		[normalSwitch setOn:FALSE];
		[dietSwitch setOn:TRUE];
	}
}

- (IBAction) switched: (id) sender {
	if (sender == normalSwitch) {
		[dietSwitch setOn:!normalSwitch.on animated: YES];
		
	} else {
		[normalSwitch setOn:!dietSwitch.on animated: YES];
	}
	[delegate.dataSource ChangeDietPlan:(normalSwitch.on ? 0 : 1)];
	delegate.dataSource.user.dietPlan = (normalSwitch.on ? 0 : 1);
}

- (IBAction) backgroundClicked: (id) sender {
	[self.view removeFromSuperview];
	[parentView viewShouldReload];
}
@end
