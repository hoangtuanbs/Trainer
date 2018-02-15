//
//  RegisterViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "iTrainerAppDelegate.h"

#import <QuartzCore/QuartzCore.h>
#import "InternetConnector.h"

#define MIN_LENGTH_NAME 4
#define MIN_LENGTH_EMAIL 10
@interface RegisterViewController (Private) 
- (bool) loadDataFromField;
- (void) reloadButtonState;
- (void) reloadState: (UIImageView*) imageView withState: (NSInteger) state;
@end


@implementation RegisterViewController
@synthesize userProfile;
@synthesize nameField, emailField, genderField, physicalComplexity, trainingGoal, sundayLabel;

@synthesize 	nameLabel, emailLabel, genderLabel, trainingStatusLabel, trainingGoalLabel, mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel;
@synthesize nextButton ,cancelButton;
@synthesize delegate, imageMonday, imageTuesday, imageThursday, imageWednesday, imageFriday, imageSunday, imageSaturday;





 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		 // Custom initialization
		 delegate = [[UIApplication sharedApplication] delegate];
		 isCreatedForEdit = FALSE;
	 }
	 return self;
 }
 

- (id) initWithDataSource: (UserProfile*) user {
	if (self = [super initWithNibName:@"RegisterView" bundle:nil]) {
		delegate = [[UIApplication sharedApplication] delegate];
		userProfile = user;
		monday = user.monday;
		tuesday = user.tuesday;
		wednesday = user.wednesday;
		thursday = user.thursday;
		friday  = user.friday;
		saturday = user.saturday;
		sunday = user.sunday;
		isCreatedForEdit = TRUE;
		//[delegate.dataSource getCurrentGoal];
	}
	return self;
}


// set up what will do when view going to appear
- (void) viewWillAppear: (BOOL) animated {
	
	//self.view.center = CGPointMake(160.0, 240.0);
	// hide toolbar
	[delegate.navMainMenuController setToolbarHidden:YES animated:animated];
	// hide navigation bar
	[delegate.navMainMenuController setNavigationBarHidden:NO animated:animated];

	[super viewWillAppear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);
	
	[nameLabel setText:NSLocalizedString(@"Name", "")];
	[emailLabel setText:NSLocalizedString(@"Email", "")]; 
	[genderLabel setText:NSLocalizedString(@"Gender", "")];
	[trainingStatusLabel setText:NSLocalizedString(@"Training status", "")];
	[trainingGoalLabel setText:NSLocalizedString(@"Training goal", "")];
	[mondayLabel setText:NSLocalizedString(@"Monday", "")];
	[tuesdayLabel setText:NSLocalizedString(@"Tuesday", "")];
	[wednesdayLabel setText:NSLocalizedString(@"Wednesday", "")];
	[thursdayLabel setText:NSLocalizedString(@"Thursday", "")];
	[fridayLabel setText:NSLocalizedString(@"Friday", "")];
	[saturdayLabel setText:NSLocalizedString(@"Saturday", "")];\
	[sundayLabel setText:NSLocalizedString(@"Sunday", "")];
	
	nameField.delegate = self;
	emailField.delegate = self;

	goalData = [delegate.dataSource getGoal];
	trainingData = [delegate.dataSource getTraining];
	genderData = [[NSArray alloc] initWithObjects: @"",NSLocalizedString( @"Female", ""),NSLocalizedString(  @"Male", ""), nil];
	
	onImage = [UIImage imageNamed:@"checkmark.png"];
	offImage = [UIImage imageNamed:@"close.png"];
	if (!isCreatedForEdit) {
		monday = 0;
		tuesday =0;
		wednesday = 0;
		thursday = 0;
		friday = 0;
		saturday = 0;
		sunday = 0;
	} else {
		nameField.text = userProfile.name;
	
		emailField.text = userProfile.email;

		genderField.text = userProfile.gender ? NSLocalizedString( @"Male", "") : NSLocalizedString( @"Female" , "");
		physicalComplexity.text = [delegate.dataSource getCurrentTraining];
		
		trainingGoal.text = [delegate.dataSource getCurrentGoal];
		nameField.delegate = self;
		emailField.delegate = self;

		genderField.delegate = self;
		//;
	}
	
	
	
	[self reloadButtonState];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	textField.placeholder = @"";
	return YES;
}

- (IBAction) resign: (id) sender {
	[self textFieldShouldReturn:(UITextField*) sender];
	[nameField resignFirstResponder];
	[emailField resignFirstResponder];

	[genderField resignFirstResponder];
	[physicalComplexity resignFirstResponder];
	[trainingGoal resignFirstResponder];
};

