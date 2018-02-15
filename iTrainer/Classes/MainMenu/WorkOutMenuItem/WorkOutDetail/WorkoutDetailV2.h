//
//  WorkoutDetailV2.h
//  iTrainer
//
//  Created by Tuan VU on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutDetail.h"
#import "Series.h"
#import "iTrainerAppDelegate.h"
@class WorkoutDetailV2;

@protocol WorkoutDetailDelegate <NSObject>
@optional
-(void) viewShouldTransitToNextView: (WorkoutDetailV2*) view;
- (void) viewShouldTransitToPreviousView: (WorkoutDetailV2*) view;

@end


@interface WorkoutDetailV2 : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	WorkoutDetail *workoutDetail;
	UIButton *nextButton;
	UIButton *prevButton;
	UILabel * mainLabel;
	UITableView * tblView;
	UIImageView *imgView;
	UIImage* image;
	UIImage *checkMarkOff;
	UITextView *InstructionView;
	NSArray * dataSource;
	iTrainerAppDelegate *appDelegate;
	int count;
	id<WorkoutDetailDelegate> viewDelegate;
	UIScrollView * scrollView;

	UIView *tableContainer;
	
	UIImage *headerBkImage ;
	UIImage *cellBkImage;
	
}
@property ( assign) id <WorkoutDetailDelegate> viewDelegate;
@property (nonatomic, assign)  WorkoutDetail *workoutDetail;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet 	UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UILabel * mainLabel;
@property (nonatomic, retain) IBOutlet UITableView * tblView;
@property (nonatomic, retain) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) IBOutlet UITextView *InstructionView;
@property (nonatomic, assign) IBOutlet UIScrollView * scrollView;
@property (nonatomic, assign) IBOutlet UIView* tableContainer;
- (id)initWithWorkout: (WorkoutDetail*) newWorkout ;
- (IBAction) buttonNextPressed: (id) sender ;
- (IBAction) buttonPreviousPressed: (id) sender ;
- (void) setTitle : (NSString *) title;
- (void) updateViewWithWorkout: (WorkoutDetail*) newWorkout;
@end
