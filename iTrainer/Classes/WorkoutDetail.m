//
//  WorkoutDetail.m
//  iTrainer
//
//  Created by Tuan VU on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WorkoutDetail.h"
#import "Series.h"
@interface WorkoutDetail ()


@end


@implementation WorkoutDetail
@synthesize 	workoutID, descriptionID, order, dayOfWeek,name, group, preparation, execution, comment,  display,  series;

- (id) initWithWorkoutID: (NSInteger) wkID descriptionID: (NSInteger) dID {
	if (self = [super init]) {
		workoutID = wkID;
		descriptionID = dID;
		return self;	
	}
	return nil;
}

- (NSInteger) sumOf: (NSArray*)  array {
	NSInteger total = 0;
	for (int i = 0 ; i < [array count]; i++ ) {
		total += [[array objectAtIndex:i] status];
	}
	return total;
}




- (void) updateStatus: (NSArray*) newSeries {
	series = newSeries;
	
}

- (void) updateStatusForIndex: (NSInteger) index withNewStatus: (NSInteger) newStatus {
	Series * newSeri = [series objectAtIndex:index];
	newSeri. status = newStatus;

}


- (NSInteger) statusAtIndex: (NSInteger) index {
	Series * newSeri = [series objectAtIndex:index];
	return newSeri.status;
}

- (void) dealloc {
	if (name) [name release];
	if (group) [group release];
	if (preparation) [preparation release];
	if ( execution) [execution release];
	if (comment) [comment release];
	if (series) [series release];
	[super dealloc];
}

- (NSInteger) statusOfSeries {	
	NSInteger status = [self sumOf:series];
	if (status == 0 ) {
		return kStatusEmpty;	
	}
	if (status == [series count]) return kStatusFull;
	return kStatusPartial;
}

- (void) defineStatus:(NSInteger) newStatus {
	for(int i = 0 ; i < [series count]; i++ ) {
		[self updateStatusForIndex:i withNewStatus:newStatus];	
	}
}

@end