- (void)dealloc {
	[goalData release];
	[trainingGoal release];
	[delegate release];
	[pickerView release];
	[nameField release];
	[emailField release];
	[genderField release];
	[physicalComplexity release];
	[trainingGoal release];
	[nextButton release];
	[cancelButton release];
    [super dealloc];
}

// load data from the field and save to the phone and database
- (bool) loadDataFromField {
		if (([nameField.text length] > MIN_LENGTH_NAME) && 
			( [emailField.text length] > MIN_LENGTH_EMAIL ) && ([genderField text])	) {
			NSInteger gender =([genderField.text isEqualToString:NSLocalizedString( @"Male", "")] ? 1 : 0);
			NSInteger iid = [delegate.internetConnector registerUser: nameField.text withEmail: emailField.text andGender: gender];
			UserProfile *user = [[UserProfile alloc] initWithIID: iid];
			user.name = [NSString stringWithString:nameField.text];
			user.email = [NSString stringWithString:emailField.text];
			user.monday = monday;
			user.tuesday = tuesday;
			user.wednesday = wednesday;
			user.thursday = thursday;
			user.friday = friday;
			user.saturday = saturday;
			user.sunday = sunday;
			user.gender = gender;
			//user.height = [heightField.text intValue];
			NSInteger days  = monday + tuesday + wednesday + friday + thursday + saturday + sunday;
			if (days < 2) days = 2;
			else if (days > 5) days = 5;
		
			return   [delegate.dataSource registerUser: user withComplex: physicalComplexity.text andGoal: trainingGoal.text andDays:days] ;
		}
		else
			return FALSE;
	

}

#pragma mark -
#pragma mark Event Handler

- (IBAction) cancelButtonPressed: (id) sender {
	/*
	// display root view
	[delegate.navMainMenuController popToRootViewControllerAnimated:YES];
	// unhide navigation bar
	[delegate.navMainMenuController setNavigationBarHidden:NO animated:YES];*/
	if (isCreatedForEdit) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error ", "") 
															 message:NSLocalizedString( @"Please register before using the program", "") 
															delegate:self 
												   cancelButtonTitle:NSLocalizedString( @"OK" , "")
												   otherButtonTitles:nil] 
								  autorelease];
		[alertView show];
	}
}

- (IBAction) nextButtonPressed: (id) sender {
	// create next view
	//if (!nextController)
	//	nextController = [[MeasurementViewController alloc] initWithNibName:@"MeasurementView" bundle:nil];
	NSInteger total = monday + tuesday +friday + wednesday + thursday + saturday+ sunday;
	if (total < 1 && total >=5) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error ", "") 
															 message:NSLocalizedString( @"Workout days should be between 2 and 5" , "")
															delegate:self 
												   cancelButtonTitle:NSLocalizedString( @"OK" , "")
												   otherButtonTitles:nil] 
								  autorelease];
		[alertView show];
	}
	else 

	// load data to database.........
	if ([self loadDataFromField]) {
		if (!isCreatedForEdit) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Congratulation" , "")
															 message:NSLocalizedString( @"Your information has been registered" , "")
															delegate:self 
												   cancelButtonTitle:NSLocalizedString( @"OK" , "")
												   otherButtonTitles:nil] 
								  autorelease];
		[alertView show];
		}
		if (!isCreatedForEdit) {
			
			[self.view removeFromSuperview];
			if ([delegate.tabBarRootViewController.view superview] == nil) 
				[delegate.window addSubview:delegate.tabBarRootViewController.view];
			// Set up the animation
		} else {
			[self.navigationController popToRootViewControllerAnimated:YES];	
		}
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		
		// Set the type and if appropriate direction of the transition, 
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromBottom];
		
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:0.25];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
		[super.view.layer addAnimation:animation forKey:@"registerAnimation"];
	}
		//nextController.hidesBottomBarWhenPushed = TRUE;
		//[delegate.navMainMenuController pushViewController:nextController animated:YES];
	else {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error " , "")
															 message:NSLocalizedString( @"Illegeal name or email, please try again" , "")
															delegate:self 
												   cancelButtonTitle:NSLocalizedString( @"OK" , "")
												   otherButtonTitles:nil] 
								  autorelease];
		[alertView show];
	}
	if (isCreatedForEdit) {
		[delegate.dataSource clearAllProgressFromDay:[NSDate date]];
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Notice " ,"")
															 message:NSLocalizedString( @"Please restart the program for new settings to take effect" , "")
															delegate:self 
												   cancelButtonTitle:NSLocalizedString( @"OK" , "")
												   otherButtonTitles:nil] 
								  autorelease];
		[alertView show];
	}
	
}

