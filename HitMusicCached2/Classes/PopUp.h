

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface PopUp : NSObject {
    NSInteger	primaryKey;
    NSString	*handle;
	NSInteger	downloaded;
	sqlite3		*database;
	bool		isActiveItem;
}

@property (assign, nonatomic)			NSInteger	primaryKey;
@property (copy, nonatomic)				NSString	*handle;
@property (nonatomic)					sqlite3		*database;
@property (nonatomic)					bool		isActiveItem;
@property (assign, nonatomic)			NSInteger	downloaded;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key 
- (id)initWithPrimaryKey:(NSInteger)pk withHandle:(NSString *)handl withDatabase:(sqlite3 *)db markActive:(bool)active isDownloaded:(bool)download;

// Inserts the mediaItem into the database and stores its primary key.
- (void)insertIntoDatabase:(sqlite3 *)db;

- (void)updatePopUpItem:(sqlite3 *)db;

// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase:(sqlite3 *)db;

@end

