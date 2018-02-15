//
//  HitMusicAppDelegate.m
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/8/08.
//  Copyright Wavem 2008. All rights reserved.
//
//
/*
	TODOs
	- Randominzing the mediaItems when the playlist is partially loaded messes up the entire app. The player starts going though the items
	  in it's playlist until it finds one that is actually saved on the phone and then starts playing it. It send the displayInfo function the
	  songIndex 0 which may or may not be downloaded so it might show the different album or nothing at all. It is all messed up from there.
 
 */

#import "HitMusicAppDelegate.h"
#import "MediaItem.h"
#import "ClockItem.h"
#import "PlayList.h"
#import "Playback.h"
#import "PopUp.h"
#import "AudioFile.h"

// Private interface for AppDelegate - internal only methods.
@interface HitMusicAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
@end

@implementation HitMusicAppDelegate

@synthesize window, mediaItems, clockItems,popUpItems, database, readyToPlayMediaCount, myFileManager, recordingDirectory;
@synthesize playLists, currentClockIndex;
@synthesize interruptedOnPlayback;
@synthesize isInternetAvailable;
@synthesize readyItemsOnPlayList;
@synthesize currentlyPlayingOnPlayList;
@synthesize currentSongIndex;
@synthesize currentDownloadIndex;
@synthesize mainView;
@synthesize songIndexesArray;
@synthesize songsArray;
@synthesize songInfoIndex;
@synthesize	currentSongId;
@synthesize playerState;
@synthesize refreshPlayListTimer;
@synthesize isPopUpDisplayed;
@synthesize waitAfterSkipClickedTimer;
@synthesize changeSecondaryViewTimer;
@synthesize avc;
@synthesize popUpTimer;
@synthesize controllerTimer;
@synthesize fadeOutTimer;
@synthesize popUpIndex;
@synthesize currentVolume;
@synthesize secondarViewState;
@synthesize radioStationsArray;

- (void) trackNotifications: (NSNotification *) notification
{//
	id nname = [notification name];
	id ndict = [notification userInfo];
//	
//	// notification name
	printf("%s\n", [nname cStringUsingEncoding:1]);
//	
//	// output accompanying data dictionary
	int i;
	id keys = [ndict allKeys];
	for (i = 1; i < [ndict count]; i++)
	{
		id key = [keys objectAtIndex:i];
		id object = [ndict objectForKey:key];
			NSLog(@"  %@ : %@", key, object);
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application { 
	
	[self setSecondaryView:introView];
	
	radioStationsArray = [[NSArray arrayWithObjects:
					@"HitMusic Channel",
					@"Metal Channel",nil] retain];
	
	//mainView.stationsView.dataSource = self;

	
	NSLog(@"Application started, running basic setup");
	//avc = [[MPAVController sharedInstance] avController];
	
	readyToPlayMediaCount		= 0;
	currentClockIndex			= 0;
	currentlyPlayingOnPlayList	= 0;
	currentClockIndex			= 0;
	popUpIndex					= 0;
	
	playerState					= playerInitializing;
	isPopUpDisplayed			= FALSE;
	isInternetAvailable			= FALSE;
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeDatabase];
	[mainView.lblLyricsTitle setText:@""];
	[mainView.viewLyrics   setText:@""];
	[mainView.lblLyricsArtist setText:@""];
	[mainView.viewCurrentDownload   setText:@""];
	
	srand([[NSDate date] timeIntervalSince1970]);
	
	[window makeKeyAndVisible];
	// create instanse of my internet file manager
	InternetFileManager	*fm = [[InternetFileManager alloc] initWithPath:[self recordingDirectory] withUrl:@"http://orange.wavem.com/skipmix/"];
	self.myFileManager = fm;
	
	// add listeners
	//[self.myFileManager addObserver:self forKeyPath:@"downloadQueue" options:NSKeyValueChangeNewKey context:nil];
	// start the timer for changing the secondaryView
	changeSecondaryViewTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / ksecondsToChangeSecondaryView) target:self selector:@selector(timerChangeSecondaryView) userInfo:nil repeats:YES];
	
	[fm release];
	[NSThread detachNewThreadSelector:@selector(startParser) toTarget:self withObject:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naturalEndOfSong) name:@"AVController_ItemPlaybackDidEnd" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerSkippedItemInPlayList) name:@"AVController_ItemFailedToPlay" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackNotifications:) name:nil object:nil];
}

- (void)	checkSystemState {
	NSLog(@"Checking for system state");
//	[self checkForReadyItems];
}

- (void) timerChangeSecondaryView {
	secondarViewState = (secondarViewState + 1) % 4;
	//NSLog(@"Changing secondary view to %i",secondarViewState);
	[self setSecondaryView:secondarViewState];
}

- (void) setSecondaryView:(int)state {
	CGRect coordinates;
	secondarViewState = state;
	[mainView.lblYes setHidden:secondarViewState != pollView];
	[mainView.lblNo setHidden:secondarViewState != pollView];
	[mainView.imgYesMeter setHidden:secondarViewState != pollView];
	[mainView.imgNoMeter setHidden:secondarViewState != pollView];
	[mainView.btnYes setHidden:secondarViewState != pollView];
	[mainView.btnNo setHidden:secondarViewState != pollView];
	
	//[mainView.lblBigTextView setHidden:secondarViewState != pollView];
	[mainView.lblVoteNow setHidden:secondarViewState != voteNowView];
	
	[mainView.imgMeter setHidden:secondarViewState != voteNowView];
	[mainView.imgNeedle setHidden:secondarViewState != voteNowView];	

	[mainView.imgInTheNews setHidden:secondarViewState != inTheNewsView];
	
	//
	
	switch (state) {
		case inTheNewsView:
			[mainView.lblBigTextView setText:@"10,000 Attend job fair at Dodger Stadium. \n A Crowd of about 10,000 came to Dodger stadium over the weekend, but they weren't there for a baseball game"];
			coordinates = CGRectMake(0,20,312,95);
			break;
		case pollView:
			[mainView.lblBigTextView setText:@"Should alcohol have a minimum price?"];
			coordinates = CGRectMake(0,10,317,30);
			break;
		case voteNowView:
			[mainView.lblBigTextView setText:@"Have your say about the music we play"];
			coordinates = CGRectMake(0,0,185,63);
			break;
		case chatView:
			[mainView.lblBigTextView setText:@"mac1212: This songs rocks \n john212: Yes, for girls \n cynthia: No, it is great !!"];
			coordinates = CGRectMake(0,0,312,95);
			break;
		case introView:
			[mainView.lblBigTextView setText:@"Welcome to the HitMusic Channel"];
			coordinates = CGRectMake(0,0,312,95);
			break;
		default:
			[mainView.lblBigTextView setText:@""];
			
			break;
	}
	
	[mainView.lblBigTextView setFrame:coordinates];
}

