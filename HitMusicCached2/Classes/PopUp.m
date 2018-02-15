
#import "PopUp.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *update_statement = nil;

@implementation PopUp
@synthesize primaryKey, handle, database, isActiveItem, downloaded;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (update_statement) sqlite3_finalize(update_statement);
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk withHandle:(NSString *)handl withDatabase:(sqlite3 *)db markActive:(bool)active isDownloaded:(bool)download {
	self.primaryKey			= pk;
	self.handle				= handl;
    self.database			= db;
	self.isActiveItem		= active;
	self.downloaded			= download;
	return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    self.database = db;
	
    if (insert_statement == nil) {
		
        static char *sql = "INSERT INTO pop_ups (id, handle) VALUES(?,?)";
		
		if (sqlite3_prepare_v2(self.database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
			
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.database));
        }
    }
	sqlite3_bind_int (insert_statement, 1, self.primaryKey);
	sqlite3_bind_text(insert_statement, 2, [self.handle UTF8String], -1, SQLITE_TRANSIENT);
	
	int success = sqlite3_step(insert_statement);
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
		NSLog(@"insertIntoDatabase success == SQLITE_ERROR");
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(self.database));
    }
}

- (void)deleteFromDatabase:(sqlite3 *)db {
	database = db;
   if (delete_statement == nil) {
        const char *sql = "DELETE FROM pop_ups WHERE id = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int(delete_statement, 1, self.primaryKey);
	
	int success = sqlite3_step(delete_statement);
    sqlite3_reset(delete_statement);
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)updatePopUpItem:(sqlite3 *)db {
	self.database = db;
	if (update_statement == nil) {
		const char *sql = "UPDATE pop_ups SET handle = ?, downloaded = ?  WHERE id = ?";
		if (sqlite3_prepare_v2(self.database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_text(update_statement,		1, [self.handle UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_statement,		2,	self.downloaded);
	sqlite3_bind_int(update_statement,		3,	self.primaryKey);
	
	int success = sqlite3_step(update_statement);
	sqlite3_reset(update_statement);
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to update with message '%s'.", sqlite3_errmsg(database));
	}
}


- (void)dealloc {
    [self.handle release];
    [super dealloc];
}
@end

