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

@interface RegisterViewController : UIViewController <UITextFieldDelegate> {
	UITextField *nameField;
	UITextField *emailField;
	UITextField *genderField;
	UITextField *heightField;
	UITextField *weightField;
	UITextField *physicalField;
	UITextField *trainingGoalField;
	UIButton *monButton;
	UIButton *tueButton;
	UIButton *wedButton;
	UIButton *thrButton;
	UIButton *friButton;
	UIButton *sarButton;
	UIButton *sunButton;
	UIButton *saveButton;
	UIButton *cancelButton;
	iTrainerAppDelegate *delegate;
	PickerViewController * pickerView;
	NSArray * physicalData;
	NSArray * trainingData;
}

@property (nonatomic, retain) iTrainerAppDelegate *delegate;
@property (nonatomic, retain) IBOutlet	UITextField *nameField;
@property (nonatomic, retain) IBOutlet	UITextField *emailField;
@property (nonatomic, retain) IBOutlet	UITextField *genderField;
@property (nonatomic, retain) IBOutlet	UITextField *heightField;
@property (nonatomic, retain) IBOutlet	UITextField *weightField;
@property (nonatomic, retain) IBOutlet	UITextField *physicalField;
@property (nonatomic, retain) IBOutlet	UITextField *trainingGoalField;
@property (nonatomic, retain) IBOutlet	UIButton *monButton;
@property (nonatomic, retain) IBOutlet	UIButton *tueButton;
@property (nonatomic, retain) IBOutlet	UIButton *wedButton;
@property (nonatomic, retain) IBOutlet	UIButton *thrButton;
@property (nonatomic, retain) IBOutlet	UIButton *friButton;
@property (nonatomic, retain) IBOutlet	UIButton *sarButton;
@property (nonatomic, retain) IBOutlet	UIButton *sunButton;
@property (nonatomic, retain) IBOutlet	UIButton *saveButton;
@property (nonatomic, retain) IBOutlet  UIButton *cancelButton;
@property (nonatomic, retain) NSArray *trainingData;
@property (nonatomic, retain) NSArray *physicalData;

- (IBAction) cancelButtonPressed: (id) sender;
- (IBAction) saveButtonPressed:(id) sender;
- (IBAction) genderFieldSelected: (id) sender;
- (IBAction) resign: (id) sender;
- (IBAction) physicalFieldSelected: (id) sender;
- (IBAction) trainingGoalFieldSelected: (id) sender;


- (BOOL) textFieldShouldReturn:(UITextField *)textField ;

- (void) loadDataFromField;
@end