- (void) popUpTimerAction {
//	NSLog(@"pop up timer triggered");
	if (!isPopUpDisplayed) {
		[self displayPopUp:TRUE];
		isPopUpDisplayed = TRUE;
		[popUpTimer	invalidate];
		popUpTimer = nil;
		popUpTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / ksecondsDisplayingPopUp) target:self selector:@selector(popUpTimerAction) userInfo:nil repeats:NO];
	} else {
		[self displayPopUp:FALSE];
		[popUpTimer	invalidate];
		popUpTimer = nil;
		isPopUpDisplayed = FALSE;
	}
}
//Pauses the play audio player, this can be called from interruption during running or by user via interface controls
- (void) pausePlayback {

}

// resume a paused media, this media can be paused by interruption or user command. Same can be done for resuming.
- (void) resumePlayback {

}

- (void) displayPopUp:(BOOL)activate {
	int songIndex = [[songIndexesArray objectAtIndex:currentSongIndex] intValue];
	//NSLog(@"Displaying popUp and currentSongIndex is %i", currentSongIndex);
		//[self displaySongInfo:[songIndexesArray objectAtIndex:currentSongIndex]];
	
	if (!activate) {
		NSString *popUpPath = [NSString stringWithFormat: @"%@/%@", [self recordingDirectory], [[mediaItems objectAtIndex:songIndex] image_handle]];
		UIImage *popUpImg = [UIImage imageWithContentsOfFile:popUpPath];
		[mainView.imgMain setImage:popUpImg];
		//[UIView beginAnimations:nil context:NULL];
		//[UIView setAnimationDuration:0.4f];
		//mainView.imgMain.frame = CGRectMake(0.0f, 0.0f, 320.0f, 365.0f);
		//mainView.imgPopUps.frame = CGRectMake(0.0f, 600.0f, 320.0f, 0.0f);
		//[UIView commitAnimations];	
	} else {
		NSString *popUpPath = [NSString stringWithFormat: @"%@/%@", [self recordingDirectory], [[popUpItems objectAtIndex:popUpIndex] handle]];
		UIImage *popUpImg = [UIImage imageWithContentsOfFile:popUpPath];
		[mainView.imgMain setImage:popUpImg];
		//if (popUpImageUrl) { [popUpImageUrl release];}
		//if (popUpImg) { [popUpImg release];}
		
		//[UIView beginAnimations:nil context:NULL];
		//[UIView setAnimationDuration:0.4f];
		//mainView.imgPopUps.frame = CGRectMake(0.0f, 175.0f, 320.0f, 193.0f);
		//mainView.imgMain.frame = CGRectMake(0.0f, 0.0f, 320.0f, 175.0f);
		//[UIView commitAnimations];
	}
	popUpIndex ++;
	popUpIndex = (popUpIndex > [popUpItems count]) ? 0 : popUpIndex;
}

- (void) playerSkippedItemInPlayList{
	NSLog(@"Player skipped item because song was not in storage");
	currentSongIndex ++;
	currentSongIndex = currentSongIndex > [songIndexesArray count] ? 0 : currentSongIndex;
	[self displaySongInfo:[songIndexesArray objectAtIndex:currentSongIndex]];
	[[mainView forwardButton] setEnabled:FALSE];
	[[mainView hateItButton] setEnabled:FALSE];	
}

- (void) naturalEndOfSong{
	NSLog(@"Natural end of song called");
	[mainView.imgMain setImage:[UIImage imageNamed:@"Default.png"]];
	currentSongIndex ++;
	currentSongIndex = currentSongIndex > [songIndexesArray count] ? 0 : currentSongIndex;
	[self displaySongInfo:[songIndexesArray objectAtIndex:currentSongIndex]];
	[[mainView forwardButton] setEnabled:FALSE];
	[[mainView hateItButton] setEnabled:FALSE];	
	waitAfterSkipClickedTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kSecondsToAllowForwardClick) target:self selector:@selector(enableSkipping) userInfo:nil repeats:NO];
}

- (void) playNextSong {
	[avc skipForward];
//	NSLog(@"PlayNextItem and currentSongIndex = %i",currentSongIndex);
//	while ([[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:currentSongIndex] intValue]] audio_downloaded] == FALSE ||
//		[[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:currentSongIndex] intValue]] image_downloaded] == FALSE ) {
//		currentSongIndex ++;
//	}
	currentSongIndex ++;
	//NSLog(@"PlayNextItem and currentSongIndex after while loop = %i",currentSongIndex);

	[[mainView forwardButton] setEnabled:FALSE];
	[[mainView hateItButton] setEnabled:FALSE];	
	waitAfterSkipClickedTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kSecondsToAllowForwardClick) target:self selector:@selector(enableSkipping) userInfo:nil repeats:NO];
	
	[self displaySongInfo:([songIndexesArray objectAtIndex:currentSongIndex])];
	
	//[self displayPopUp:FALSE];
