//
//  WorkOutTableViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
//#import "WorkOutDetailController.h"

#import "WorkoutDetailV2.h"
#import "DataSource.h"
#import "WorkoutDetail.h"
@interface WorkOutTableViewController : UITableViewController 
<UITableViewDelegate, UITableViewDataSource, WorkoutDetailDelegate> {
	UIImage *checkmark;
	UIImage *checkmarkFull;
	UIImage *checkmarkNon;
	DataSource *database;
	NSArray *dataSource;
	iTrainerAppDelegate *delegate;
	//WorkoutDetailV2 *newViewController;
	NSDate *date;
	NSInteger selectedIndex ;
	UIViewController * controllerView;

	WorkoutDetailV2 *currentView;
	WorkoutDetailV2 *hiddenView;
}
- (id) initWithDate: (NSDate*) cDay;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSArray *dataSource;

//@property (nonatomic, retain) WorkoutDetailV2 * newViewController;
- (void) initDataSource;
@end
