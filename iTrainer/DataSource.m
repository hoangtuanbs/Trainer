//
//  DataSource.m
//  iTrainer
//
//  Created by Tuan VU on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataSource.h"
#import "DayProgress.h"
#import "Series.h"
//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//						DEFINE CLASS CONSTANT
//*********************************************************************************************************************************************
#ifndef PROFILE_CONST
#define PROFILE_CONST
	enum PROFILE {
		IID_COL = 0,
		NAME_COL,
		EMAIL_COL,
		GENDER_COL,
		TIMEID_COL,
		MONDAY_COL,
		TUESDAY_COL,
		WEDNESDAY_COL,
		THURSDAY_COL,
		FRIDAY_COL,
		SATURDAY_COL,
		SUNDAY_COL,
		WEIGHT_COL,
		HEIGHT_COL,
		GOAL_COL,
		COMPLEXITY_COL,
		PROGRAM_COL,
		DIETPLAN_COL
	} ;
#endif
//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
#ifndef SQLSTATEMENT
#define SQLSTATEMENT
static sqlite3_stmt *register_statement = nil;
static sqlite3_stmt *get_training = nil;
static sqlite3_stmt *get_goal = nil;
static sqlite3_stmt *update_user_statement = nil;
static sqlite3_stmt *drop_series_view = nil;
static sqlite3_stmt *get_progress_for_day_statement = nil;
static sqlite3_stmt *create_series_view_statement = nil;
static sqlite3_stmt *get_workouts_for_date_statement = nil;
static sqlite3_stmt *register_program_statement = nil;
static sqlite3_stmt *get_series_for_workout_statement = nil;
static sqlite3_stmt *update_seri_progress_statement = nil;
static sqlite3_stmt *create_workout_progress_statement = nil;
static sqlite3_stmt *get_program_for_workout_and_work_day_statement = nil;
static sqlite3_stmt *get_series_with_description_statement = nil;
static sqlite3_stmt *get_program_with_goal_and_complexity_statement = nil;
static sqlite3_stmt *get_image_for_workout_statement = nil;
static sqlite3_stmt *create_series_view_for_month_statement = nil;
static sqlite3_stmt *drop_series_view_for_month = nil;
static sqlite3_stmt *get_available_day_statement = nil;
static sqlite3_stmt *get_all_progress_for_day_statement =  nil;
static sqlite3_stmt *get_all_done_progress_for_day_statement = nil;
static sqlite3_stmt *get_current_training_statement = nil;
static sqlite3_stmt *get_current_goal_statement = nil;
static sqlite3_stmt *clear_progress_statement = nil;
static sqlite3_stmt *change_diet_plan_statement = nil;
//static sqlite3_stmt *update_trainingday_statement = nil;
//static sqlite3_stmt *update_trainingday_statement = nil;
#endif

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//			PRIVATE DECLARATION
//*********************************************************************************************************************************************
@interface DataSource (Private)
- (void) createEditableCopyOfDatabaseIfNeeded;
- (void) initDatabase;
- (NSInteger) dateToInteger: (NSDate*) date;
- (NSInteger) countWorkingDays: (NSInteger) date;
- (NSString *) UTF8CStringNotNull: (id) inputString;


@end

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//			CLASS IMPLEMENTATION
//*********************************************************************************************************************************************
@implementation DataSource
@synthesize user;
- (id) init  {
	if (self = [super init]) {
		[self createEditableCopyOfDatabaseIfNeeded];
		[self initDatabase];
		inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyyMMdd"];
		gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
	}
	return self;
}

- (NSInteger) countWorkingDays: (NSInteger) date {
	NSInteger total = [[workingDays objectAtIndex:date] intValue];
	for (int i = 0 ; i < date; i++) {
		total += [[workingDays objectAtIndex:i] intValue];
	}
	return total;
}

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
// Creates a writable copy of the bundled default database in the application Documents directory.
//*********************************************************************************************************************************************
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"database.sqlite"];
	NSLog(writableDBPath);
	
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"database.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
// Open the database connection and retrieve minimal information for all objects.
//*********************************************************************************************************************************************
- (void)initDatabase {
    //NSMutableArray *bookArray = [[NSMutableArray alloc] init];
    //self.books = bookArray;
    //[bookArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"database.sqlite"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for all books.
        const char *sql = "SELECT * FROM Profile";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
            if (sqlite3_step(statement) == SQLITE_ROW) {
				user = [[UserProfile alloc] initWithIID: sqlite3_column_int(statement, IID_COL)];
				user.name =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, NAME_COL)];
				user.email = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, EMAIL_COL)];
				user.gender = sqlite3_column_int(statement, GENDER_COL);
				user.monday = sqlite3_column_int(statement, MONDAY_COL);
				user.tuesday = sqlite3_column_int(statement, TUESDAY_COL);
				user.wednesday = sqlite3_column_int(statement, WEDNESDAY_COL);
				user.thursday = sqlite3_column_int(statement, THURSDAY_COL);
				user.friday = sqlite3_column_int(statement, FRIDAY_COL);
				user.saturday = sqlite3_column_int(statement, SATURDAY_COL );
				user.sunday = sqlite3_column_int(statement, SUNDAY_COL );
				workingDays = [[NSArray alloc] initWithObjects: ([NSNumber numberWithInt:user.sunday]),
							   ([NSNumber numberWithInt: user.monday]), 
							   ([NSNumber numberWithInt:user.tuesday]), 
							   ([NSNumber numberWithInt:user.wednesday]), 
							   [NSNumber numberWithInt:user.thursday], 
							   ([NSNumber numberWithInt:user.friday]),
							   ([NSNumber numberWithInt:user.saturday]), 
							    nil];
				user.weight = sqlite3_column_int(statement, WEIGHT_COL);
				user.height = sqlite3_column_int(statement, HEIGHT_COL);
				user.goal = sqlite3_column_int(statement, GOAL_COL);
				user.complexity = sqlite3_column_int(statement, COMPLEXITY_COL );
				user.program = sqlite3_column_int(statement, PROGRAM_COL);
				user.dietPlan = sqlite3_column_int(statement, DIETPLAN_COL);
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}
//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
// Check if there is user
//*********************************************************************************************************************************************

