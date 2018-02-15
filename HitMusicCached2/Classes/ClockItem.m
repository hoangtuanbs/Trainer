
#import "ClockItem.h"


// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement   = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *update_statement = nil;

@implementation ClockItem
@synthesize list_category_id, no, database, isActiveItem;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (update_statement) sqlite3_finalize(update_statement);
}

- (id)initWithListCategoryId:(NSInteger)listCategoryId withDatabase:(sqlite3 *)db withRotationNo:(NSInteger)rotationNo markActive:(bool)active
	{
    if (self = [super init]) {
		self.database				= db;
		self.no						= rotationNo;
		self.list_category_id		= listCategoryId;
		self.isActiveItem			= active;
	}
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    self.database = db;
	
    if (insert_statement == nil) {
		
        static char *sql = "INSERT INTO clocks (list_category_id, no) VALUES(?,?)";
		
		if (sqlite3_prepare_v2(self.database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
			
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.database));
        }
    }
	//NSLog(@"insertIntoDatabase after creation os sql statement");
	sqlite3_bind_int (insert_statement, 1, self.list_category_id);
	sqlite3_bind_int (insert_statement, 2, self.no);
	
	//NSLog(@"insertIntoDatabase gave values to all parameters");	
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
		NSLog(@"insertIntoDatabase success == SQLITE_ERROR");
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(self.database));
    }
	//NSLog(@"Recored inserted to database");
	//primaryKey = sqlite3_last_insert_rowid(database);
}

- (void)dealloc {
    [super dealloc];
}

- (void)deleteFromDatabase:(sqlite3 *)db {
	database = db;
    // Compile the delete statement if needed.
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM clocks WHERE list_category_id = ? and no = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, self.list_category_id);
	sqlite3_bind_int(delete_statement, 2, self.no);
	
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

// Flushes all but the primary key and title out to the database.
- (void)updateClockItem:(sqlite3 *)db {
	self.database = db;
	// Write any changes to the database.
	// First, if needed, compile the update query
	if (update_statement == nil) {
		const char *sql = "UPDATE clocks SET list_category_id = ?, no = ? WHERE list_category_id = ? and no = ?";
		if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	// Bind the query variables.

	sqlite3_bind_int(update_statement,		1,	self.list_category_id);
	sqlite3_bind_int(update_statement,		2,	self.no);
	sqlite3_bind_int(update_statement,		3,	self.list_category_id);
	sqlite3_bind_int(update_statement,		4,	self.no);	
	
	// Execute the query.
	int success = sqlite3_step(update_statement);
	// Reset the query for the next use.
	sqlite3_reset(update_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to update with message '%s'.", sqlite3_errmsg(database));
	}
}
@end

