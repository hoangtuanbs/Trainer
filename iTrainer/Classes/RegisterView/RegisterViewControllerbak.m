//
//  RegisterViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "iTrainerAppDelegate.h"
#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RegisterViewController

@synthesize nameField, 
			emailField, 
			genderField, 
			heightField, 
			weightField, 
			physicalField, 
			trainingGoalField;
@synthesize monButton, 
			tueButton, 
			wedButton, 
			thrButton, 
			friButton, 
			sarButton,
			sunButton, 
			saveButton, 
			cancelButton;
@synthesize delegate;

@synthesize trainingData,
			physicalData;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// set up what will do when view going to appear
- (void) viewWillAppear: (BOOL) animated {
	// hide toolbar
	[delegate.navMainMenuController setToolbarHidden:YES animated:animated];
	// hide navigation bar
	[delegate.navMainMenuController setNavigationBarHidden:YES animated:animated];
	
	[super viewWillAppear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	delegate = [[UIApplication sharedApplication] delegate];
	genderField.delegate = self;
	physicalData = [[NSArray alloc] initWithObjects:@"", @"Fat", @"Wellfitted", @"Thin", nil];
	trainingData = [[NSArray alloc] initWithObjects:@"", @"Wellfitted", @"Diet", @"Gain weight", nil];
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
	//[nameField becomeFirstResponder];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}




#pragma mark -
#pragma mark Textfield delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (IBAction) resign: (id) sender {
	[self textFieldShouldReturn:(UITextField*) sender];
	[nameField resignFirstResponder];
	[emailField resignFirstResponder];
	[heightField resignFirstResponder];
	[weightField resignFirstResponder];
	[physicalField resignFirstResponder];
	[trainingGoalField resignFirstResponder];
};

- (void)dealloc {
	[delegate release];
	[nameField release];
	[emailField release];
	[genderField release];
	[heightField release];
	[weightField release];
	[physicalField release];
	[trainingGoalField release];
	[monButton release];
	[tueButton release];
	[wedButton release];
	[thrButton release];
	[friButton release];
	[sarButton release];
	[sunButton release];
	[saveButton release];
	[cancelButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Button Action Methods

- (IBAction) cancelButtonPressed: (id) sender {
	// display root view
	[delegate.navMainMenuController popToRootViewControllerAnimated:YES];
	// unhide navigation bar
	[delegate.navMainMenuController setNavigationBarHidden:NO animated:YES];
}

- (IBAction) saveButtonPressed: (id) sender {
	// display root view
	[delegate.navMainMenuController popToRootViewControllerAnimated:YES];
	// unhide navigation bar
	[delegate.navMainMenuController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -
#pragma mark Even Handle
// display gender field
- (IBAction) genderFieldSelected :(id) sender {
	// set up gender dataset
	NSArray *dataSource = [[NSArray alloc] initWithObjects:@"", @"Male", @"Female", nil];
	// set up responder for later release
	[sender becomeFirstResponder];
	// set up picker view
	pickerView = [[PickerViewController alloc] initWithNibName:@"PickerView" bundle:[NSBundle mainBundle] withData: dataSource andSelectionObject: genderField];
	// clear keyboard
	[self textFieldShouldReturn:(UITextField*) sender];
	[self.view.window addSubview:pickerView.view];
	// animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
	
	[dataSource release];
}

- (IBAction) physicalFieldSelected: (id) sender {
	//set new responnder for later release
	[sender becomeFirstResponder];
	// create a picker view with data set
	pickerView = [[PickerViewController alloc] initWithNibName:@"PickerView" bundle:[NSBundle mainBundle] withData: physicalData andSelectionObject: physicalField];
	// remove keyboard view
	[self textFieldShouldReturn:(UITextField*) sender];
	// display picker view
	[self.view.window addSubview:pickerView.view];
	
	// setup animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
	
}

- (IBAction) trainingGoalFieldSelected: (id) sender {
	// set new responder for later release
	[sender becomeFirstResponder];
	// set up picker view
	pickerView = [[PickerViewController alloc] initWithNibName:@"PickerView" bundle:[NSBundle mainBundle] withData: trainingData andSelectionObject: trainingGoalField];
	// remove keyboard
	[self textFieldShouldReturn:(UITextField*) sender];
	[self.view.window addSubview:pickerView.view];
	
	// setup animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];

}


// load data from the field and save to the phone and database
- (void) loadDataFromField {
	
}
@end