//	if (popUpTimer) {
//		[popUpTimer	invalidate];
//		popUpTimer = nil;
//	}	
}

- (void)  playSong {
	if (!avc) {
		avc= [[APAudioPlayer alloc] initWithCrossFadeSeconds:1000 repeatPlayList:YES withFadeInOutOnSkip:YES];
		avc.parent = self;
		[avc setVolume:1.0];
	}
	else {
		if ([avc isPlaying]) [avc stop];
	}
	[avc play];
	//NSLog(@"The first song to play is %@", [songsArray objectAtIndex:0]);
	playerState	= playerActive;
	[[mainView forwardButton] setEnabled:FALSE];
	[[mainView hateItButton] setEnabled:FALSE];	
	waitAfterSkipClickedTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kSecondsToAllowForwardClick) target:self selector:@selector(enableSkipping) userInfo:nil repeats:NO];
}

- (void) setGain:(float)volume{
	//int ss = [avc volume];
	//NSLog(@"the new volume is %i",volume);
	//for (int t = 10; t > 1; t--) {
//		fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 0.0017) target:self selector:NULL userInfo:nil repeats:NO ];
//		NSLog(@"t=%i ",t);
		[avc setVolume:volume/10];
	//}
}

- (void) enableSkipping {
	//NSLog(@"Going to turn on skipping");
	[waitAfterSkipClickedTimer invalidate];
	waitAfterSkipClickedTimer = nil;
	[[mainView forwardButton] setEnabled:TRUE];
	[[mainView hateItButton] setEnabled:TRUE];	
	//	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"************************************************************************");
	NSLog(@"**************** Received low memory warning message *******************");
	NSLog(@"************************************************************************");
}

- (void)dealloc {
    [window release];
	[mediaItems release];
    [super dealloc];	
	[radioStationsArray release];

}

- (int) nextSongIndex {
	//	NSLog(@"Nextsongindex. currentclockindex = %i, currentSongIndex=%i",currentSongIndex, currentClockIndex);
	
	// Step 1: what is the playlistid in the current clock item and save it on nextListId variable
	int nextListId = [[clockItems objectAtIndex:self.currentClockIndex] list_category_id];
	//NSLog(@"Next List id = %i",nextListId);
	int playListLastIndex;
	int nextSongIndex = 0;
	int playListIndexOnPlayListArray;
	
	// Step #2: what is the index in the playList array of the nextListId ( save in PlayListIndexOnPlayListArray)
	// also, index in mediaitem of last found item for this playlist      ( save in playListLastIndex initialized to -1 on object)
	
	for (int t = 0; t < [playLists count] ; t++) {
		if([[playLists objectAtIndex:t] primaryKey] == nextListId) {
			playListLastIndex = [[playLists objectAtIndex:t] currentPositionOnArray]; 
			//NSLog(@"playListLastIndex= %i",playListLastIndex);
			playListIndexOnPlayListArray = t;
			//NSLog(@"playListIndexOnPlayListArray = %i",playListIndexOnPlayListArray);
			//NSLog(@"playListLastIndex = %i",playListLastIndex);
			break;
		}
	}
	
	// Step #3: Scan the mediaItems array for this nextListId starting from playListLastIndex. If it is the first search then playlistlastindex is -1
	for (int e = playListLastIndex + 1; e < [mediaItems count]; e++) {
		if ([[mediaItems objectAtIndex:e] list_category_id] == nextListId) {
			nextSongIndex = e;
			[[playLists objectAtIndex:playListIndexOnPlayListArray] setCurrentPositionOnArray:e] ;
			//NSLog(@" nextSongIndex = %i",nextSongIndex);
			break;
		} 
	}
	
	// Step: #3.2 Ended the search in mediaItems array for this nextListId and found nothing so started search from begining of the mediaItems array
	if (nextSongIndex == -1) {
		//NSLog(@"Reached the end so I start the search from the beginning!, playListIndexOnPlayListArray= %i total mediaItems = %i, nextListId=%i",playListIndexOnPlayListArray, [mediaItems count], nextListId);
		for (int f = 0 ; f < [mediaItems count]; f++) {
			//NSLog(@"Inside begining loop no %i",f);
			if ([[mediaItems objectAtIndex:f] list_category_id] == nextListId ) {
				//NSLog(@"found begining loop no %i, listcategory= %i",f,[[mediaItems objectAtIndex:f] list_category_id]);
				nextSongIndex = f;
				[[playLists objectAtIndex:playListIndexOnPlayListArray] setCurrentPositionOnArray:f] ;
				break;
			} 
		}
	}
	
	//self.currentSongIndex = nextSongIndex;
	//currentSongIndex = currentSongIndex % 30;
	//NSLog(@"Finished nextsongindex proc and currentSongIndex = %i",currentSongIndex);
	int clocksArrayCount = [clockItems count] -1;
	currentClockIndex++;
	if (currentClockIndex > clocksArrayCount) {
		currentClockIndex = 0 ;
	}
	
	return nextSongIndex;
}

- (void) categorizedPlayLists {
	NSInteger playListSearch;
	for (int t = 0; t < [mediaItems count]; t++) {
		
		playListSearch = [self doesPlayListExist:[[mediaItems objectAtIndex:t] list_category_id]];
		
		if (playListSearch == -1) {
			PlayList *newPlayList = [[PlayList alloc] createWithId:[[mediaItems objectAtIndex:t] list_category_id]];
			[playLists addObject:newPlayList];
			[newPlayList release];
		} 
	}
}


