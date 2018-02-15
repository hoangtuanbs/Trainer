//
//  DataSource.h
//  iTrainer
//
//  Created by Tuan VU on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "WorkoutDetail.h"
#import "Series.h"
#import "UserProfile.h"
//#import "GifDecoder.h"
#import "AnimatedGif.h"
@interface DataSource : NSObject {
	sqlite3 *database;
	NSDateFormatter *inputFormatter;
	UserProfile *user;
	NSArray * workingDays;
	NSCalendar *gregorian;
	AnimatedGif *decoder;
}

@property (nonatomic, retain) UserProfile *user;

- (bool) isRegistered;
- (bool) registerUser: (UserProfile*) newUser withComplex: (NSString*) complexity andGoal: (NSString*) goal andDays:(NSInteger)days;
- (NSArray*) getTraining ;
- (NSArray*) getGoal;
- (bool) registerTrainingProgramWithComplexity: (NSString*) complexity trainingGoal: (NSString*) goal andDays: (NSInteger) days;
- (NSArray*) getWorkOutDetailAtTime: (NSDate*) time ;
- (NSArray*) getImagesForWorkoutID: (NSInteger) workoutID;
- (BOOL) updateProgressOfSeries: (NSArray*) series;
- (BOOL) updateProgressOfSeri:(Series*) seri;
- (NSArray*) getSeriesStatusForMonth: (NSInteger) month andYear: (NSInteger) year;
- (void) createSeries ;
- (NSString*) getCurrentGoal;
- (NSString*) getCurrentTraining;
- (BOOL) clearAllProgressFromDay: (NSDate*) date;

- (void) ChangeDietPlan : (NSInteger) newPlan;
@end
