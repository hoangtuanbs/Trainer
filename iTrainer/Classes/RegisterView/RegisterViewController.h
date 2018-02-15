//
//  RegisterViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import "PickerViewController.h"

#import "UserProfile.h"
@interface RegisterViewController : UIViewController <UITextFieldDelegate> {
	UITextField *nameField;
	UITextField *emailField;
	UITextField *genderField;
	//UITextField *weightField;
	//UITextField *heightField;
	//UITextField *genderField;
	UITextField *physicalComplexity;
	UITextField *trainingGoal;
	UIButton *nextButton;
	UIButton *cancelButton;
	
	iTrainerAppDelegate *delegate;
	PickerViewController * pickerView;
	
	NSArray *trainingData;
	NSArray *goalData;
	NSArray *genderData;
	//MeasurementViewController *nextController;
	
	UIImageView *imageMonday;
	UIImageView *imageTuesday;
	UIImageView *imageWednesday;
	UIImageView *imageThursday;
	UIImageView *imageFriday;
	UIImageView *imageSaturday;
	UIImageView *imageSunday;
	
	NSInteger monday;
	NSInteger tuesday;
	NSInteger wednesday;
	NSInteger thursday;
	NSInteger friday;
	NSInteger saturday;
	NSInteger sunday;
	
	UIImage* onImage;
	UIImage* offImage;
	

	
	UILabel *nameLabel;
	UILabel *emailLabel;
	UILabel *genderLabel;
	UILabel *trainingStatusLabel;
	UILabel *trainingGoalLabel;
	UILabel *mondayLabel;
	UILabel *tuesdayLabel;
	UILabel *wednesdayLabel;
	UILabel *thursdayLabel;
	UILabel *fridayLabel;
	UILabel *saturdayLabel;
	UILabel *sundayLabel;
	BOOL isCreatedForEdit;
	UserProfile *userProfile;
	

}

- (id) initWithDataSource: (UserProfile* ) user;
@property (nonatomic, retain) iTrainerAppDelegate *delegate;
@property (nonatomic, retain) UserProfile *userProfile;

@property (nonatomic, retain) IBOutlet	UITextField *nameField;
@property (nonatomic, retain) IBOutlet	UITextField *emailField;
@property (nonatomic, retain) IBOutlet  UITextField *genderField;
//@property (nonatomic, retain) IBOutlet	UITextField *weightField;
//@property (nonatomic, retain) IBOutlet	UITextField *heightField;
@property (nonatomic, retain) IBOutlet	UITextField *physicalComplexity;
@property (nonatomic, retain) IBOutlet	UITextField *trainingGoal;
@property (nonatomic, retain) IBOutlet	UIButton *nextButton;
@property (nonatomic, retain) IBOutlet  UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet 	UIImageView *imageMonday;
@property (nonatomic, retain) IBOutlet UIImageView *imageTuesday;
@property (nonatomic, retain) IBOutlet UIImageView *imageWednesday;
@property (nonatomic, retain) IBOutlet UIImageView *imageThursday;
@property (nonatomic, retain) IBOutlet UIImageView *imageFriday;
@property (nonatomic, retain) IBOutlet UIImageView *imageSaturday;
@property (nonatomic, retain) IBOutlet UIImageView *imageSunday;

					  
@property (nonatomic, retain) IBOutlet	UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet  UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet  UILabel *genderLabel;
@property (nonatomic, retain) IBOutlet  UILabel *trainingStatusLabel;
@property (nonatomic, retain) IBOutlet UILabel *trainingGoalLabel;
@property (nonatomic, retain) IBOutlet  UILabel *mondayLabel;
@property (nonatomic, retain) IBOutlet UILabel *tuesdayLabel;
@property (nonatomic, retain) IBOutlet UILabel *wednesdayLabel;
@property (nonatomic, retain) IBOutlet UILabel *thursdayLabel;
@property (nonatomic, retain) IBOutlet  UILabel *fridayLabel;
@property (nonatomic, retain) IBOutlet UILabel *saturdayLabel;
@property (nonatomic, retain) IBOutlet UILabel *sundayLabel;


- (IBAction) cancelButtonPressed: (id) sender;
- (IBAction) nextButtonPressed:(id) sender;
- (IBAction) genderFieldSelected: (id) sender;
- (IBAction) trainingFieldSelected :(id) sender;
- (IBAction) goalFieldSelected :(id) sender;
- (IBAction) resign: (id) sender;
- (IBAction) mondayPressed: (id) sender;
- (IBAction) tuesdayPressed: (id) sender;
- (IBAction) wednesdayPressed: (id) sender;
- (IBAction) thursdayPressed: (id) sender;
- (IBAction) fridayPressed: (id) sender;
- (IBAction) saturdayPressed: (id) sender;
- (IBAction) sundayPressed: (id) sender;

- (BOOL) textFieldShouldReturn:(UITextField *)textField ;


@end