- (int)	nextDownloadIndex {
	//int nextListId = [[clockItems objectAtIndex:self.currentClockIndex] list_category_id];
//	int playListLastIndex;
//	int nextSongIndex = 0;
//	int playListIndexOnPlayListArray;
//	
//	for (int t = 0; t < [playLists count] ; t++) {
//		if([[playLists objectAtIndex:t] primaryKey] == nextListId) {
//			playListLastIndex = [[playLists objectAtIndex:t] currentPositionOnArray];
//			//NSLog(@"playListLastIndex= %i",playListLastIndex);
//			playListIndexOnPlayListArray = t;
//			break;
//		}
//	}
//	//NSLog(@"CurrentPositinOnTheArray = %i",playListLastIndex);
//	
//	for (int e = playListLastIndex + 1; e < [mediaItems count]; e++) {
//		if ([[mediaItems objectAtIndex:e] list_category_id] == nextListId && [[mediaItems objectAtIndex:e] downloaded_files] == 2) {
//			nextSongIndex = e;
//			[[playLists objectAtIndex:playListIndexOnPlayListArray] setCurrentPositionOnArray:e] ;
//			//NSLog(@" nextSongIndex = %i",nextSongIndex);
//			break;
//		} 
//	}
//	// ended the search and found nothing so started search from begining.
	return 0;
}

- (int) doesPlayListExist:(NSInteger)listId {
	int result = -1;
	NSInteger listIdSearched;
	//NSLog(@"Inside playlist search with playlistCount = %i and searching id %i", [self.playLists count],listId);
	for (int t = 0; t < [playLists count]; t++) {
		listIdSearched = [[playLists objectAtIndex:t] primaryKey];
	//	NSLog(@"Comparing t= %i with sentId = %i",listIdSearched, listId);
		
		if (listIdSearched == listId) {
			result = t;
			break;
	//		NSLog(@"Id found, exiting with index value of %i",t);
		}
	}
	return result;
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"radioDB.sql"];
	//NSLog(@"The DB path is %@",writableDBPath);
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"radioDB.sql"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
	[fileManager release];
}

// Open the database connection and retrieve information for all objects.
- (void)initializeDatabase {

	NSMutableArray *mediaItemArray			= [[NSMutableArray alloc] init];
	NSMutableArray *clockItemArray			= [[NSMutableArray alloc] init];
	NSMutableArray *playListArray			= [[NSMutableArray alloc] init];
	NSMutableArray *popUpItemArray			= [[NSMutableArray alloc] init];
	NSMutableArray *songsArrayArray			= [[NSMutableArray alloc] init];
	NSMutableArray *songIndexesArrayArray	= [[NSMutableArray alloc] init];
	NSMutableArray *songInfoIndexArray		= [[NSMutableArray alloc] init];
	
    self.mediaItems			= mediaItemArray;
	self.clockItems			= clockItemArray;
	self.playLists			= playListArray;
	self.popUpItems			= popUpItemArray;
	self.songsArray			= songsArrayArray;
	self.songIndexesArray	= songIndexesArrayArray;
	self.songInfoIndex		= songInfoIndexArray;
	
    [mediaItemArray release];
	[clockItemArray release];
	[playListArray release];
	[popUpItemArray release];
	[songsArrayArray release];
	[songIndexesArrayArray release];
	[songInfoIndexArray release];
	
	// The database is stored in the application bundle. 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"radioDB.sql"];
    self.recordingDirectory = documentsDirectory;
	
	[self loadObjectsFromDataBase:path];

//	NSLog(@"******** from database ************");
//	NSLog(@"Media files in DB %i.", [mediaItems count]);
//	NSLog(@"Clock files in DB %i.", [clockItems count]);
//	NSLog(@"Total playlists = %i", [playLists count]);
//	NSLog(@"Total popUps = %i", [popUpItems count]);
//	NSLog(@"******** from database ************");
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [radioStationsArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radiostations"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"radiostations"] autorelease];
	}
	// Set up the cell
	cell.textLabel.text = [radioStationsArray objectAtIndex:indexPath.row];
	return cell;
}

// this happenes everytime a cell in the stations selection view is clicked.
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"A tab was clicked");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:mainView cache:YES];
	[mainView.stationsView removeFromSuperview];
	[mainView addSubview:mainView.radioInterface];
	[UIView commitAnimations];
	//
//	// *****
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.5];
//	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
//	[registerView removeFromSuperview];
//	[radioInterface removeFromSuperview];
//	[self addSubview:stationsView];
//	[UIView commitAnimations];
	
}

