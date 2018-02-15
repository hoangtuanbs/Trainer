//
//  WorkoutDetail.h
//  iTrainer
//
//  Created by Tuan VU on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStatusFull 1
#define kStatusEmpty 0
#define kStatusPartial -1
@interface WorkoutDetail : NSObject {
	NSInteger workoutID;
	NSInteger descriptionID;
	NSInteger order;
	NSInteger dayOfWeek;
	NSString *name;
	NSString *group;
	NSString *preparation;
	NSString *execution;
	NSString *comment;
	NSArray *series;
	NSInteger display;
}

- (id) initWithWorkoutID: (NSInteger) wkID descriptionID: (NSInteger) dID;
- (void) updateStatus: (NSArray*) newSeries;
- (void) updateStatusForIndex: (NSInteger) index withNewStatus: (NSInteger) newStatus;
- (NSInteger) statusAtIndex: (NSInteger) index;
- (NSInteger ) statusOfSeries ;
- (void) defineStatus: (NSInteger) newStatus;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *group;
@property (nonatomic, retain) NSString *preparation;
@property (nonatomic, retain) NSString *execution;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic) NSInteger workoutID;
@property (nonatomic) NSInteger descriptionID;
@property (nonatomic) NSInteger order;
@property (nonatomic) NSInteger dayOfWeek;
@property (nonatomic) NSInteger display;

@property (nonatomic, retain) NSArray *series;


@end
