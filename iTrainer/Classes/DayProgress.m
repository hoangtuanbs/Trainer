//
//  DayProgress.m
//  iTrainer
//
//  Created by Tuan VU on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DayProgress.h"


@implementation DayProgress
@synthesize day, totalWorkout, workoutCompleted;

- (id) initWithDay: (NSInteger) _day withTotal: (NSInteger) total andCompleted: (NSInteger) completed {

	if (self = [super init]) {
		day = _day;
		totalWorkout = total;
		workoutCompleted = completed;
		
	}
	return self;
}

- (id) initWithDay:( NSInteger) _day {
	if (self= [super init]) {
		day = _day;
	}
	return self;
}

- (double) getPercentage {
	return (workoutCompleted / (totalWorkout*1.0)) *100.0;
}
@end
