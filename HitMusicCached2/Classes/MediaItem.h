
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface MediaItem : NSObject {
	
    // Opaque reference to the underlying database.
    sqlite3		*database;
    NSInteger	primaryKey;
	NSString	*hour;
	NSInteger	objectId;
	NSInteger	mediaId;
	NSString	*type;
	NSInteger	coverObjectId;
	NSInteger	coverMediaId;
	NSString	*coverUrl;
	NSString	*title;
	NSString	*artist;
	NSString	*album;
	NSInteger	mediaDuration;
	NSInteger	posStart;
	NSInteger	posFadeIn;
	NSInteger	posChain;
	NSInteger	posFadeOut;
	NSInteger	posEnd;
	NSString	*image_handle;
	NSString	*audio_handle;
	NSString	*audio_source;
	NSString	*image_source;
	NSInteger	audio_downloaded;
	NSInteger	image_downloaded;
	bool		isActiveItem;
	bool		isAddedToDownloadQueue;
}

@property (nonatomic)					sqlite3		*database;
@property (assign, nonatomic)			NSInteger	primaryKey;
@property ( nonatomic, copy)			NSString	*hour;
@property ( assign,  nonatomic)			NSInteger	objectId;
@property ( assign,  nonatomic)			NSInteger	mediaId;
@property ( nonatomic, copy)			NSString	*type;
@property ( nonatomic, nonatomic)		NSInteger	coverObjectId;
@property ( nonatomic, nonatomic)		NSInteger	coverMediaId;
@property ( nonatomic, copy)			NSString	*coverUrl;
@property ( nonatomic, copy)			NSString	*title;
@property ( nonatomic, copy)			NSString	*artist;
@property ( nonatomic, copy)			NSString	*album;
@property ( assign,  nonatomic)			NSInteger	mediaDuration;
@property ( assign,  nonatomic)			NSInteger	posStart;
@property ( assign,  nonatomic)			NSInteger	posFadeIn;
@property ( assign,  nonatomic)			NSInteger	posChain;
@property ( assign,  nonatomic)			NSInteger	posFadeOut;
@property ( assign,  nonatomic)			NSInteger	posEnd;
@property ( nonatomic, copy)			NSString	*image_handle;
@property ( nonatomic, copy)			NSString	*audio_handle;
@property ( nonatomic, copy)			NSString	*audio_source;
@property ( nonatomic, copy)			NSString	*image_source;
@property ( assign,  nonatomic)			NSInteger	audio_downloaded;
@property ( assign,  nonatomic)			NSInteger	image_downloaded;
@property (nonatomic)					bool		isActiveItem;
@property (nonatomic)					bool		isAddedToDownloadQueue;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;
- (id) newInstance;
// Creates the object with primary key 
//- (id)initWithPrimaryKey:(NSInteger)pk withDatabase:(sqlite3 *)db withHour:(NSString *)pHour withObjectId:(NSString *)pObjectId withMediaId:(NSString*)pMediaId
//	  withType:(NSInteger)pType withCoverObjectId:(NSInteger)pCoverObjectId withCoverMediaId:(NSInteger)pCoverMediaId withTitle:(NSString*)pTitle
//			  withArtist:(NSInteger)pArtist withAlbum:(NSString *)pAlbum withDuration:(NSInteger)pDuration withPosStart:(NSInteger)pPosStart
//		  withpPosFadeIn:(NSInteger)pPosFadeIn withPosChain:(NSInteger)pPosChain withPosFadeOut markActive:(BOOL)active;

// Inserts the mediaItem into the database and stores its primary key.
- (void)insertIntoDatabase:(sqlite3 *)db;

- (void)updateMediaItem:(sqlite3 *)db;

// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase:(sqlite3 *)db;


@end

