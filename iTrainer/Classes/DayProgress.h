//
//  DayProgress.h
//  iTrainer
//
//  Created by Tuan VU on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DayProgress : NSObject {
	NSInteger day;
	NSInteger totalWorkout;
	NSInteger workoutCompleted;
}
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger totalWorkout ;
@property (nonatomic) NSInteger workoutCompleted;

- (id) initWithDay: (NSInteger) _day withTotal: (NSInteger) total andCompleted: (NSInteger) completed;
- (id) initWithDay: (NSInteger) _day;
- (double) getPercentage;
@end