- (void) loadObjectsFromDataBase:(NSString*)path {
	char *str = nil;
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		
		// *************** Get values for mediaItems. *********************
        const char *sql = "select id, handle ,audio_name, artist_name, list_category_id, media_type, segue_point, mime_type, length,image_handle, audio_downloaded, image_downloaded, pop_up_downloaded from media_item";
        sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
                int pKey			= sqlite3_column_int(statement, 0);
				str = (char *)sqlite3_column_text(statement,1);
				NSString *fHandle		=(str) ? [NSString stringWithUTF8String:str] : @"";
				str = (char *)sqlite3_column_text(statement, 2);
				NSString *fAudio_name	=(str) ? [NSString stringWithUTF8String:str] : @"";
				str = (char *)sqlite3_column_text(statement, 3);
				NSString *fArtist_name	=(str) ? [NSString stringWithUTF8String:str] : @"";
				int	 fList_category_id	= sqlite3_column_int(statement, 4);
				int fMedia_type			= sqlite3_column_int(statement, 5);
				int fSeguePoint			= sqlite3_column_int(statement, 6);
				str = (char *)sqlite3_column_text(statement, 7);
				NSString *fMime_type	=(str) ? [NSString stringWithUTF8String:str] : @"";
				int fLength				= sqlite3_column_int(statement, 8);
				str = (char *)sqlite3_column_text(statement, 9);
				NSString *imageHandl	=(str) ? [NSString stringWithUTF8String:str] : @"";
				int faudio_downloaded	= sqlite3_column_int(statement, 10);
				int fimage_downlaoded	= sqlite3_column_int(statement, 11);
				int fpop_up_downlaoded	= sqlite3_column_int(statement, 12);
				
				MediaItem *mediaItem = [[MediaItem alloc] initWithPrimaryKey:pKey withDatabase:database withHandle:fHandle withAudioName:fAudio_name
															  withArtistName:fArtist_name withlistCategoryId:fList_category_id withMediaType:fMedia_type 
															  withSeguePoint:fSeguePoint withMimeType:fMime_type withMediaLength:fLength 
															  withImageHandle:imageHandl markActive:FALSE];
				
				[mediaItem setAudio_downloaded:faudio_downloaded];
				[mediaItem setImage_downloaded:fimage_downlaoded];
				[mediaItem setPop_up_downloaded:fpop_up_downlaoded];
				
                [mediaItems addObject:mediaItem];
				[mediaItem release];
				
				// if this media item has both downlaods complete then encrease our completed media items variable
				if ([mediaItem image_downloaded] == TRUE && [mediaItem audio_downloaded] == TRUE) {
					readyToPlayMediaCount++;
				}
				// register play_list_category
				// NSLog(@"Asking if playlist with id %i exists",fList_category_id);
				NSInteger playListSearch = [self doesPlayListExist:fList_category_id];
				// NSLog(@"Playlist search result = %i",playListSearch);
				
				if (playListSearch == -1) {
					// NSLog(@"New playlist found, adding it to array");
					PlayList *newPlayList = [[PlayList alloc] createWithId:fList_category_id];
					[playLists addObject:newPlayList];
					[newPlayList release];
				} 
			}
        }
		
		sqlite3_finalize(statement);
		
		//***************  Get values for clockItems. ***************
		const char *sql2 = "select list_category_id, no from clocks";
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(database, sql2, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				int	fList_category_id	= sqlite3_column_int(statement, 0);
				int fNo					= sqlite3_column_int(statement, 1);
				
				//NSLog(@"New clock item %i, %i", fList_category_id, fNo);
				ClockItem *clockItem = [[ClockItem alloc] initWithListCategoryId:fList_category_id withDatabase:database withRotationNo:fNo markActive:FALSE];
				
                [clockItems addObject:clockItem];
                [clockItem release];
				
			}
        } else {
			NSLog(@"HitMusicDeleGate: LoadObjectsFromDataBase: Something did not go right with the clock insert");
		}
		
		sqlite3_finalize(statement);
		
		// *************** Get the popUp items ***************
		const char *sql3 = "select id,handle, downloaded from pop_ups";
		if (sqlite3_prepare_v2(database, sql3, -1, &statement, NULL) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
				int	fId						= sqlite3_column_int(statement, 0);
				str							= (char *)sqlite3_column_text(statement, 1);
				NSString *imageHandl		=(str) ? [NSString stringWithUTF8String:str] : @"";
				int	fDownloaded				= sqlite3_column_int(statement, 2);
				
				PopUp *popUpItem = [[PopUp alloc] initWithPrimaryKey:fId withHandle:imageHandl withDatabase:database markActive:FALSE isDownloaded:fDownloaded];
				[popUpItem setDownloaded:fDownloaded];
                [popUpItems addObject:popUpItem];
				[popUpItem release];
			}
        } else {
			NSLog(@"HitMusicDeleGate: LoadObjectsFromDataBase:  Something did not go right with the popUpItem insert");
		}
		
		sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
		//NSLog(@"Sent a close database command");
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
	
//	NSLog(@"******** from database ************");
//	NSLog(@"Media files in DB %i.", [mediaItems count]);
//	NSLog(@"Clock files in DB %i.", [clockItems count]);
//	NSLog(@"Total popUps = %i", [popUpItems count]);
//	NSLog(@"******** from database ************");
	[mainView.lblDownloadedSongs setText: [NSString stringWithFormat:@"%d", readyToPlayMediaCount]];
}

- (void)	deleteExtraObjectsFromDataBase {
	//NSLog(@"there are %i mediaItems in mediaitemsarray",[mediaItems count]);
	// ********* CleanUp media_items array
	for (int t = 0; t < [mediaItems count] ;t++) {
		if ([[mediaItems objectAtIndex:t] isActiveItem] == 0) {
			//NSLog(@"found one mediaitem with active=0, index at %i .Deleting",t);
			
			[[mediaItems objectAtIndex:t] deleteFromDatabase:database];
			[mediaItems removeObject:[mediaItems objectAtIndex:t]];
		}
	}

	// ********* CleanUp clocks array
	for (int t = 0; t < [clockItems count] ;t++) {
		if ([[clockItems objectAtIndex:t] isActiveItem] == 0) {
			[[clockItems objectAtIndex:t] deleteFromDatabase:database];
			[clockItems removeObject:[clockItems objectAtIndex:t]];
		}
	}
	
	// ********* CleanUp popUp array
	for (int t = 0; t < [popUpItems count] ;t++) {
		if ([[popUpItems objectAtIndex:t] isActiveItem] == 0) {
			[[popUpItems objectAtIndex:t] deleteFromDatabase:database];
			[popUpItems removeObject:[popUpItems objectAtIndex:t]];
		}
	}
}

- (void) addDownloadFileOnMediaItemIndexed:(NSInteger)mediaItemIndexNumber {
  
//	[[mediaItems objectAtIndex:mediaItemIndexNumber] setDownloaded_files:[[mediaItems objectAtIndex:mediaItemIndexNumber] downloaded_files]+1];
	// NSLog(@"Marking this file indexed %i as downloaded on DB and now it's media_handle = %@ and image_handle = %@",mediaItemIndexNumber,  [[mediaItems objectAtIndex:mediaItemIndexNumber] handle], [[mediaItems objectAtIndex:mediaItemIndexNumber] image_handle]);
//	[[mediaItems objectAtIndex:mediaItemIndexNumber] updateMediaItem:self.database];
//	NSLog(@"Marked this file as downloaded on DB and now it's media_handle = %@ and image_handle = %@",  [[mediaItems objectAtIndex:mediaItemIndexNumber] handle], [[mediaItems objectAtIndex:mediaItemIndexNumber] image_handle]);
}

