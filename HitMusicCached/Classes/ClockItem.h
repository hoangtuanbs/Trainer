//
//  ClockItem.h
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/27/08.
//  Copyright 2008 Wavem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ClockItem : NSObject {
    sqlite3		*database;
	NSInteger	list_category_id;
	NSInteger	no;						// oder number of the playlist inside clock
	bool		isActiveItem;				// if this item is inserted or updated then it is active in the system, otherwise delete it.
}

@property (assign, nonatomic)			NSInteger	no;
@property ( assign, nonatomic)			NSInteger	list_category_id;
@property (nonatomic)					sqlite3		*database;
@property (nonatomic)					bool		isActiveItem;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object
- (id)initWithListCategoryId:(NSInteger)listCategoryId withDatabase:(sqlite3 *)db withRotationNo:(NSInteger)rotationNo markActive:(bool)active;

// Inserts the mediaItem into the database and stores its primary key.
- (void)insertIntoDatabase:(sqlite3 *)db;

- (void)updateClockItem:(sqlite3 *)db;

// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase:(sqlite3 *)db;


@end

