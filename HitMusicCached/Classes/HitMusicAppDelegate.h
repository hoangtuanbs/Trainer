//
//  HitMusicAppDelegate.h
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/8/08.
//  Copyright Wavem 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "InternetFileManager.h"
#import "XMLReader.h"
#import "MainView.h"
#import "Constants.h"
#import "APAudioPlayer.h"
@class MediaItem, PlayList, ClockItem, AVController;

@interface HitMusicAppDelegate : NSObject <UIApplicationDelegate, UITableViewDataSource>{
	NSArray						*radioStationsArray;
    UIWindow					*window;				
	NSMutableArray				*mediaItems;				// List of all songs, ads and IDs
	NSMutableArray				*clockItems;				// List of all clock items
	NSMutableArray				*playLists;					// Keeps track of playLists as well as their status on the clock
	NSMutableArray				*popUpItems;
	NSMutableArray				*songsArray;				// songs array to pass to audio player
	NSMutableArray				*songIndexesArray;			// to keep track of which song is playing on the audioplayer.
	NSMutableArray				*songInfoIndex;
	sqlite3						*database;
	int							readyToPlayMediaCount;		// We sould have more than 3 songs? before allowing foward button or starting to play.
	InternetFileManager			*myFileManager;				// All file management in applications
	NSString					*recordingDirectory;		// Local directory where media is stored
	int							currentClockIndex;			// keeps track of clock item currently playing
	NSURL						*soundFileURL;
	NSURL						*soundFileURL2;
	BOOL						interruptedOnPlayback;
	BOOL						isInternetAvailable;
	int							readyItemsOnPlayList;
	int							currentlyPlayingOnPlayList;
	int							currentSongIndex;			
	int							currentSongId;
	int							currentDownloadIndex;		// to download songs in the same order as the playlist.
	int							playerState;
	int							popUpIndex;					// to keep a record of which pop up to display on the index
	int							secondarViewState;			// this determines the state of the lower view on the main radio GUI
	float						currentVolume;
	IBOutlet					MainView *mainView;
	APAudioPlayer				*avc;
	//AVController				*avc;
	NSTimer						*refreshPlayListTimer,
								*waitAfterSkipClickedTimer,
								*popUpTimer,
								*controllerTimer,
								*fadeOutTimer,
								*changeSecondaryViewTimer;
	BOOL						isPopUpDisplayed;
}

@property (nonatomic, retain)	NSArray				*radioStationsArray;
@property (nonatomic, retain)	IBOutlet UIWindow	*window;
@property (nonatomic, retain)	NSMutableArray		*mediaItems;
@property (nonatomic, retain)	NSMutableArray		*clockItems;
@property (nonatomic, retain)	NSMutableArray		*playLists;
@property (nonatomic, retain)	NSMutableArray		*popUpItems;
@property (nonatomic, retain)	NSMutableArray		*songIndexesArray;	
@property (nonatomic, retain)	NSMutableArray		*songsArray;				// songs array to pass to audio player
@property (nonatomic, retain)	NSMutableArray		*songInfoIndex;
@property (nonatomic,assign)    int					playerState;
@property (nonatomic,assign)    int					secondarViewState;
@property (nonatomic)			sqlite3				*database;
@property (nonatomic, assign)	int					readyToPlayMediaCount;
@property (nonatomic, assign)	float				currentVolume;
@property (nonatomic, retain)	InternetFileManager	*myFileManager;
@property (nonatomic, retain)	NSString			*recordingDirectory;
@property (nonatomic, assign)	int					currentClockIndex;
@property (readwrite)			BOOL				interruptedOnPlayback;
@property (nonatomic)			int					readyItemsOnPlayList;
@property (readwrite)			BOOL				isInternetAvailable;
@property (nonatomic)			int					currentlyPlayingOnPlayList;
@property (nonatomic)			int					currentSongIndex;
@property (nonatomic)			int					currentDownloadIndex;
@property (nonatomic)			int					currentSongId;
@property (nonatomic)			int					popUpIndex;
@property (nonatomic,retain)	IBOutlet			MainView *mainView;
@property (nonatomic, assign)	APAudioPlayer		*avc;
@property (nonatomic,retain)	NSTimer				*refreshPlayListTimer;
@property (nonatomic,retain)	NSTimer				*controllerTimer;
@property (nonatomic,retain)	NSTimer				*popUpTimer;
@property (nonatomic,retain)	NSTimer				*waitAfterSkipClickedTimer;
@property (nonatomic,retain)	NSTimer				*fadeOutTimer;
@property (nonatomic,retain)	NSTimer				*changeSecondaryViewTimer;
@property (nonatomic, assign)	BOOL				isPopUpDisplayed;

- (NSString *)	getMediaHandleAtIndex:(NSInteger)objectIndex;
- (NSString *)	getImageHandleAtIndex:(NSInteger)objectIndex;
- (void)		addDownloadFileOnMediaItemIndexed:(NSInteger)mediaItemIndexNumber;
- (NSInteger)	downloadStateOfMediaItemAtIndex:(NSInteger)index;
- (void)		startDownload; 
- (void)		startParser;
- (int)			doesPlayListExist:(NSInteger)listId;
- (int)			nextSongIndex;
- (int)			nextDownloadIndex;
- (void)		randomizeMediaArray;
- (void)		categorizedPlayLists;
- (void)		enableSkipping;
- (void)	    addPopUpsToPlayList;
- (void)		loadObjectsFromDataBase:(NSString*)path;
- (void)		deleteExtraObjectsFromDataBase;
- (void)		displaySongInfo:(NSNumber*)songIndex;
- (void)		popUpTimerAction;
- (void)		checkForReadyItems:(NSString *)readyFile;
- (void)		markReadyDownload:(NSString *)handle;
- (void)		displayPopUp:(BOOL)activate;
- (void)		checkSystemState;							// This is to check on download status, add files to play list, etc.
- (void)		syncAudioPlayList;							// this matches the play list with what is downloaded and ready to play
- (void)		naturalEndOfSong;
- (void)		playerSkippedItemInPlayList;
- (void)		sendXMLRequest:(int)vote;
- (void)		setGain:(float)volume;
- (void)		setSecondaryView:(int)state;
- (void)		timerChangeSecondaryView;
- (NSInteger)	tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)		tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


// Audio
- (void)		initPlayer;
- (void)		pausePlayback;
- (void)		resumePlayback;
- (void)		playNextSong;
- (void)		playSong;
@end