- (NSString *)getMediaHandleAtIndex:(NSInteger)objectIndex {
	return [[mediaItems objectAtIndex:objectIndex] handle];
}

- (NSString *)getImageHandleAtIndex:(NSInteger)objectIndex {
	return [[mediaItems objectAtIndex:objectIndex] image_handle];
}

- (NSInteger) downloadStateOfMediaItemAtIndex:(NSInteger)index {
//	return [[mediaItems objectAtIndex:index] downloaded_files];
	return 0;
}

- (void) startDownload  {
	int presentIndex;
	for (int t = 0; t < [self.songIndexesArray count]; t++) {
		presentIndex = ([[self.songIndexesArray objectAtIndex:t] intValue]);
		if ([[mediaItems objectAtIndex:presentIndex] isAddedToDownloadQueue] == FALSE) {
			[myFileManager addToQueue:[mediaItems objectAtIndex:presentIndex]];
			[[mediaItems objectAtIndex:presentIndex] setIsAddedToDownloadQueue:TRUE];
		}
	}
	[NSThread detachNewThreadSelector:@selector(downLoadFiles) toTarget:self.myFileManager withObject:nil];
}

// this downloads the xml from the server populating our object arrays.
- (void) startParser {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Started parser");
	NSString *feedURLString;
	NSError  *parseError;
	Boolean connectionError = FALSE;
	
	XMLReader *streamingParser;
	//HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[mainView.lblSongName setText:@"Loading playist...."];
	
	// First download media_items data
	feedURLString = @"http://orange.wavem.com/RadioAdminPHP/iphone_media_item.php?clock_id=11";
	parseError = nil;
	streamingParser = [[XMLReader alloc] init];
    //NSLog(@"Ready to send message to streamparses");
	[streamingParser parseXMLFileAtURL:[NSURL URLWithString:feedURLString] parseError:&parseError objectName:@"media_item" withObjectArray:(NSMutableArray *)mediaItems withDatabase:database];
	if (parseError  != nil) 
		connectionError = TRUE;	
	
	[streamingParser release];        
    
	// Download pop up list from server
	feedURLString = @"http://orange.wavem.com/RadioAdminPHP/iphone_pop_up_items.php";
	parseError = nil;
	streamingParser = [[XMLReader alloc] init];
    [streamingParser parseXMLFileAtURL:[NSURL URLWithString:feedURLString] parseError:&parseError objectName:@"pop_up_item" withObjectArray:(NSMutableArray *)popUpItems withDatabase:database];
	if (parseError  != nil) 
		connectionError = TRUE;	
	
	[streamingParser release]; 
	
	// Download clock information
	feedURLString =  @"http://orange.wavem.com/RadioAdminPHP/iphone_clock.php?clock_id=11";
	parseError = nil;
	streamingParser = [[XMLReader alloc] init];
	[streamingParser parseXMLFileAtURL:[NSURL URLWithString:feedURLString] parseError:&parseError objectName:@"clock_item" withObjectArray:(NSMutableArray *)clockItems withDatabase:database];
	if (parseError  != nil) 
		connectionError = TRUE;	
	
	[streamingParser release];        
	
	//NSLog(@"Number of clockItem %i",[appDelegate.clockItems count]);
	
//	if ([mediaItems count] == 0) {
//		NSLog(@"There are no media items, there seems to be a connection error");
//		[mainView.lblSongName setText:@""];
//		[mainView.lblArtistName setText:@"Connection not available"];
//		return;
//	}
	
	if (connectionError == TRUE) {
		NSLog(@"******* No connection is available");
		[mainView.lblSongName setText:@"there was an error getting playlist"];
		isInternetAvailable = FALSE;
		
	} else {
		NSLog(@"******* connection is available");
		[self deleteExtraObjectsFromDataBase];	
		//[mainView.lblSongName setText:@"Playlist succesfully downloaded"];
		isInternetAvailable = TRUE;
	}

	[self randomizeMediaArray];
	//[mainView.lblSongName setText:@"Randomized play list"];
	[self categorizedPlayLists];
	//[mainView.lblSongName setText:@"Categorized play list"];
	[self addPopUpsToPlayList];
	//[mainView.lblSongName setText:@"Added pop ups"];

	//NSLog(@"Media files in array %i.", [mediaItems count]);
	//NSLog(@"Clock files in array %i.", [clockItems count]);
	//NSLog(@"Total playlists items= %i", [playLists count]);
	//NSLog(@"Total popUps = %i", [popUpItems count]);
	//NSLog(@"Number of ready files %i",readyToPlayMediaCount);
	
	[self performSelectorOnMainThread:@selector(initPlayer) withObject:nil waitUntilDone:NO];
	
	//NSLog(@"Ended Parser succesfully");
	[pool release];
}

- (void) checkForReadyItems:(NSString *)readyFile {
	NSLog(@"Checking for ready items and the one sent was %@", readyFile);
	//return;
	//NSString * newReadyItem = [myFileManager getReadyItem];
	//while (newReadyItem !=  @"") {
	//	NSLog(@"Checking for ready Items: found one %@ ", newReadyItem);
	[self markReadyDownload:readyFile];
		//NSLog(@"After this new download the songsArray count is %i", [songsArray count]);
		//newReadyItem = [myFileManager getReadyItem];
	//}
	[mainView.viewCurrentDownload setText: [myFileManager downloadFileNewName]];
}

