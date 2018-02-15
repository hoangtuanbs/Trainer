
#import "MediaItem.h"


// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *update_statement = nil;

@implementation MediaItem
@synthesize primaryKey, handle, audio_name, artist_name, list_category_id, media_type, segue_point;
@synthesize lyrics, mime_type, length, image_handle, database, isActiveItem, popUpHandle, audio_downloaded,image_downloaded,pop_up_downloaded;
@synthesize isAddedToDownloadQueue;


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (update_statement) sqlite3_finalize(update_statement);
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk withDatabase:(sqlite3 *)db withHandle:(NSString *)handl withAudioName:(NSString *)audioNam withArtistName:(NSString*)artistNam
	  withlistCategoryId:(NSInteger)categoryId withMediaType:(NSInteger)mediaTyp withSeguePoint:(NSInteger)seguePoin withMimeType:(NSString*)mimeTyp
		 withMediaLength:(NSInteger)mediaLength withImageHandle:(NSString *)imageHandl markActive:(BOOL)active {
    if (self = [super init]) {
		self.primaryKey			= pk;
        self.database			= db;
		self.handle				= handl;
		self.audio_name			= audioNam;
		self.artist_name		= artistNam;
		self.list_category_id	= categoryId;
		self.media_type			= mediaTyp;
		self.segue_point		= seguePoin;
		self.mime_type			= mimeTyp;
		self.length				= mediaLength;
		self.image_handle		= imageHandl;
		self.audio_downloaded	= 0;
		self.image_downloaded	= 0;
		self.pop_up_downloaded	= 0;
		self.isActiveItem		= active;
		//NSLog(@"from mediaItem init active = %i",active);
	}
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {


    self.database = db;

    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {

        static char *sql = "INSERT INTO media_item (id, handle, audio_name, artist_name, list_category_id, media_type, segue_point, mime_type,length, image_handle) VALUES(?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2(self.database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {

			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.database));
        }
    }
	//NSLog(@"insertIntoDatabase after creation os sql statement");
	sqlite3_bind_int (insert_statement, 1, self.primaryKey);
    sqlite3_bind_text(insert_statement, 2, [self.handle UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 3, [self.audio_name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 4, [self.artist_name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int (insert_statement, 5, self.list_category_id);
	sqlite3_bind_int (insert_statement, 6, self.media_type);
	sqlite3_bind_int (insert_statement, 7, self.segue_point);
	sqlite3_bind_text(insert_statement, 8, [self.mime_type UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int (insert_statement, 9, self.length);
	sqlite3_bind_text (insert_statement, 10, [self.image_handle UTF8String], -1, SQLITE_TRANSIENT);
	
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
    [self.handle release];
    [self.audio_name release];
    [super dealloc];
}

- (void)deleteFromDatabase:(sqlite3 *)db {
	database = db;
    // Compile the delete statement if needed.
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM media_item WHERE id=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, primaryKey);
	
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
- (void)updateMediaItem:(sqlite3 *)db {
	// NSLog(@"Marking this mediaItem as downloaded on DB and now it's media_handle = %@ and image_handle = %@",  self.handle, self.image_handle);	
	database = db;
        // Write any changes to the database.
        // First, if needed, compile the update query
        if (update_statement == nil) {
			//NSLog(@"MediaItem:UpdateMediaItem: update_statement == nil");
            const char *sql = "UPDATE media_item SET handle=?, audio_name=?, artist_name=?, list_category_id=?, media_type =?, segue_point=?, mime_type=?, length=?, image_handle=? ,  audio_downloaded = ? ,image_downloaded = ?, pop_up_downloaded = ? WHERE id=?";
            if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(update_statement,		1,	[self.handle UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_statement,		2,	[self.audio_name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_statement,		3,	[self.artist_name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_statement,		4,	self.list_category_id);
		sqlite3_bind_int(update_statement,		5,	self.media_type);
		sqlite3_bind_int(update_statement,		6,	self.segue_point);
		sqlite3_bind_text(update_statement,		7,	[self.mime_type UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(update_statement,		8,	self.length);
		sqlite3_bind_text(update_statement,		9,	[self.image_handle UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_statement,		10,	self.audio_downloaded);
		sqlite3_bind_int(update_statement,		11,	self.image_downloaded);
		sqlite3_bind_int(update_statement,		12,	self.pop_up_downloaded);
		sqlite3_bind_int(update_statement,		13, self.primaryKey);

	
        // Execute the query.
        int success = sqlite3_step(update_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to update with message '%s'.", sqlite3_errmsg(database));
        } else {
			//NSLog(@"Record updated successfylle");
		}
}
@end