- (NSInteger) dateToInteger: (NSDate*) date {
	NSInteger result;
	result = [[inputFormatter stringFromDate:date] intValue]; 
	return result;
}
//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
// Check if there is user
//*********************************************************************************************************************************************

- (bool) isRegistered {
	if (user) return YES;
	else {
		return NO;
	}
}


//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	Get available training
//*********************************************************************************************************************************************

- (NSArray*) getTraining {
	//if (!user) return nil;
	
	// init array result 
	NSMutableArray *array = [[NSMutableArray alloc ] initWithObjects:@" ", nil];
	
	// check statement 
	if (!get_training) {
		const char *sql = "SELECT ConditionName FROM 'ConditionType'";
		NSLog([NSString stringWithCString:sql]);
		if (sqlite3_prepare_v2(database, sql, -1, &get_training, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	// parsing result
	while (sqlite3_step(get_training) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		NSString * conditionName;
		conditionName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(get_training, 0)];
		[array addObject:conditionName];
		//[conditionName release];
	}
	
	
	// Reset the query for the next use.
	sqlite3_reset(get_training);
	// Handle errors.
	if ([array count] < 1) {
		NSLog(@"Database is empty");
		//NSAssert1(0, @"Error: '%s' or database is empty.", sqlite3_errmsg(database));
	}
	// Update the object state with respect to unwritten changes.
	return [array retain];
}


//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	Get available Goals
//*********************************************************************************************************************************************

- (NSArray*) getGoal {
	//if (!user) return nil;
	
	// init array result 
	NSMutableArray *array = [[NSMutableArray alloc ] initWithObjects:@" ", nil];
	
	// check statement 
	if (!get_goal) {
		const char *sql = "SELECT ProgramName FROM 'Program'";
		NSLog([NSString stringWithCString:sql]);
		if (sqlite3_prepare_v2(database, sql, -1, &get_goal, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	// parsing result
	while (sqlite3_step(get_goal) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		NSString * goalName;
		goalName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(get_goal, 0)];
		[array addObject:goalName];
		//[goalName release];
	}
	
	
	// Reset the query for the next use.
	sqlite3_reset(get_goal);
	// Handle errors.
	if ([array count] < 1) {
		NSLog(@"Database is empty");
		//NSAssert1(0, @"Error: '%s' or database is empty.", sqlite3_errmsg(database));
	}
	// Update the object state with respect to unwritten changes.
	return [array retain];
}


//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
// register user
////*********************************************************************************************************************************************
- (bool) registerUser: (UserProfile*) newUser withComplex: (NSString*) complexity andGoal: (NSString*) goal andDays:(NSInteger)days {
	
	if (!get_program_with_goal_and_complexity_statement) {
		static char* sql2 = "SELECT ProgramID FROM Programs WHERE ((Days = ?) AND (ConditionID IN (SELECT ConditionID FROM ConditionType WHERE ConditionName = ?)) AND (ProgramTypeID IN (SELECT ProgramTypeID FROM Program WHERE ProgramName = ?))) LIMIT 1";
		if (sqlite3_prepare_v2(database, sql2, -1, &get_program_with_goal_and_complexity_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return FALSE;
		}
	}
	
	sqlite3_bind_int(get_program_with_goal_and_complexity_statement, 1, days);
	sqlite3_bind_text(get_program_with_goal_and_complexity_statement, 2,[complexity UTF8String], -1, SQLITE_TRANSIENT) ;
	sqlite3_bind_text(get_program_with_goal_and_complexity_statement, 3,[goal UTF8String], -1, SQLITE_TRANSIENT) ;
	
	// Execute the query.
	if (sqlite3_step(get_program_with_goal_and_complexity_statement) == SQLITE_ROW) {
		int key = sqlite3_column_int(get_program_with_goal_and_complexity_statement, 0);
		//NSLog(@"Program %d querried, updating profile.", key);
		newUser.program = key;
	} else return FALSE;
	
	// Reset the query for the next use.
	sqlite3_reset(get_program_with_goal_and_complexity_statement);
	
	if(!newUser) return NO;
	if (user ) {
		if (!update_user_statement) {
			static char* sql = "UPDATE Profile SET 'Name' = ?, 'Email' = ?, 'Monday' = ?, 'Tuesday' = ? , 'Wednesday' = ?, 'Thursday' = ?, 'Friday' = ?, 'Saturday' = ?, 'Sunday' = ?, 'Weight' = ?, 'Height'= ?, 'Gender' = ?, 'Program' = ?";
			if (sqlite3_prepare_v2(database, sql, -1, &update_user_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		[user release];
		
		user = newUser;
		sqlite3_bind_text(update_user_statement, 1, [user.name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_user_statement, 2, [user.email UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_user_statement, 3, user.monday);
		sqlite3_bind_int(update_user_statement, 4, user.tuesday);
		sqlite3_bind_int(update_user_statement, 5, user.wednesday);
		sqlite3_bind_int(update_user_statement, 6, user.thursday);
		sqlite3_bind_int(update_user_statement, 7, user.friday);
		sqlite3_bind_int(update_user_statement, 8, user.saturday);
		sqlite3_bind_int(update_user_statement, 9, user.sunday);
		sqlite3_bind_int(update_user_statement, 10, user.weight);
		sqlite3_bind_int(update_user_statement, 11, user.height);
		sqlite3_bind_int(update_user_statement, 12, user.gender);
		sqlite3_bind_int(update_user_statement, 13, user.program);
		//sqlite3_bind_int(update_user_statement, 14, user);
		workingDays = [[NSArray alloc] initWithObjects: ([NSNumber numberWithInt:user.sunday]),
					   ([NSNumber numberWithInt: user.monday]), 
					   ([NSNumber numberWithInt:user.tuesday]), 
					   ([NSNumber numberWithInt:user.wednesday]), 
					   [NSNumber numberWithInt:user.thursday], 
					   ([NSNumber numberWithInt:user.friday]),
					   ([NSNumber numberWithInt:user.saturday]), 
					    nil];

        // Execute the query.
        int success = sqlite3_step(update_user_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_user_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
			return FALSE;
        }
        // Update the object state with respect to unwritten changes.
        else {
			return TRUE;
		}
    } else {
		user = newUser;
		if (!register_statement) {
			static char* sql = "INSERT INTO Profile('IID','Name','Email','Gender','TimeID','Monday', 'Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday','Weight','Height', 'Program') VALUES (?, ?, ? , ?, ?,?,?,?,?,?,?,?,?,?,?)";
			if (sqlite3_prepare_v2(database, sql, -1, &register_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_bind_int(register_statement, 1, user.iid);
		sqlite3_bind_text(register_statement, 2, [user.name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(register_statement, 3, [user.email UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(register_statement, 4, user.gender);

		if (!user.date)  {
			sqlite3_bind_text(register_statement, 5, [[NSString stringWithString:@"DATE('now')"] UTF8String], -1, SQLITE_TRANSIENT);
		}
		else  {
			sqlite3_bind_text (register_statement, 5, [[user.date description] UTF8String], -1, SQLITE_TRANSIENT);
		}
		
		sqlite3_bind_int(register_statement, 6, user.monday);
		sqlite3_bind_int(register_statement, 7, user.tuesday);
		sqlite3_bind_int(register_statement, 8, user.wednesday);
		sqlite3_bind_int(register_statement, 9, user.thursday);
		sqlite3_bind_int(register_statement, 10, user.friday);
		sqlite3_bind_int(register_statement, 11, user.saturday);
		sqlite3_bind_int(register_statement, 12, user.sunday);
		sqlite3_bind_int(register_statement, 13, user.weight);
		sqlite3_bind_int(register_statement, 14, user.height);
		sqlite3_bind_int(register_statement, 15, user.program);
		workingDays = [[NSArray alloc] initWithObjects: ([NSNumber numberWithInt:user.sunday]),
					   ([NSNumber numberWithInt: user.monday]), 
					   ([NSNumber numberWithInt:user.tuesday]), 
					   ([NSNumber numberWithInt:user.wednesday]), 
					   [NSNumber numberWithInt:user.thursday], 
					   ([NSNumber numberWithInt:user.friday]),
					   ([NSNumber numberWithInt:user.saturday]), 
					    nil];
        // Execute the query.
		int success = sqlite3_step(register_statement);
		// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
		sqlite3_reset(register_statement);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
			return NO;
		} else {
			return YES;
		}
		
	}
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    // if dehydrate is called multiple times.

}


//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	register training program
//*********************************************************************************************************************************************

- (bool) registerTrainingProgramWithComplexity: (NSString*) complexity trainingGoal: (NSString*) goal andDays: (NSInteger) days {
	BOOL result = FALSE;
	if (!register_program_statement) {
		static char* sql = "UPDATE Profile SET Program= ?";
		if (sqlite3_prepare_v2(database, sql, -1, &register_program_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return result;
		}
	}
	
	if (!get_program_with_goal_and_complexity_statement) {
		static char* sql2 = "SELECT ProgramID FROM Programs WHERE ((Days = ?) AND (ConditionID IN (SELECT ConditionID FROM ConditionType WHERE ConditionName = ?)) AND (ProgramTypeID IN (SELECT ProgramTypeID FROM Program WHERE ProgramName = ?))) LIMIT 1";
		if (sqlite3_prepare_v2(database, sql2, -1, &get_program_with_goal_and_complexity_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return result;
		}
	}
	
	sqlite3_bind_int(get_program_with_goal_and_complexity_statement, 1, days);
	sqlite3_bind_text(get_program_with_goal_and_complexity_statement, 2,[complexity UTF8String], -1, SQLITE_TRANSIENT) ;
	sqlite3_bind_text(get_program_with_goal_and_complexity_statement, 3,[goal UTF8String], -1, SQLITE_TRANSIENT) ;

	// Execute the query.
	if (sqlite3_step(get_program_with_goal_and_complexity_statement) == SQLITE_ROW) {
		int key = sqlite3_column_int(get_program_with_goal_and_complexity_statement, 0);
		NSLog(@"Program %d querried, updating profile.", key);
		user.program = key;
		sqlite3_bind_int(register_program_statement, 1, key);
		if (sqlite3_step(register_program_statement) == SQLITE_DONE) {
			NSLog(@"Program registered.");
			result = TRUE;
		}
	}
	
	// Reset the query for the next use.
	sqlite3_reset(get_program_with_goal_and_complexity_statement);
	sqlite3_reset(register_program_statement);
	
	// Update the object state with respect to unwritten changes.
	return result;
	
}

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	Get Workout detail at time
//*********************************************************************************************************************************************

- (NSArray*) getWorkOutDetailAtTime: (NSDate*) time  {
	if (!user) return nil;
	
	// init array result 
	NSMutableArray *array = [[NSMutableArray array ] init];
	//NSMutableArray *workoutProgress = [[NSMutableArray array] init];
	char* sql;
	// init the calendar
	static const unsigned unitFlags = NSWeekdayCalendarUnit;
	if (!gregorian) gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
	NSDateComponents *weekdayComponents =
    [gregorian components:unitFlags fromDate:time];
	int weekday = [weekdayComponents weekday]-1; // get which day is the current day, SUNDAY = 1
	
	// QUERRYING FOR WORKOUT PROGRESS AT THE GIVEN TIME
	// check if current day have workout program created or not
	if (!get_progress_for_day_statement) {
		//if (sql) 
		sql = "SELECT ProgressID FROM WorkoutProgress WHERE Time = ? LIMIT 1";
		if (sqlite3_prepare_v2(database, sql, -1, &get_progress_for_day_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	NSDate *date;
	if (!time) {
		date = [NSDate date];
		NSLog(@" Date is null, load current time");
	}
	else date = time;
	
	NSInteger convertedTime = [self dateToInteger:date];
	
	NSLog([NSString stringWithFormat:@"Querrying database for: %d", convertedTime] );
	//NSLog([date description]);
	// binding into sql statement
	sqlite3_bind_int(get_progress_for_day_statement, 1 ,convertedTime);
	
	
	// check if there are progresses saved for given time
	if (sqlite3_step(get_progress_for_day_statement) != SQLITE_ROW) {
		// if there is no working progress for given day and the given day is the defined day
		// we create progress item and load them into result array
		// check if today is working day and it is not in the past
		NSInteger currentDay = [self dateToInteger:[NSDate date]];
		if ([[workingDays objectAtIndex:weekday] intValue] &&( currentDay <= convertedTime)) {
			
			// which working day position is this
			int numberOfWorkingDayFromSunday = [self countWorkingDays:weekday];
			// create statement 
			if (!get_program_for_workout_and_work_day_statement) {
				sql = "SELECT ID FROM ProgramDescription WHERE ProgramID = ? AND DayOfWeek = ? ORDER BY 'Order'";
				if (sqlite3_prepare_v2(database, sql, -1, &get_program_for_workout_and_work_day_statement, NULL) != SQLITE_OK) {
					NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
				}
			}
			
			if (!get_series_with_description_statement) {
				sql = "SELECT ID FROM Series WHERE DescriptionID =? ORDER BY 'SOrder'";
				if (sqlite3_prepare_v2(database, sql, -1, &get_series_with_description_statement, NULL) != SQLITE_OK) {
					NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
				}
			}
			
			if (!create_workout_progress_statement) {
				sql = "INSERT INTO WorkoutProgress ('Time', 'Status', 'SeriID') VALUES (?, 0, ?)";
				if (sqlite3_prepare_v2(database, sql, -1, &create_workout_progress_statement, NULL) != SQLITE_OK) {
					NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
				}
			}
			
			// binding data to statement
			sqlite3_bind_int(get_program_for_workout_and_work_day_statement, 1, user.program);
			sqlite3_bind_int(get_program_for_workout_and_work_day_statement, 2, numberOfWorkingDayFromSunday);
			
			// parsing all workout at current date
			if (sqlite3_step(get_program_for_workout_and_work_day_statement) == SQLITE_ROW) {
				do {
					// get the ID for getting series
					int primaryProgramDescription = sqlite3_column_int(get_program_for_workout_and_work_day_statement, 0);
					sqlite3_bind_int(get_series_with_description_statement, 1, primaryProgramDescription);
				
					while (sqlite3_step(get_series_with_description_statement)== SQLITE_ROW) {
						int key = sqlite3_column_int(get_series_with_description_statement, 0);
						sqlite3_bind_int(create_workout_progress_statement, 1, convertedTime);
						sqlite3_bind_int(create_workout_progress_statement, 2, key);
						if (sqlite3_step(create_workout_progress_statement) == SQLITE_DONE) {
							NSLog(@"Created workout progress for serie %d", key);
						}
						sqlite3_reset(create_workout_progress_statement);
					}
					sqlite3_reset(get_series_with_description_statement);
				} while (sqlite3_step(get_program_for_workout_and_work_day_statement) == SQLITE_ROW);
			} else {
				sqlite3_reset(get_program_for_workout_and_work_day_statement);
				NSInteger dayToQuery;
				static const unsigned dateComponentFlags = NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit;
				NSInteger dayOfGivenTime = [[gregorian components:dateComponentFlags fromDate:date] day];
				NSInteger monthOfGivenTime = [[gregorian components:dateComponentFlags fromDate:date] month];
				//NSInteger yearOfGivenTime = [[gregorian components:dateComponentFlags fromDate:date] year];
				if ((dayOfGivenTime < 7)) {
					dayToQuery = (monthOfGivenTime %2) ? 1 : 2;
				} else dayToQuery = (dayOfGivenTime %2)? 1: 2;
				
				sqlite3_bind_int(get_program_for_workout_and_work_day_statement, 1, user.program);
				sqlite3_bind_int(get_program_for_workout_and_work_day_statement, 2, dayToQuery);
				if (sqlite3_step(get_program_for_workout_and_work_day_statement) == SQLITE_ROW) {
					do {
						// get the ID for getting series
						int primaryProgramDescription = sqlite3_column_int(get_program_for_workout_and_work_day_statement, 0);
						sqlite3_bind_int(get_series_with_description_statement, 1, primaryProgramDescription);
						
						while (sqlite3_step(get_series_with_description_statement)== SQLITE_ROW) {
							int key = sqlite3_column_int(get_series_with_description_statement, 0);
							sqlite3_bind_int(create_workout_progress_statement, 1, convertedTime);
							sqlite3_bind_int(create_workout_progress_statement, 2, key);
							if (sqlite3_step(create_workout_progress_statement) == SQLITE_DONE) {
								NSLog(@"Created workout progress for serie %d", key);
							}
							sqlite3_reset(create_workout_progress_statement);
						}
						sqlite3_reset(get_series_with_description_statement);
					} while (sqlite3_step(get_program_for_workout_and_work_day_statement) == SQLITE_ROW);
					
				}
			}
			sqlite3_reset(get_program_for_workout_and_work_day_statement);
			
		}	
		
		
	}
	
	
		// now, we have working progress for current day
		// create temp view for Series of given time
		if (!create_series_view_statement) {
			const char* newsql = [[NSString stringWithFormat:@"CREATE  VIEW IF NOT EXISTS SeriesView AS SELECT * FROM 'Series','WorkoutProgress' WHERE ('WorkoutProgress'.Time = %d) AND (WorkoutProgress.SeriID = Series.ID)", convertedTime] cStringUsingEncoding:NSASCIIStringEncoding];
			if (sqlite3_prepare_v2(database, newsql, -1, &create_series_view_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		//sqlite3_bind_int(create_series_view_statement, 1, convertedTime);
		// if success then display message
		if (sqlite3_step(create_series_view_statement) == SQLITE_DONE) {
			NSLog(@"Series view created successfully!");
			sqlite3_finalize(create_series_view_statement);
			create_series_view_statement = nil;
		} else NSLog(@"SeriesView failed to be created!" );
		
		// then get workouts information for given time
		if (!get_workouts_for_date_statement) {
			sql = " SELECT  PD.'ID', PD.'DayOfWeek', PD.'Order', TEMP.* FROM ProgramDescription AS PD, (SELECT W.'WorkoutID', W.'WorkoutName', W.'Preparation', W.'Execution', W.'Comment', W.'Display', TG.'GroupName' FROM Workout AS W, TrainingGroup AS TG WHERE W.TrainingGroupID = TG.GroupID) AS TEMP WHERE PD.WorkoutID = TEMP.WorkoutID AND PD.ID IN (SELECT DescriptionID FROM SeriesView ) ORDER BY PD.'ProgramID', PD.'DayOfWeek', PD.'Order' ASC ";
			if (sqlite3_prepare_v2(database, sql, -1, &get_workouts_for_date_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		// parsing result 
		while (sqlite3_step(get_workouts_for_date_statement) == SQLITE_ROW) {
			int programID = sqlite3_column_int(get_workouts_for_date_statement, 0);
			int workoutID = sqlite3_column_int(get_workouts_for_date_statement, 3);
			WorkoutDetail *detail = [[WorkoutDetail alloc] initWithWorkoutID:workoutID descriptionID:programID];
			detail.dayOfWeek = sqlite3_column_int(get_workouts_for_date_statement, 1);
			detail.order = sqlite3_column_int(get_workouts_for_date_statement, 2);
			detail.name = [self UTF8CStringNotNull: (id)sqlite3_column_text(get_workouts_for_date_statement, 4)];
			detail.preparation = [self UTF8CStringNotNull: (id)  sqlite3_column_text(get_workouts_for_date_statement, 5)];
			detail.execution = [self UTF8CStringNotNull: (id)sqlite3_column_text(get_workouts_for_date_statement, 6)];
			detail.comment =  [self UTF8CStringNotNull:  (id)sqlite3_column_text(get_workouts_for_date_statement, 7)];
			detail.display = sqlite3_column_int(get_workouts_for_date_statement, 8);
			detail.group = [self UTF8CStringNotNull: (id)sqlite3_column_text(get_workouts_for_date_statement, 9)];
			[array addObject:detail];
			[detail release];
		}
		
		// get workout series for each workout 
		if (!get_series_for_workout_statement) {
			sql = "SELECT * FROM SeriesView WHERE DescriptionID = ? ORDER BY 'SOrder'";
			if (sqlite3_prepare_v2(database, sql, -1, &get_series_for_workout_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		// parsing series 
		int i ;
		WorkoutDetail *tempDetail;
		
		for (i = 0 ;  i < [array count]; i ++ ) {
			NSMutableArray *seriesArray = [[NSMutableArray alloc] init];
			
			tempDetail = [array objectAtIndex:i];
			sqlite3_bind_int(get_series_for_workout_statement, 1, tempDetail.descriptionID);
			while (sqlite3_step(get_series_for_workout_statement) == SQLITE_ROW) {
				// create new series objects
				Series * seriItem = [[Series alloc] initWithIID:sqlite3_column_int(get_series_for_workout_statement, 0)];
				seriItem.order = sqlite3_column_int(get_series_for_workout_statement, 2);
				seriItem.repeat = sqlite3_column_int(get_series_for_workout_statement, 3);
				seriItem.strength = sqlite3_column_int(get_series_for_workout_statement, 4);
				seriItem.progressID = sqlite3_column_int(get_series_for_workout_statement, 5);
				seriItem.status = sqlite3_column_int(get_series_for_workout_statement, 7);
				[seriesArray addObject:seriItem];
				[seriItem release];
			}
			[tempDetail updateStatus:seriesArray];
			//[seriesArray release];
			sqlite3_reset(get_series_for_workout_statement);
		}
	
		// clear view
		if (!drop_series_view) {
			sql = "DROP VIEW IF EXISTS SeriesView ";
			if (sqlite3_prepare_v2(database, sql, -1, &drop_series_view, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_step(drop_series_view);
	
		// reset current statement
	sqlite3_reset(drop_series_view);
	sqlite3_reset(get_program_for_workout_and_work_day_statement);
	sqlite3_reset(get_workouts_for_date_statement);
	//sqlite3_reset(create_series_view_statement);
	sqlite3_reset(get_progress_for_day_statement);
	//[weekdayComponents release];
	return [array retain];
}

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	Release memory
//*********************************************************************************************************************************************

- (void) dealloc {
	NSLog(@"Databased deallocated");
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	//sqlite3_close(database)
	[user release];
	[super dealloc];
}


//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	Get images for workout
//*********************************************************************************************************************************************

- (NSArray*) getImagesForWorkoutID: (NSInteger) workoutID {
	
	if (!user) return nil;
	//NSMutableArray *imageArray = [[NSMutableArray alloc] init];
	
	if (!get_image_for_workout_statement) {
		const char*sql = "SELECT * FROM 'Picture' WHERE IID = ? LIMIT 1";
		if (sqlite3_prepare_v2(database, sql, -1, &get_image_for_workout_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	
	sqlite3_bind_int(get_image_for_workout_statement, 1, workoutID);
	if (sqlite3_step(get_image_for_workout_statement) == SQLITE_ROW) {
		NSData * data= [NSData dataWithBytes:sqlite3_column_blob(get_image_for_workout_statement, 1) length:sqlite3_column_bytes(get_image_for_workout_statement, 1)];
		//NSLog([NSString stringWithFormat:@"Querying for image: %d, %d", [[instruction objectAtIndex:i] picture]], sqlite3_column_bytes(get_images_for_instruction, 1));
		if(data == nil)
				NSLog(@"No image found.");
		else {
			if (decoder) [decoder release];
				decoder = [[AnimatedGif alloc] init];
			[decoder decodeGIF:data];
			
		}
	}
	//[data autorelease];
	sqlite3_reset(get_image_for_workout_statement);
	return [decoder getAnimatingImages];
}

//*********************************************************************************************************************************************
//*********************************************************************************************************************************************
//	Release memory
//*********************************************************************************************************************************************

- (NSString*) UTF8CStringNotNull: (id) inputString {
	if (inputString) {
		return [NSString stringWithUTF8String:(char*) inputString];
	}
	else return nil;
}

- (BOOL) updateProgressOfSeri:(Series*) seri  {
	NSLog(@"DATABASE: Updating progress for ProgressID %d", seri.progressID);
	// create an update statement
	if (!update_seri_progress_statement) {
		static const char* sql = "UPDATE WorkoutProgress SET Status = ? WHERE ProgressID = ?" ;
		if (sqlite3_prepare_v2(database, sql, -1, &update_seri_progress_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	// binding int into statement
	sqlite3_bind_int(update_seri_progress_statement, 1, [seri status]);
	sqlite3_bind_int(update_seri_progress_statement, 2, [seri progressID]);
	
	// check if succeeded
	int success = sqlite3_step(update_seri_progress_statement);
	
	// reset statement
	sqlite3_reset(update_seri_progress_statement);
	if (success ==  SQLITE_DONE) {
		return TRUE;
	}
	else  {
		return FALSE;	
	}
}

- (BOOL) updateProgressOfSeries: (NSArray*) series {
	NSLog(@"DATABASE: Update progress for array of series");

	for (int i = 0; i< [series count]; i++) {
		if (! [self updateProgressOfSeri: [series objectAtIndex:i]]) 
			return FALSE;
	}
	return TRUE;
}

- (NSArray*) getSeriesStatusForMonth: (NSInteger) month andYear: (NSInteger) year{
	char* sql;
	NSMutableArray *result = [[NSMutableArray alloc] init];
	NSInteger dateFrom = year * 10000 + month * 100 ;
	NSInteger dateTo = year * 10000 + month * 100 + 32; 
	// now, we have working progress for current day
	// create temp view for Series of given time
	if (!create_series_view_for_month_statement) {
		const char* newsql = [[NSString stringWithFormat:@"CREATE  VIEW IF NOT EXISTS SeriesViewForMonth AS SELECT * FROM 'Series','WorkoutProgress' WHERE ('WorkoutProgress'.'Time' > %d) AND ('WorkoutProgress'.'Time' < %d ) AND ('WorkoutProgress'.'SeriID' = 'Series'.'ID')", dateFrom, dateTo] cStringUsingEncoding:NSASCIIStringEncoding];
		if (sqlite3_prepare_v2(database, newsql, -1, &create_series_view_for_month_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
		//NSLog(@"DATABASE: sql created '%s'", newsql);
	}

	//sqlite3_bind_int(create_series_view_statement, 1, convertedTime);
	// if success then display message
	if (sqlite3_step(create_series_view_for_month_statement) == SQLITE_DONE) {
		NSLog(@"DATABASE: Series view created successfully!");
		sqlite3_finalize(create_series_view_for_month_statement);
		create_series_view_for_month_statement = nil;
		
		// allocate days that have workout available
		if (!get_available_day_statement) {
			sql = "SELECT DISTINCT(Time) FROM SeriesViewForMonth";
			if (sqlite3_prepare_v2(database, sql, -1, &get_available_day_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		if (!get_all_progress_for_day_statement) {
			sql = "SELECT COUNT(ProgressID) FROM SeriesViewForMonth WHERE Time = ?";
			if (sqlite3_prepare_v2(database, sql, -1, &get_all_progress_for_day_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		if (!get_all_done_progress_for_day_statement) {
			sql = "SELECT COUNT(ProgressID) FROM SeriesViewForMonth WHERE Time = ? AND Status != 0 ";
			if (sqlite3_prepare_v2(database, sql, -1, &get_all_done_progress_for_day_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
			
		}
		// fetching database 
		while (sqlite3_step(get_available_day_statement) == SQLITE_ROW) {
			NSInteger day = sqlite3_column_int(get_available_day_statement, 0);
			
			// get total progress
			sqlite3_bind_int(get_all_progress_for_day_statement, 1, day);
			sqlite3_step(get_all_progress_for_day_statement);
			NSInteger total = sqlite3_column_int(get_all_progress_for_day_statement, 0);
			sqlite3_reset(get_all_progress_for_day_statement);
			
			// get all done progress
			sqlite3_bind_int(get_all_done_progress_for_day_statement, 1, day);
			sqlite3_step(get_all_done_progress_for_day_statement);
			NSInteger totalDone = sqlite3_column_int(get_all_done_progress_for_day_statement, 0);
			sqlite3_reset(get_all_done_progress_for_day_statement);
			// push to array
			DayProgress *newDay  = [[DayProgress alloc ] initWithDay:day withTotal: total andCompleted: totalDone];
			[result addObject:newDay];
			[newDay release];
		}
		
		// clear view
		if (!drop_series_view_for_month) {
			sql = "DROP VIEW IF EXISTS SeriesViewForMonth";
			if (sqlite3_prepare_v2(database, sql, -1, &drop_series_view_for_month, NULL) != SQLITE_OK) {
				NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_step(drop_series_view_for_month);
		sqlite3_reset(drop_series_view_for_month);
	} else NSLog(@"DATABASE: SeriesView failed to be created!" );
	
	//sqlite3_reset(get_all_done_progress_for_day_statement);
	//sqlite3_reset(get_all_progress_for_day_statement);
	
	sqlite3_reset(get_available_day_statement);
	sqlite3_finalize(get_available_day_statement);
	get_available_day_statement = nil;
	return [result retain];
}


// these codes are not for fun

- (void) createSeries {
	/*
	NSInteger programID = 18;
	sqlite3_stmt * create_series_statement = nil;
	char * sql = "INSERT INTO Series(DescriptionID, SOrder, Strength, Repeat) VALUES (?, ? ,? ,? )";
	if (sqlite3_prepare_v2(database, sql, -1, &create_series_statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"DATABASE: Error - failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_stmt * get_description_statemenet  = nil;
	sql = "SELECT ID, WorkoutID FROM ProgramDescription WHERE ProgramID = ?";
	if (sqlite3_prepare_v2(database, sql, -1, &get_description_statemenet, NULL) != SQLITE_OK) {
		NSAssert1(0, @"DATABASE: Error - failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_int(get_description_statemenet, 1, programID);
	while (sqlite3_step(get_description_statemenet) == SQLITE_ROW) {
		NSInteger pKey = sqlite3_column_int(get_description_statemenet, 0);
		NSInteger workoutID = sqlite3_column_int(get_description_statemenet, 1);
		NSInteger numberOfSeries = 3;
		NSInteger repeatOfSeries = 10;
		if ((workoutID == 17) || (workoutID == 34)) {
			numberOfSeries = 1;
		}
		if ((workoutID == 26)) {
			//numberOfSeries = 4;
			repeatOfSeries = 12;
		}
		for (int i = 1; i <= numberOfSeries; i++ ) {
			sqlite3_bind_int(create_series_statement, 1, pKey);
			sqlite3_bind_int(create_series_statement, 2, i);
			sqlite3_bind_int(create_series_statement, 3, i);
			if (workoutID != 26)
				sqlite3_bind_int(create_series_statement, 4, 14- (2*i));
			else 
				sqlite3_bind_int(create_series_statement, 4, repeatOfSeries);
			
			//sqlite3_bind_int(create_series_statement, 4, repeatOfSeries);
			int success = sqlite3_step(create_series_statement);
			if (success != SQLITE_DONE ) {
				NSAssert1(0, @"DATABASE: Error - Can't create series for DescriptionID %s ",sqlite3_errmsg(database));
			}
			sqlite3_reset(create_series_statement);
		}
	}
	sqlite3_finalize(get_description_statemenet);
	sqlite3_finalize(create_series_statement);
	NSLog(@"Finished for program %d", programID);*/
}


- (NSString *) getCurrentGoal {
	NSString * result = nil;
	if (!get_current_goal_statement) {
		const char *sql = "SELECT ProgramName FROM Program WHERE ProgramTypeID IN (SELECT ProgramTypeID FROM Programs WHERE ProgramID = ? LIMIT 1) LIMIT 1";
		if (sqlite3_prepare_v2(database, sql, -1, &get_current_goal_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_bind_int(get_current_goal_statement, 1, user.program);
	
	sqlite3_step(get_current_goal_statement);
	result = [self UTF8CStringNotNull: (id)sqlite3_column_text(get_current_goal_statement, 0)];
	sqlite3_reset(get_current_goal_statement);
	
	return [result retain];
}

- (NSString*) getCurrentTraining{
	NSString * result = nil;
	if (!get_current_training_statement) {
		const char *sql = "SELECT ConditionName FROM ConditionType WHERE ConditionID IN (SELECT ConditionID FROM Programs WHERE ProgramID = ? LIMIT 1) LIMIT 1";
		if (sqlite3_prepare_v2(database, sql, -1, &get_current_training_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
	}
	
	sqlite3_bind_int(get_current_training_statement, 1, user.program);
	
	sqlite3_step(get_current_training_statement);
	result = [self UTF8CStringNotNull: (id)sqlite3_column_text(get_current_training_statement, 0)];
	sqlite3_reset(get_current_training_statement);
	
	return [result retain];
}


- (BOOL) clearAllProgressFromDay: (NSDate*) date {
	BOOL result = FALSE;
	if (!clear_progress_statement) {
		const char *sql = "DELETE FROM WorkoutProgress WHERE Time > ?";
		if (sqlite3_prepare_v2(database, sql, -1, &clear_progress_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	NSInteger dayToClear = [self dateToInteger:date];
	sqlite3_bind_int(clear_progress_statement, 1, dayToClear);
	sqlite3_step(clear_progress_statement);
	result = TRUE;
	return result;
	
}

- (void) ChangeDietPlan: (NSInteger) newPlan {
	if (!change_diet_plan_statement) {
		const char *sql = "UPDATE Profile SET DietPlan=?";
		if (sqlite3_prepare_v2(database, sql, -1, &change_diet_plan_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"DATABASE: Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
	}	
	
	sqlite3_bind_int(change_diet_plan_statement, 1, newPlan);
	sqlite3_step(change_diet_plan_statement);
	user.dietPlan = newPlan;
}

@end