- (void) markReadyDownload:(NSString *)fileName {

	
	for (int u = 0; u < [popUpItems count]; u++) {
		if ([[[popUpItems objectAtIndex:u] handle] isEqualToString:fileName]) {
			//NSLog(@"markReadyDownload: The file %@ was found in popUpItem index %i",fileName, u);
			[[popUpItems objectAtIndex:u] setDownloaded:TRUE];
			[[popUpItems objectAtIndex:u] updatePopUpItem:database];
		}
	}
	
	//NSLog(@"continuing to check media items");
	for (int i = 0; i < [mediaItems count]; i++) {
		 if ([[[mediaItems objectAtIndex:i] handle] isEqualToString:fileName]) {
			// NSLog(@"markReadyDownload: The file %@ was found in audio index %i",fileName,i);
			 [[mediaItems objectAtIndex:i] setAudio_downloaded:TRUE];
			 [[mediaItems objectAtIndex:i] updateMediaItem:database];
			 if ([[mediaItems objectAtIndex:i] image_downloaded] == TRUE) {
				 readyToPlayMediaCount++;
			 }
			 //indexFound = i;
		}
		if ([[[mediaItems objectAtIndex:i] image_handle] isEqualToString:fileName]) {
			//NSLog(@"markReadyDownload: The file %@ was found in image index %i",fileName,i);
			[[mediaItems objectAtIndex:i] setImage_downloaded:TRUE];
			[[mediaItems objectAtIndex:i] updateMediaItem:database];
			if ([[mediaItems objectAtIndex:i] audio_downloaded] == TRUE) {
				readyToPlayMediaCount++;
			}
	}
	[mainView.lblDownloadedSongs setText: [NSString stringWithFormat:@"%i", readyToPlayMediaCount]];
	[mainView.lblQueuedSongs setText:[NSString stringWithFormat:@"%i", [myFileManager.downloadQueue count]]];
	[mainView.viewCurrentDownload   setText:[myFileManager downloadFileNewName]];
		
	if (([[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:0] intValue]] audio_downloaded] == TRUE &&
		[[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:0] intValue]] image_downloaded] == TRUE &&
		playerState == playerInitializing)  && 
		([[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:0] intValue]] audio_downloaded] == TRUE &&
		 [[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:0] intValue]] image_downloaded] == TRUE &&
		 playerState == playerInitializing) ) {	
		NSLog(@"markReadyDownload: First element in the play list has audio and image downloaded, staring to play");
		[self displaySongInfo:([songIndexesArray objectAtIndex:0])];
		[self playSong];
	};
	};
}

- (void) displaySongInfo:(NSNumber*)songIndex {
	//NSLog(@"DisplaySongInfo sonidex = %i and mediaitems count is %i",([songIndex intValue]), [mediaItems count]);
	// Get the information about the media item
	NSString *imgHandle    = [[self.mediaItems objectAtIndex:([songIndex intValue])] image_handle];
	NSString *mediaName    = [[self.mediaItems objectAtIndex:([songIndex intValue])] audio_name];
	NSString *lyricsText   = [[self.mediaItems objectAtIndex:([songIndex intValue])] lyrics];
	NSString *Artist       = [[self.mediaItems objectAtIndex:([songIndex intValue])] artist_name];
	
	lyricsText = ([lyricsText length] == 0) ? @"No lyrics available" : lyricsText;
	self.currentSongId = [[mediaItems objectAtIndex:([songIndex intValue])] primaryKey];
	
	// change displays on views
	[mainView.lblLyricsTitle setText:mediaName];
	[mainView.viewLyrics   setText:lyricsText];
	[mainView.lblSongName setText:mediaName];
	[mainView.lblArtistName setText:Artist];
	[mainView.lblLyricsArtist setText:Artist];
	
	// Change the main display image of the song
	NSString *imagePath = [NSString stringWithFormat: @"%@/%@", [self recordingDirectory], imgHandle];
	//NSLog(@"the image is %@",imagePath);
	//NSURL *imageUrl = [[NSURL URLWithString:imagePath] retain];
	//NSData *data = [NSData dataWithContentsOfURL:imageUrl];
	//UIImage *img = [[UIImage alloc] initWithData:data ];
	
	UIImage *img = [UIImage imageWithContentsOfFile:imagePath];

	
	//UIImage *img = [[UIImage alloc] imageWithContentsOfFile:imagePath ];
	
	[mainView.imgMain setImage:img];
	//if (imageUrl) { [imageUrl release];}
	//if (img) {[img release];}
	
	// check to see if this song has a popup associated with it.
	if ([[[self.mediaItems objectAtIndex:([songIndex intValue])] popUpHandle] length] != 0) {
		//NSLog(@"This song has an popUp called %@",[[self.mediaItems objectAtIndex:([songIndex intValue])] popUpHandle]);
		// activate the popUpTimer
		popUpTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / ksecondsBeforePopUpDisplay) target:self selector:@selector(popUpTimerAction) userInfo:nil repeats:NO];
	}
}

