//
//  ChangeDietPlan.h
//  iTrainer
//
//  Created by Tuan VU on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"

@protocol ParentViewDelegate

- (void) viewShouldReload;

@end

@interface ChangeDietPlan : UIViewController {
	UISwitch *dietSwitch;
	UISwitch *normalSwitch;
	iTrainerAppDelegate *delegate;
	NSInteger selected ;
	id <ParentViewDelegate> parentView;
	UILabel* normalLabel;
	UILabel* dietLabel;
}

@property (nonatomic, retain) IBOutlet UILabel * normalLabel;
@property (nonatomic, retain) IBOutlet UILabel * dietLabel;
@property (nonatomic, retain) IBOutlet UISwitch *dietSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *normalSwitch;
@property (nonatomic, assign) id<ParentViewDelegate> parentView;
- (IBAction) switched: (id) sender;
- (IBAction) backgroundClicked: (id) sender;
@end
