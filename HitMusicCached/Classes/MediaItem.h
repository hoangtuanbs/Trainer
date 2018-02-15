
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface MediaItem : NSObject {
	
    // Opaque reference to the underlying database.
    sqlite3		*database;
    NSInteger	primaryKey;
    NSString	*handle;
	NSString	*audio_name;
	NSString	*artist_name;
	NSInteger	list_category_id;
	NSInteger	media_type;
	NSInteger	segue_point;
	NSString	*lyrics;
	NSString	*mime_type;
	NSInteger	length;
	NSString	*image_handle;
	NSString	*popUpHandle;
	NSInteger	audio_downloaded;
	NSInteger	image_downloaded;
	NSInteger	pop_up_downloaded;
	bool		isActiveItem;
	bool		isAddedToDownloadQueue;
}

@property (assign, nonatomic)			NSInteger	primaryKey;
@property (copy, nonatomic)				NSString	*handle;
@property (copy, nonatomic)				NSString	*audio_name; 
@property (copy, nonatomic)				NSString	*artist_name;
@property ( assign, nonatomic)			NSInteger	list_category_id;
@property (  assign, nonatomic)			NSInteger	media_type;
@property (  assign, nonatomic)			NSInteger	segue_point;
@property (copy, nonatomic)				NSString	*lyrics;
@property (copy, nonatomic)				NSString	*mime_type;
@property ( assign,  nonatomic)			NSInteger	length;
@property ( nonatomic, copy)  		    NSString	*image_handle;
@property ( nonatomic, copy)  		    NSString	*popUpHandle;
@property (nonatomic)					sqlite3		*database;
@property ( assign,  nonatomic)			NSInteger	audio_downloaded;
@property ( assign,  nonatomic)			NSInteger	image_downloaded;
@property ( assign,  nonatomic)			NSInteger	pop_up_downloaded;
@property (nonatomic)					bool		isActiveItem;
@property (nonatomic)					bool		isAddedToDownloadQueue;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key 
- (id)initWithPrimaryKey:(NSInteger)pk withDatabase:(sqlite3 *)db withHandle:(NSString *)handl withAudioName:(NSString *)audioNam withArtistName:(NSString*)artistNam
	  withlistCategoryId:(NSInteger)categoryId withMediaType:(NSInteger)mediaTyp withSeguePoint:(NSInteger)seguePoin withMimeType:(NSString*)mimeTyp
		 withMediaLength:(NSInteger)length withImageHandle:(NSString *)imageHandl markActive:(BOOL)active;

// Inserts the mediaItem into the database and stores its primary key.
- (void)insertIntoDatabase:(sqlite3 *)db;

- (void)updateMediaItem:(sqlite3 *)db;

// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase:(sqlite3 *)db;


@end

