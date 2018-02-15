
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
@synthesize    database, primaryKey, hour, objectId, mediaId, type, coverObjectId, coverMediaId, title;
@synthesize    artist, album, mediaDuration, posStart, posFadeIn, posChain, posFadeOut, posEnd, image_handle;
@synthesize    audio_handle, audio_downloaded, image_downloaded, isActiveItem, isAddedToDownloadQueue, coverUrl, image_source, audio_source;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (update_statement) sqlite3_finalize(update_statement);
}

// Creates the object with primary key and title is brought into memory.
//- (id)initWithPrimaryKey:(NSInteger)pk withDatabase:(sqlite3 *)db withHandle:(NSString *)handl withAudioName:(NSString *)audioNam withArtistName:(NSString*)artistNam
//	  withlistCategoryId:(NSInteger)categoryId withMediaType:(NSInteger)mediaTyp withSeguePoint:(NSInteger)seguePoin withMimeType:(NSString*)mimeTyp
//		 withMediaLength:(NSInteger)mediaLength withImageHandle:(NSString *)imageHandl markActive:(BOOL)active {
//    if (self = [super init]) {
//		self.primaryKey			= pk;
//        self.database			= db;
//		self.handle				= handl;
//		self.audio_name			= audioNam;
//		self.artist_name		= artistNam;
//		self.list_category_id	= categoryId;
//		self.media_type			= mediaTyp;
//		self.segue_point		= seguePoin;
//		self.mime_type			= mimeTyp;
//		self.length				= mediaLength;
//		self.image_handle		= imageHandl;
//		self.audio_downloaded	= 0;
//		self.image_downloaded	= 0;
//		self.pop_up_downloaded	= 0;
//		self.isActiveItem		= active;
//		//NSLog(@"from mediaItem init active = %i",active);
//	}
//    return self;
//}

- (id) init {
	if (self = [super init]) {
		return self;
	}
	return self;
}

- (id) newInstance {
	return [[MediaItem alloc] init];
}

- (void)insertIntoDatabase:(sqlite3 *)db {
//	NSLog(@"Inside insert method");
	

    self.database = db;

    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {

        static char *sql = "INSERT INTO media_items ( hour, object_id, media_id, cover_object_id, cover_media_id, title, artist, album, duration, posstart,posfadein, poschain, posfadeout, posend, cover_url, type, image_source, audio_source) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		if (sqlite3_prepare_v2(self.database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {

			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.database));
        }
    }
	
//	sqlite3_bind_int (insert_statement, 1, self.primaryKey);
    sqlite3_bind_text(insert_statement, 1, [self.hour UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int (insert_statement, 2, self.objectId);
	sqlite3_bind_int (insert_statement, 3, self.mediaId);
	sqlite3_bind_int (insert_statement, 4, self.coverObjectId);
	sqlite3_bind_int (insert_statement, 5, self.coverMediaId);
	
	sqlite3_bind_text(insert_statement, 6, [self.title UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 7, [self.artist UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 8, [self.album UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int (insert_statement, 9, self.mediaDuration);
    sqlite3_bind_int (insert_statement, 10, self.posStart);
	sqlite3_bind_int (insert_statement, 11, self.posFadeIn);
	sqlite3_bind_int (insert_statement, 12, self.posChain);
	sqlite3_bind_int (insert_statement, 13, self.posFadeOut);
	sqlite3_bind_int (insert_statement, 14, self.posEnd);
	sqlite3_bind_text(insert_statement, 15, [self.coverUrl UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 16, [self.type UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 17, [self.image_source UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 18, [self.audio_source UTF8String], -1, SQLITE_TRANSIENT);
	
	//NSLog(@"insertIntoDatabase gave values to all parameters");	
    int success = sqlite3_step(insert_statement);
	//	NSLog(@"The record inserted  success is  %i",success);
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
        const char *sql = "DELETE FROM media_items WHERE media_id=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, mediaId);
	
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
	self.database = db;
	// Write any changes to the database.
	// First, if needed, compile the update query
	if (update_statement == nil) {
		const char *sql = "UPDATE media_items SET hour = ?, object_id = ?, cover_object_id = ?, cover_media_id = ?, title = ? , artist = ?, album = ?, duration = ?, posstart = ?, posfadein = ?, poschain = ?, posfadeout = ?, posend = ?, cover_url = ?, type = ?, image_downloaded = ?, audio_downloaded = ?, audio_handle = ?, image_handle = ?, image_source = ?, audio_source = ? WHERE media_id = ? ";
		if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	// Bind the query variables.
//	NSLog(@"The imagehandle is %@ and the audioHandle is %@", self.image_handle, audio_handle);
	//self.image_handle = self.image_handle == nil ? @"cdd" : self.image_handle;
	//self.audio_handle = self.audio_handle == nil ? @"dc" : self.audio_handle;
	
	sqlite3_bind_text(update_statement,		1, [self.hour UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_statement,		2,	self.objectId);
	sqlite3_bind_int(update_statement,		3,	self.coverObjectId);
	sqlite3_bind_int(update_statement,		4,	self.coverMediaId);
	sqlite3_bind_text(update_statement,		5, [self.title UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,		6, [self.artist UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,		7, [self.album UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_statement,		8,	self.mediaDuration);
	sqlite3_bind_int(update_statement,		9,	self.posStart);
	sqlite3_bind_int(update_statement,		10,	self.posFadeIn);
	sqlite3_bind_int(update_statement,		11,	self.posChain);
	sqlite3_bind_int(update_statement,		12,	self.posFadeOut);
	sqlite3_bind_int(update_statement,		13,	self.posEnd);
	sqlite3_bind_text(update_statement,		14, [self.coverUrl UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,		15, [self.type UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_statement,		16,	self.image_downloaded);
	sqlite3_bind_int(update_statement,		17,	self.audio_downloaded);

	sqlite3_bind_text(update_statement,		18, [self.audio_handle UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,		19, [self.image_handle UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_text(update_statement,		20, [self.image_source UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,		21, [self.audio_source UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(update_statement,		22,	self.mediaId);	
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

