//
//  DietPlan.h
//  iTrainer
//
//  Created by Tuan VU on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import "ChangeDietPlan.h"

@interface DietPlan : UIViewController<ParentViewDelegate> {
	UITableView * tableview;
	iTrainerAppDelegate *appDelegate;
	NSMutableArray *dataSource;
	ChangeDietPlan *changeDietPlanView;
	NSArray *tempArr;
}

@property (nonatomic, retain) IBOutlet UITableView * tableview;
- (void) changePlan : (id) sender;
- (void) viewShouldReload;
@end