#pragma mark -
#pragma mark Even Handle
// display gender field
- (IBAction) goalFieldSelected :(id) sender {
	// set up responder for later release
	[sender becomeFirstResponder];
	// set up picker view
	if (pickerView) [pickerView release];
	pickerView = [[PickerViewController alloc] initWithNibName:@"PickerView" 
														bundle:[NSBundle mainBundle] 
													  withData: goalData
											andSelectionObject: (UITextField*)sender];

	// clear keyboard
	[self textFieldShouldReturn:(UITextField*) sender];

	
	//[UIView beginAnimation: @"animation" context: nil];
	[self.view.window addSubview:pickerView.view];
	// animation
	
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// slowly appears 
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	basicAnimation.duration = 0.25;
	basicAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	basicAnimation.toValue = [NSNumber numberWithFloat: 1.0];
	[[pickerView.view layer] addAnimation:basicAnimation forKey:@"animation opacity"];
	[[pickerView.view layer] addAnimation:animation forKey:@"layerAnimation"];
	
//	[dataSource release];
}

- (IBAction) genderFieldSelected: (id) sender {
	// set up responder for later release
	[sender becomeFirstResponder];
	// set up picker view
	if (pickerView) [pickerView release];
	pickerView = [[PickerViewController alloc] initWithNibName:@"PickerView" 
														bundle:[NSBundle mainBundle] 
													  withData: genderData
											andSelectionObject: (UITextField*) sender];
	
	// clear keyboard
	[self textFieldShouldReturn:(UITextField*) sender];
	[self.view.window addSubview:pickerView.view];
	// animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromTop];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	basicAnimation.duration = 0.25;
	basicAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	basicAnimation.toValue = [NSNumber numberWithFloat: 1.0];
	[[pickerView.view layer] addAnimation:basicAnimation forKey:@"animation opacity"];
	[[pickerView.view layer] addAnimation:animation forKey:@"layerAnimation"];
	
	
}
// display gender field
- (IBAction) trainingFieldSelected :(id) sender {

	// set up responder for later release
	[sender becomeFirstResponder];
	// set up picker view
	if (pickerView) [pickerView release];
	pickerView = [[PickerViewController alloc] initWithNibName:@"PickerView" 
															bundle:[NSBundle mainBundle] 
														  withData: trainingData
												andSelectionObject: (UITextField*) sender];

	// clear keyboard
	[self textFieldShouldReturn:(UITextField*) sender];
	[self.view.window addSubview:pickerView.view];
	// animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromTop];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	basicAnimation.duration = 0.25;
	basicAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	basicAnimation.toValue = [NSNumber numberWithFloat: 1.0];
	[[pickerView.view layer] addAnimation:basicAnimation forKey:@"animation opacity"];
	[[pickerView.view layer] addAnimation:animation forKey:@"layerAnimation"];
	
	//[dataSource release];
}

- (IBAction) mondayPressed: (id) sender {
	monday = (monday ? 0 : 1) ;
	[self reloadState:imageMonday withState:monday];
}
- (IBAction) tuesdayPressed: (id) sender {
	tuesday = (tuesday ? 0 : 1) ;
	[self reloadState:imageTuesday withState:tuesday];
}
- (IBAction) wednesdayPressed: (id) sender {
	wednesday = (wednesday ? 0 : 1) ;
	[self reloadState:imageWednesday withState:wednesday];
}
- (IBAction) thursdayPressed: (id) sender {
	thursday = (thursday ? 0 : 1) ;
	[self reloadState:imageThursday withState:thursday];
}
- (IBAction) fridayPressed: (id) sender {
	friday = (friday ? 0 : 1) ;
	[self reloadState:imageFriday withState:friday];
}
- (IBAction) saturdayPressed: (id) sender {
	saturday = (saturday ? 0 : 1) ;
	[self reloadState:imageSaturday withState:saturday];
	
}
- (IBAction) sundayPressed: (id) sender {
	sunday = (sunday ? 0 : 1) ;
	[self reloadState:imageSunday withState:sunday];
}

- (void) reloadButtonState {
	[self reloadState:imageMonday withState:monday];
	[self reloadState:imageTuesday withState:tuesday];
	[self reloadState:imageWednesday withState:wednesday];
	[self reloadState:imageThursday withState:thursday];
	[self reloadState:imageFriday withState:friday];
	[self reloadState:imageSunday withState:sunday];
	[self reloadState:imageSaturday withState:saturday];

}

- (void) reloadState: (UIImageView*) iView withState: (NSInteger) state{
	iView.image = (state ? onImage: offImage);
	NSInteger days  = monday + tuesday + wednesday + friday + thursday + saturday + sunday;
	if (days >1 &&days <= 5) {
		nextButton.enabled = YES;
		nextButton.titleLabel.textColor = [UIColor blueColor];
	}
	else {
		nextButton.enabled = NO;
		nextButton.titleLabel.textColor = [UIColor grayColor];
	}

}
@end
