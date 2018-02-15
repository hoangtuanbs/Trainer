//
//  MainViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import "WorkOutView.h"
#import "FAQViewController.h"
#import "DietPlan.h"
@interface MainViewController : UIViewController {
	
	NSDictionary *menuTitle;
	iTrainerAppDelegate *delegate;
	WorkoutView *workOutViewController;
	FAQViewController *faqViewController;
	DietPlan *dietPlan;
	UIView * menuView;
	UIButton * workoutButton;
	UIButton *dietButton;
}

@property (nonatomic, retain) iTrainerAppDelegate *delegate;
@property (nonatomic, retain) IBOutlet NSDictionary *menuTitle;
@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic, retain) WorkoutView *workOutViewController;
@property (nonatomic, retain) FAQViewController *faqViewController;
@property (nonatomic, retain) IBOutlet UIButton * workoutButton;
@property (nonatomic, retain) IBOutlet UIButton *dietButton;
- (IBAction) workoutMenuClicked : (id) sender ;
- (IBAction) dietPlanClicked: (id) sender ;
- (IBAction) consultTrainerClicked: (id) sender;
@end