- (void) initPlayer {	

	for (int e = 0; e < [popUpItems count]; e++) {
		
		if ([[popUpItems objectAtIndex:e] downloaded] == 0) {
			//NSLog(@"Popup %i) called %@ isDownloaded = %i",e, [[popUpItems objectAtIndex:e] handle], [[popUpItems objectAtIndex:e] downloaded]);
			[myFileManager addSingleFile:[[popUpItems objectAtIndex:e] handle]];
		}
	}

	//NSLog(@"INitializing player, songIndexesArray count = %i and songsarray count = %i",[songIndexesArray count], [songsArray count]);
	if (!avc) {
		avc= [[APAudioPlayer alloc] initWithCrossFadeSeconds:1000 repeatPlayList:YES  withFadeInOutOnSkip:YES];
		avc.parent = self;
		[avc setVolume:1.0];
	}
	for (int t = 0; t < kPreloadedSongs; t++) {
		self.currentSongIndex = [self nextSongIndex];	
		//NSLog(@"Got the nextSongIndex =%i and the mediaItem is %@",self.currentSongIndex, [[mediaItems objectAtIndex:self.currentSongIndex] handle]);
		if (currentSongIndex == -1) {
			NSLog(@"The currentlist did not have mediaitems");
			[mainView.lblSongName setText:@"The currentlist did not have mediaitems"];
			break;
		}
		
		[[self songIndexesArray] addObject:[NSNumber numberWithInteger:currentSongIndex]];
		
		NSString *mediaHandle = [[mediaItems objectAtIndex:currentSongIndex] handle];
		
		
		AudioFile *tempFile =	[[AudioFile alloc] initWithFileURL: [NSString stringWithFormat: @"%@/%@",recordingDirectory, mediaHandle]
													  withOffset:0 
										andWithFadeOutMilisecond:1000];	// [NSString stringWithFormat: @"%@/%@",recordingDirectory, mediaHandle]];
		//NSLog([NSString stringWithFormat: @"file://localhost%@/%@",recordingDirectory, mediaHandle]);
		if (tempFile.fileURL)
			[avc addAudioToPlayList: tempFile];	
		//[self.songsArray addObject:tempFile ];
		[tempFile autorelease];
		
	//	[[self songsArray] addObject:path];
	//	[path release];
	}
	
	// TESTING 
	NSLog(@"************ songsArray elements *************");
	NSLog(@"songsArray count is %i and songsIndexesArray count is %i, mediaItems count is %i",[songsArray count],[songIndexesArray count], [mediaItems count]);
	for (int d = 0; d < [songsArray count]; d++) {
		NSLog(@"%i) songsArray E= %@,I= %@ AD= %i, ID=%i",[[songIndexesArray objectAtIndex:d] intValue],
				[[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:d] intValue]] handle],
				[[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:d] intValue]] image_handle],
			    [[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:d] intValue]] audio_downloaded],
			    [[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:d] intValue]] image_downloaded]);
	}
	NSLog(@"************ END OF songsArray elements *************");
	
	
	NSLog(@"************ mediaItems array elements %i *************", [mediaItems count]);
	for (int d = 0; d < [mediaItems count]; d++) {
		NSLog(@"%i) mediaItem E= %@,I= %@ AD= %i, ID=%i",d,
			  [[mediaItems objectAtIndex:d] handle],
			  [[mediaItems objectAtIndex:d] image_handle],
			  [[mediaItems objectAtIndex:d] audio_downloaded],
			  [[mediaItems objectAtIndex:d] image_downloaded]);
	}
	NSLog(@"************ END OF media items array elements *************");
		
	
	// END OF TESTING 
	
	self.currentSongIndex = 0;
	
	//if (readyToPlayMediaCount  > 0 ) {
	if ([[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:0] intValue]] audio_downloaded] == TRUE &&
		[[mediaItems objectAtIndex:[[songIndexesArray objectAtIndex:0] intValue]] image_downloaded] == TRUE) {
		[self displaySongInfo:([songIndexesArray objectAtIndex:0])];
		[self playSong];
		//[mainView.lblSongName setText:@"Started audio play"];
	}
	
	//[NSThread detachNewThreadSelector:@selector(startDownload) toTarget:self withObject:nil];
	if (isInternetAvailable) {
		[self startDownload];
	}
}

- (void) syncAudioPlayList {

	
}

- (void) addPopUpsToPlayList {
	int				totalPopUps =  [popUpItems count];
	int				currentPopUpIndex = 0;
	int				totalMediaItems = [mediaItems count];
	int				taggedTotal = kPopUpRate * totalMediaItems / 100; 
	int				tagged = 0;
	NSUInteger		randomPick;
	
	//NSLog(@"taggedTotal = %i",taggedTotal);
	while (tagged < taggedTotal) {
		randomPick = random() % totalMediaItems;
		if ([[[mediaItems objectAtIndex:randomPick] popUpHandle] length] == 0) {
			//NSLog(@"The popUpHandle was empty tagged = %i and taggedTotal= %i, currentPopUpIndex = %i", tagged, taggedTotal,currentPopUpIndex);
			[[mediaItems objectAtIndex:randomPick] setPopUpHandle:[[popUpItems objectAtIndex:currentPopUpIndex] handle]];
			tagged++;
			currentPopUpIndex++;
			currentPopUpIndex = currentPopUpIndex % totalPopUps;
		}
	}	
}

// send XML request
- (void)sendXMLRequest:(int)vote {
	int currentIndex		= [[songIndexesArray objectAtIndex:currentSongIndex] intValue];
	NSString *songId		= [NSString stringWithFormat:@"%d", currentSongId];
	NSString *playListId	= [NSString stringWithFormat:@"%d", [[mediaItems objectAtIndex:currentIndex] list_category_id]];
	NSString *voteString	= [NSString stringWithFormat:@"%d", vote];
	
	NSString *post = [NSString stringWithFormat:@"play_list_id=%@&song_id=%@&station_id=%@&vote=%@", playListId, songId, @"1", voteString];
	NSLog(@"The post string is %@",post);
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	
	[request setURL:[NSURL URLWithString:@"http://orange.wavem.com/RadioAdminPHP/submit_song_vote.php"]];  
	[request setHTTPMethod:@"POST"];  
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	
	NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
	if (conn)  
	{  
		NSLog(@"XML Message sent was : %@",post);
	}  
	else  
	{  
		// inform the user that the download could not be made  
	}  
}

- (void) randomizeMediaArray {

	NSUInteger firstObject = 0;
	for (int i = 0; i<[mediaItems count];i++) {
		NSUInteger randomIndex = random() % [mediaItems count];
		[mediaItems exchangeObjectAtIndex:firstObject withObjectAtIndex:randomIndex];
		firstObject +=1;
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
 
}

@end
