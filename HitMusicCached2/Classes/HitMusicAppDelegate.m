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
#import "XMLParser.h"
#import "DownloadObject.h"
#import "TreeNode.h"
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
@synthesize radioStationsArray, tempMediaItem;
@synthesize	playListsDate;

@synthesize myDate, year,dayOfTheYear, hourOfDay, hourOfDay2, monthOfYear, dayOfMonth, timeZoneOffset;

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

- (void) downloadFiles {
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    for (int t = 0; t < [mediaItems count]; t++) {
        /* Download images */
		if ([[mediaItems objectAtIndex:t] image_downloaded] == FALSE ) {
            NSLog(@" Ordered download of image %@",[[mediaItems objectAtIndex:t] image_source]);
            [[self myFileManager] addFileToQueue:([[mediaItems objectAtIndex:t] image_source])
									 withNewName:[NSString stringWithFormat:@"%@%i.jpg",@"image",[[mediaItems objectAtIndex:t] coverObjectId]]
                                       fromOwner:@"MediaItem" withOwnerId:[[mediaItems objectAtIndex:t] mediaId] withOwnerIndex:t withType:@"image"];
        }
        /* Download audio */
		
		if ([[mediaItems objectAtIndex:t] audio_downloaded] == FALSE ) {
            NSLog(@" Ordered download of audio %@",[[mediaItems objectAtIndex:t] audio_source]);
            [[self myFileManager] addFileToQueue:[[mediaItems objectAtIndex:t] audio_source] withNewName:[NSString stringWithFormat:@"%@%i.aac",@"audio",[[mediaItems objectAtIndex:t] mediaId]]
                                       fromOwner:@"MediaItem" withOwnerId:[[mediaItems objectAtIndex:t] mediaId] withOwnerIndex:t withType:@"audio"];
        }
    }
	
//	[[self myFileManager] addFileToQueue:@"http://media.goomradio.com/MATIERE/OBJET/8/3/6/7/8/IMAGE/173644.420.JPG" withNewName:@"MyTest.jpg" fromOwner:@"MediaItem" withOwnerId:2332323232 withOwnerIndex:2];
	
    NSLog(@"Finished adding files to the queue. starting download");
    //[[self myFileManager] downLoadFiles];
	[NSThread detachNewThreadSelector:@selector(downLoadFiles) toTarget:self.myFileManager withObject:nil];
//	[pool release];
}

/* Ads songs to the play list that are already downloaded on the phone */
- (void) addFilesToPlayList { 
	AudioFile *newFile;
	float progressValue;
	double finalProgress;
	NSString *addedFile;

	NSLog(@"Adding files to playlist and the count is %i ",[mediaItems count]);
	
	for (int t = 0; t < [mediaItems count]; t++) {
		
		if ([[mediaItems objectAtIndex:t] image_downloaded] == TRUE && [[mediaItems objectAtIndex:t] audio_downloaded] == TRUE) {
			addedFile = [NSString stringWithFormat:@"%@/%@", self.recordingDirectory, [[mediaItems objectAtIndex:t] audio_handle]];
			NSLog(@"Adding new file to play list with url = %@", addedFile);
			NSLog([NSString stringWithFormat:@"Song information: Pos start %d pos fade %d and pos chain %d and duration: %d", [[mediaItems objectAtIndex:t]posStart], [[mediaItems objectAtIndex:t] posFadeOut], [[mediaItems objectAtIndex:t] posChain] , [[mediaItems objectAtIndex:t] posEnd]]);
			newFile = [[AudioFile alloc] initWithFileURL:addedFile 
											  withOffset:[[mediaItems objectAtIndex:t] posStart]
								andWithFadeOutMilisecond:[[mediaItems objectAtIndex:t] posFadeOut] 
										 andWithPosChain:[[mediaItems objectAtIndex:t] posChain] 
											withDuration:[[mediaItems objectAtIndex:t] posEnd] 
											   withImage:[[mediaItems objectAtIndex:t] image_handle]
											   withTitle:[[mediaItems objectAtIndex:t] title]
										   andWithSinger:[[mediaItems objectAtIndex:t] artist]];
			[avc addAudioToPlayList:newFile];
			progressValue =  ((([[avc fileList] count] * 100) / [mediaItems count])) ;
			finalProgress = (double) progressValue /100;
			[mainView setProgress:(float)finalProgress];
		}
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application { 
	myDate = [NSDate date] ;
	year = [myDate descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil] ;
	dayOfTheYear=[myDate descriptionWithCalendarFormat:@"%j" timeZone:nil locale:nil] ;
	hourOfDay =[myDate descriptionWithCalendarFormat:@"%H" timeZone:nil locale:nil] ;
	hourOfDay2 = [NSString stringWithFormat:@"%i",(([hourOfDay intValue]+1)%24)];
	monthOfYear =[myDate descriptionWithCalendarFormat:@"%m" timeZone:nil locale:nil] ;
	dayOfMonth =[myDate descriptionWithCalendarFormat:@"%d" timeZone:nil locale:nil] ;
	timeZoneOffset =[myDate descriptionWithCalendarFormat:@"%z" timeZone:nil locale:nil] ;
	
	tempMediaItem = [[MediaItem alloc] init];
	readyToPlayMediaCount		= 0;
	currentClockIndex			= 0;
	currentlyPlayingOnPlayList	= 0;
	currentClockIndex			= 0;
	popUpIndex					= 0;
	playerState					= playerInitializing;
	isPopUpDisplayed			= FALSE;
	isInternetAvailable			= FALSE;
	
	InternetFileManager *fm = [[InternetFileManager alloc] init];
	self.myFileManager = fm;
	
	[mainView.lblLyricsTitle setText:@""];
	[mainView.viewLyrics   setText:@""];
	[mainView.lblLyricsArtist setText:@""];
	[mainView.viewCurrentDownload   setText:@""];
	
	[self setSecondaryView:introView];	
	[self createEditableCopyOfDatabaseIfNeeded];
	
	[self initPlayer];
	[self initializeDatabase];

	
	NSLog(@"After loading objects from database, mediaitems count is %i",[mediaItems count]);
	[self parsePlayListFromServer];
	NSLog(@"After parsing objects from server , mediaitems count is %i",[mediaItems count]);
	
	
	
	radioStationsArray = [[NSArray arrayWithObjects:@"Rock Your Life", nil] retain];
	
	//mainView.stationsView.dataSource = self;
	
	NSLog(@"Application started, running basic setup");
	
	srand([[NSDate date] timeIntervalSince1970]);
	
	[window makeKeyAndVisible];
	// create instanse of my internet file manager

	[self addFilesToPlayList];
	[self deleteExtraObjectsFromDataBase];
	NSLog(@"******************** after adding songs form DB and into player, the player count is %i",[[avc fileList] count]);
	[self downloadFiles];
	
	// add listeners

	[fm release];
	//[NSThread detachNewThreadSelector:@selector(startParser) toTarget:self withObject:nil];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naturalEndOfSong) name:@"AVController_ItemPlaybackDidEnd" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerSkippedItemInPlayList) name:@"AVController_ItemFailedToPlay" object:nil];
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
	
	//[mainView.imgMeter setHidden:secondarViewState != voteNowView];
	//[mainView.imgNeedle setHidden:secondarViewState != voteNowView];	

	[mainView.imgInTheNews setHidden:secondarViewState != inTheNewsView];
	

	switch (state) {
		case inTheNewsView:
			//[mainView.lblBigTextView setText:@"10,000 Attend job fair at Dodger Stadium. \n A Crowd of about 10,000 came to Dodger stadium over the weekend, but they weren't there for a baseball game"];
			//coordinates = CGRectMake(0,20,312,95);
			[mainView displayNewsView];
			break;
		case pollView:
			[mainView.lblBigTextView setText:@"Should alcohol have a minimum price?"];
			coordinates = CGRectMake(0,10,317,30);
			break;
		case voteNowView:
			[mainView askForVote];
			
			//[mainView.lblBigTextView setText:@"Have your say about the music we play"];
			coordinates = CGRectMake(0,0,185,63);
			break;
		case chatView:
			//[mainView.lblBigTextView setText:@"mac1212: This songs rocks \n john212: Yes, for girls \n cynthia: No, it is great !!"];
			//coordinates = CGRectMake(0,0,312,95);
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
	currentSongIndex = currentSongIndex > [mediaItems count] ? 0 : currentSongIndex;
	[self displaySongInfo:(-1)];
	[[mainView forwardButton] setEnabled:FALSE];
	[[mainView hateItButton] setEnabled:FALSE];	
}

- (void) naturalEndOfSong{
	NSLog(@"Natural end of song called");
	//[mainView.imgMain setImage:[UIImage imageNamed:@"Default.png"]];
	currentSongIndex ++;
	currentSongIndex = currentSongIndex > [mediaItems count] ? 0 : currentSongIndex;
	[self displaySongInfo:currentSongIndex];	[[mainView forwardButton] setEnabled:FALSE];
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

	//NSLog(@"PlayNextItem and currentSongIndex after while loop = %i",currentSongIndex);

	[[mainView forwardButton] setEnabled:FALSE];
	[[mainView hateItButton] setEnabled:FALSE];	
	waitAfterSkipClickedTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kSecondsToAllowForwardClick) target:self selector:@selector(enableSkipping) userInfo:nil repeats:NO];
	
	currentSongIndex ++;
	currentSongIndex = currentSongIndex > [mediaItems count] ? 0 : currentSongIndex;
	[self displaySongInfo:currentSongIndex];
	
	//[self displayPopUp:FALSE];
//	if (popUpTimer) {
//		[popUpTimer	invalidate];
//		popUpTimer = nil;
//	}	
}

- (void)  playSong { /*
	if (!avc) {
		avc= [[APAudioPlayer alloc] initWithCrossFadeSeconds:2000 repeatPlayList:YES withFadeInOutOnSkip:YES];
		avc.parent = self;
		[avc setVolume:1.0];
	}
	else {
		if ([avc isPlaying]) [avc stop];
	}
	[avc play]; */
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
	if ([[avc fileList] count] > 1 ) {
		[avc play];
	} else {
		[self displayAlert:@"The application is still loading files, please try again in a few seconds"];
		return;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:mainView cache:YES];
	[mainView.stationsView removeFromSuperview];
	[mainView addSubview:mainView.radioInterface];
	[UIView commitAnimations];
	
	
	//[self displaySongInfo:0];
	self.currentSongIndex = -1;
	/* Start the secondary view flipping */
	changeSecondaryViewTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / ksecondsToChangeSecondaryView) target:self selector:@selector(timerChangeSecondaryView) userInfo:nil repeats:YES];
	
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

- (void) parsePlayListFromServer {
	
	NSMutableArray *tempArray  = [[NSMutableArray alloc] init];
	NSMutableArray *tempArray2 = [[NSMutableArray alloc] init];
	
	NSString *url  = [NSString stringWithFormat:@"%@/%@/%@/%@.XML",@"http://media2.goomradio.com/MATIERE/CONDUCTEUR/7",year, dayOfTheYear, hourOfDay];
	
	NSString *url2 = [NSString stringWithFormat:@"%@/%@/%@/%@.XML",@"http://media2.goomradio.com/MATIERE/CONDUCTEUR/7",year, dayOfTheYear, hourOfDay2];
	NSLog(@"The url is %@", url);
	NSLog(@"The url2 is %@", url2);
	
	NSString *feedURLString = @"http://wavem.mobi/goom/playlist173/plist11.xml";

	

//	NSString *feedURLString  = url;
	NSString *feedURLString2 = url2;
	
	if (tempMediaItem == nil) {
		//NSLog(@"The tempMediaItem is nil, creating one");
		tempMediaItem = [MediaItem alloc];
	}
	
	TreeNode *goomPlayList	= [[XMLParser sharedInstance] parseXMLFromURL:[NSURL URLWithString:feedURLString]];
	//[goomPlayList dump];
	TreeNode *goomPlayList2 = [[XMLParser sharedInstance] parseXMLFromURL:[NSURL URLWithString:feedURLString2]];
	// Error handling
	if (goomPlayList == nil || goomPlayList2 == nil) {
		//[self reportAppError:@"Fetching rdmlClientData"];
		return;
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    
						   @"primaryKey",			@"item_uid", 
                           @"objectId",				@"id_objectid",
                           @"mediaId",				@"id_mediaid",
						   @"type",					@"id_type",
						   @"coverObjectId",		@"cover_objectid",
						   @"coverMediaId",			@"cover_mediaid",
						   @"coverUrl",				@"cover_url",
						   @"posEnd",				@"posend",
						  @"posStart",				@"posstart",
						  @"posFadeIn",				@"posfadein",
						  @"posChain",				@"poschain",
						   @"mediaDuration",		@"duration",
						  @"posFadeOut",			@"posfadeout", nil];
    
    tempArray  = [[[goomPlayList objectForKey:@"datas"] objectForKey:@"items"] createArrayForKey:@"item" withObject:tempMediaItem withTranslationTable:dict];
	tempArray2 = [[[goomPlayList2 objectForKey:@"datas"] objectForKey:@"items"] createArrayForKey:@"item" withObject:tempMediaItem withTranslationTable:dict];
	NSLog(@"The temparray 1 has %i elements",[tempArray count]);
	NSLog(@"The temparray 2 has %i elements",[tempArray2 count]);
	NSLog(@"Before the first parse the mediaitems count is %i", [mediaItems count]);
	[self updateMediaItemsFromParsedData:tempArray];
	NSLog(@"After the first parse the mediaitems count is %i", [mediaItems count]);
	//[self updateMediaItemsFromParsedData:tempArray2];
	NSLog(@"After the second parse the mediaitems count is %i", [mediaItems count]);
	
//	self.playListsDate = [[goomPlayList objectForKey:@"datas"] attributeValueForKey:@"items" forAttribute:@"date"];
	
//	NSLog(@"============= The playList date is %@", playListsDate);
	
}

- (void) updateMediaItemsFromParsedData:(NSArray*)tempArray {
	
	NSInteger searchIndex;
	NSMutableString *imageIdAsPath;
	NSString *imageIdAsString;
	
	//NSDate *now = [[NSDate alloc] init];
	NSDate *songTime = [[NSDate alloc] init];
	
	for (int t = 0; t < [tempArray count]; t++) {
		/* Check if this object was already in database, if so, update it, other wise, insert it. */
		searchIndex = [self searchForObjectIndexWithMediaId:[[tempArray objectAtIndex:t] mediaId] fromArray:mediaItems];
		
		//goom/mediaid.aac
		
		/* create audio links of the song */
		//[[tempArray objectAtIndex:t] setAudio_source:[NSString stringWithFormat:@"%@_%i_%i/AAC_64",@"http://store.goomradio.com/audio/2",[[tempArray objectAtIndex:t] objectId],[[tempArray objectAtIndex:t] mediaId]]];
		//[[tempArray objectAtIndex:t] setPosFadeOut:([[tempArray objectAtIndex:t] posFadeOut] - 200)];
		//[[tempArray objectAtIndex:t] setPosStart:0];
		//NSLog(@"**** The handle for the audio is %@",[[tempArray objectAtIndex:t] audio_source]);
		[[tempArray objectAtIndex:t] setAudio_source:[NSString stringWithFormat:@"http://wavem.mobi/goom/%i.aac",[[tempArray objectAtIndex:t] mediaId]]];
		
		/* If posFadeOut = 0 then make it duration - 200 */
		//NSLog(@"============= The posFade was %i, and duration = %i",[[tempArray objectAtIndex:t] posFadeOut] , [[tempArray objectAtIndex:t] mediaDuration]);
		//if ([[tempArray objectAtIndex:t] posFadeOut] == 0 || [[tempArray objectAtIndex:t] posFadeOut] == [[tempArray objectAtIndex:t] mediaDuration]) {
		//	[[tempArray objectAtIndex:t] setPosFadeOut:([[tempArray objectAtIndex:t] mediaDuration] - 200)];
		//	NSLog(@"============= The posFade was %i, and duration = %i, so I changed it to %i",([[tempArray objectAtIndex:t] posFadeOut] + 200), [[tempArray objectAtIndex:t] mediaDuration], [[tempArray objectAtIndex:t] posFadeOut]);
		//}
		/*  */
				
		/* create image link */
		imageIdAsString = [NSString stringWithFormat:@"%i",[[tempArray objectAtIndex:t] coverObjectId]] ;
		imageIdAsPath = [[NSMutableString alloc] init];
		
		for (int r = 0; r < [imageIdAsString length]; r++) {
			if (r < [imageIdAsString length]) [imageIdAsPath appendString:[NSString stringWithFormat:@"%@/",[imageIdAsString substringWithRange:NSMakeRange(r , 1)]]];
		}
		
		[[tempArray objectAtIndex:t] setImage_source:[NSString stringWithFormat:@"http://media.goomradio.com/MATIERE/OBJET/%@IMAGE/%i.420.JPG",(NSString*)imageIdAsPath, [[tempArray objectAtIndex:t] coverMediaId]]];
		//NSLog(@"ObjectId translation, original = %@ and the result = %@", imageIdAsString, imageIdAsPath);
		
		songTime =[[NSDate alloc] initWithString:[NSString stringWithFormat:@"%@-%@-%@ %@ %@",year, monthOfYear, dayOfMonth,[[tempArray objectAtIndex:t] hour], timeZoneOffset]];
		
		/* Skip incomplete media files */
		if ([[tempArray objectAtIndex:t] mediaId] == 0) continue;
		if ([[tempArray objectAtIndex:t] objectId] == 0 ) continue;
	//	if ([songTime earlierDate:now] == songTime) continue;
		
		/* Check if this object was already in database, if so, update it, other wise, insert it. */
		if (searchIndex == -1) { 
			[[tempArray objectAtIndex:t] setIsActiveItem:TRUE];
			[[tempArray objectAtIndex:t] insertIntoDatabase:database];
			[mediaItems addObject:[tempArray objectAtIndex:t]];	
		} else {
			[[mediaItems objectAtIndex:searchIndex] setIsActiveItem:TRUE];
			[[mediaItems objectAtIndex:searchIndex] setHour:[[tempArray objectAtIndex:t] hour]];
			[[mediaItems objectAtIndex:searchIndex] setObjectId:[[tempArray objectAtIndex:t] objectId]];
			[[mediaItems objectAtIndex:searchIndex] setType:[[tempArray objectAtIndex:t] type]];
			[[mediaItems objectAtIndex:searchIndex] setCoverObjectId:[[tempArray objectAtIndex:t] coverObjectId]];
			[[mediaItems objectAtIndex:searchIndex] setCoverMediaId:[[tempArray objectAtIndex:t] coverMediaId]];
			[[mediaItems objectAtIndex:searchIndex] setCoverUrl:[[tempArray objectAtIndex:t] coverUrl]];
			[[mediaItems objectAtIndex:searchIndex] setTitle:[[tempArray objectAtIndex:t] title]];
			[[mediaItems objectAtIndex:searchIndex] setArtist:[[tempArray objectAtIndex:t] artist]];
			[[mediaItems objectAtIndex:searchIndex] setAlbum:[[tempArray objectAtIndex:t] album]];
			[[mediaItems objectAtIndex:searchIndex] setMediaDuration:[[tempArray objectAtIndex:t] mediaDuration]];
			[[mediaItems objectAtIndex:searchIndex] setPosStart:[[tempArray objectAtIndex:t] posStart]];
			[[mediaItems objectAtIndex:searchIndex] setPosFadeIn:[[tempArray objectAtIndex:t] posFadeIn]];
			[[mediaItems objectAtIndex:searchIndex] setPosChain:[[tempArray objectAtIndex:t] posChain]];
			[[mediaItems objectAtIndex:searchIndex] setPosFadeOut:[[tempArray objectAtIndex:t] posFadeOut]];
			[[mediaItems objectAtIndex:searchIndex] setPosEnd:[[tempArray objectAtIndex:t] posEnd]];
			//[[mediaItems objectAtIndex:searchIndex] setImage_handle:[[tempArray objectAtIndex:t] image_handle]];
			//[[mediaItems objectAtIndex:searchIndex] setAudio_handle:[[tempArray objectAtIndex:t] audio_handle]];
			[[mediaItems objectAtIndex:searchIndex] updateMediaItem:database];
		}
		
		/*
		 NSLog(@"'****************");
		 
		 NSLog(@"%i) pk= %i, hour= %@, objectId = %i, mediaId=%i,  type= %@, coverObjectId = %i, coverMediaId=%i, image_handle=%@, audio_handle = %@, audio_source = %@, image_source = %@", t,
		 [[tempArray objectAtIndex:t] primaryKey],
		 [[tempArray objectAtIndex:t] hour],
		 [[tempArray objectAtIndex:t] objectId],
		 [[tempArray objectAtIndex:t] mediaId],
		 [[tempArray objectAtIndex:t] type],
		 [[tempArray objectAtIndex:t] coverObjectId],
		 [[tempArray objectAtIndex:t] coverMediaId],
		 [[tempArray objectAtIndex:t] image_handle],
		 [[tempArray objectAtIndex:t] audio_handle],
		 [[tempArray objectAtIndex:t] audio_source],
		 [[tempArray objectAtIndex:t] image_source]
		 
		 );
		 
		 NSLog(@" coverUrl= %@, title= %@, artist = %@, album=%@,  duration= %i, posStart = %i, posfadein=%i, poschain= %i, posfadeout=%i, posend=%i",
		 [[tempArray objectAtIndex:t] coverUrl],
		 [[tempArray objectAtIndex:t] title],
		 [[tempArray objectAtIndex:t] artist],
		 [[tempArray objectAtIndex:t] album],
		 [[tempArray objectAtIndex:t] mediaDuration],
		 [[tempArray objectAtIndex:t] posStart],
		 [[tempArray objectAtIndex:t] posFadeIn],
		 [[tempArray objectAtIndex:t] posChain],
		 [[tempArray objectAtIndex:t] posFadeOut],
		 [[tempArray objectAtIndex:t] posEnd]);
		 */
	}
	
}

- (NSInteger)    searchForObjectIndexWithMediaId:(int)pk fromArray:(NSMutableArray*)array{
    NSInteger foundIndex = -1;
    
    if ([array count] == 0) return -1;

    for (int t = 0; t < [array count]; t++) {
		//NSLog(@"Searching for mediaId = %i and the current item has %i",pk,[[array objectAtIndex:t] mediaId]);
		
        if ([[array objectAtIndex:t] mediaId] == pk) {
            foundIndex = t;
		//	NSLog(@"ITS A MATCH");
            break;
        }// else NSLog(@"No Match");
    }
    return foundIndex;
}

- (void) reportAppError:(NSString*)errorSource {
    NSString *errorMessage = errorSource;
    [self displayAlert:errorMessage];
    NSLog(errorMessage);
}

/* Display common pop up alert */
- (void)displayAlert: (NSString*)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [alert show];
    [alert release];
}

- (void) loadObjectsFromDataBase:(NSString*)path {
	char *str = nil;
	NSDate *myDate = [NSDate date] ;
	NSString *year = [myDate descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil] ;
	NSString *dayOfTheYear=[myDate descriptionWithCalendarFormat:@"%j" timeZone:nil locale:nil] ;
	NSString *hourOfDay =[myDate descriptionWithCalendarFormat:@"%H" timeZone:nil locale:nil] ;
	NSString *monthOfYear =[myDate descriptionWithCalendarFormat:@"%m" timeZone:nil locale:nil] ;
	NSString *dayOfMonth =[myDate descriptionWithCalendarFormat:@"%d" timeZone:nil locale:nil] ;
	NSString *timeZoneOffset =[myDate descriptionWithCalendarFormat:@"%z" timeZone:nil locale:nil] ;
	
	NSDate *now = [[NSDate alloc] init];
	NSDate *songTime = [[NSDate alloc] init];
	
	
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		
		// *************** Get values for mediaItems. *********************
        const char *sql = "select id, hour, object_id, media_id, cover_object_id, cover_media_id,title, artist, album, duration, posstart, posfadein, poschain, posfadeout, posend, cover_url, image_downloaded, audio_downloaded, image_handle, audio_handle, image_source, audio_source from media_items";
		
        sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
			    int rKey					= sqlite3_column_int(statement, 0);
				str = (char *)sqlite3_column_text(statement, 1);
				NSString *rHour	=(str) ? [NSString stringWithUTF8String:str] : @"";
				//NSString *rHour				=((char *)sqlite3_column_text(statement,1)) ? [NSString stringWithUTF8String:str] : @"";
				int rObject_id				= sqlite3_column_int(statement, 2);
				int rMedia_id				= sqlite3_column_int(statement, 3);
				int rCover_object_id		= sqlite3_column_int(statement, 4);
				int rCover_media_id			= sqlite3_column_int(statement, 5);
				
				str = (char *)sqlite3_column_text(statement, 6);
				NSString *rTitle	=(str) ? [NSString stringWithUTF8String:str] : @"";
				str = (char *)sqlite3_column_text(statement, 7);
				NSString *rArtist	=(str) ? [NSString stringWithUTF8String:str] : @"";
				str = (char *)sqlite3_column_text(statement, 8);
				NSString *rAlbum	=(str) ? [NSString stringWithUTF8String:str] : @"";
			
				int rDuration				= sqlite3_column_int(statement, 9);
				int rPosstart				= sqlite3_column_int(statement, 10);
				int rPosfadein				= sqlite3_column_int(statement, 11);
				int rPoschain				= sqlite3_column_int(statement, 12);
				int rPosfadeout				= sqlite3_column_int(statement, 13);
				int rPosend					= sqlite3_column_int(statement, 14);
				str = (char *)sqlite3_column_text(statement, 15);
				NSString *rCoverUrl	=(str) ? [NSString stringWithUTF8String:str] : @"";
				
				int rImageDownloaded		= sqlite3_column_int(statement, 16);
				int rAudioDownloaded		= sqlite3_column_int(statement, 17);
				
				str = (char *)sqlite3_column_text(statement, 18);
				NSString *rImageHandle	=(str) ? [NSString stringWithUTF8String:str] : @"";
				
				str = (char *)sqlite3_column_text(statement, 19);
				NSString *rAudioHandle	=(str) ? [NSString stringWithUTF8String:str] : @"";
				
				str = (char *)sqlite3_column_text(statement, 20);
				NSString *rImageSource	=(str) ? [NSString stringWithUTF8String:str] : @"";
				
				str = (char *)sqlite3_column_text(statement, 21);
				NSString *rAudioSource	=(str) ? [NSString stringWithUTF8String:str] : @"";
				
				MediaItem *mediaItem = [[MediaItem alloc] init];
				[mediaItem setPrimaryKey:rKey];
				[mediaItem setHour:rHour];
				[mediaItem setObjectId:rObject_id];
				[mediaItem setMediaId:rMedia_id];
				[mediaItem setCoverMediaId:rCover_object_id];
				[mediaItem setCoverObjectId:rCover_media_id];
				[mediaItem setTitle:rTitle];
				[mediaItem setArtist:rArtist];
				[mediaItem setAlbum:rAlbum];
				[mediaItem setMediaDuration:rDuration];
				[mediaItem setPosStart:rPosstart];
				[mediaItem setPosFadeIn:rPosfadein];
				[mediaItem setPosChain:rPoschain];
				[mediaItem setPosFadeOut:rPosfadeout];
				[mediaItem setPosEnd:rPosend];
				[mediaItem setDatabase:database];
				[mediaItem setCoverUrl:rCoverUrl];
				[mediaItem setImage_downloaded:rImageDownloaded];
				[mediaItem setAudio_downloaded:rAudioDownloaded];
				[mediaItem setAudio_handle:rAudioHandle];
				[mediaItem setImage_handle:rImageHandle];
				[mediaItem setImage_source:rImageSource];
				[mediaItem setAudio_source:rAudioSource];
				
				songTime =[[NSDate alloc] initWithString:[NSString stringWithFormat:@"%@-%@-%@ %@ %@",year, monthOfYear, dayOfMonth,[mediaItem hour], timeZoneOffset]];
				
			//	if ([songTime earlierDate:now] == songTime) {
					
					//NSLog(@"fetched song from db was too old, skipping ");					
			//	} else {
					//NSLog(@"fetched song from db was good ");					
					[mediaItems addObject:mediaItem];
			//	}
				[mediaItem release];
				
				// if this media item has both downlaods complete then encrease our completed media items variable
				//if ([mediaItem image_downloaded] == TRUE && [mediaItem audio_downloaded] == TRUE) {
//					readyToPlayMediaCount++;
//				}
			}
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
//[mainView.forwardButton setText:[NSString stringWithFormat:@""
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
			//[myFileManager addToQueue:[mediaItems objectAtIndex:presentIndex]];
			//[[mediaItems objectAtIndex:presentIndex] setIsAddedToDownloadQueue:TRUE];
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
	feedURLString = @"http://orange.wavem.com/RadioAdminPHP/iphone_media_item.php?clock_id=13";
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
	feedURLString =  @"http://orange.wavem.com/RadioAdminPHP/iphone_clock.php?clock_id=13";
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
	
	//[self performSelectorOnMainThread:@selector(initPlayer) withObject:nil waitUntilDone:NO];
	
	//NSLog(@"Ended Parser succesfully");
	[pool release];
}

- (void) checkForReadyItems:(NSString *)readyFile {
	NSLog(@"Checking for ready items and the one sent was %@", readyFile);
	//return;
	//NSString * newReadyItem = [myFileManager getReadyItem];
	//while (newReadyItem !=  @"") {
	//	NSLog(@"Checking for ready Items: found one %@ ", newReadyItem);
	//[self markReadyDownload:readyFile];
		//NSLog(@"After this new download the songsArray count is %i", [songsArray count]);
		//newReadyItem = [myFileManager getReadyItem];
	//}
	[mainView.viewCurrentDownload setText: [myFileManager downloadFileNewName]];
}

- (void) markReadyDownload:(DownloadObject*)download {
	NSString *addedFile;
	AudioFile *newFile;
	float progressValue;
	double finalProgress;
	
	NSLog(@"A file jhas finished downloading");
    if (download == nil) NSLog(@"Object came but empty");
    
    if ([[download ownerName] isEqualToString:@"MediaItem"] && [[download mediaType] isEqualToString:@"image"])     {
        NSLog(@"Image has been downlaoded, marking it on DB %@", [download newName]);
		//[[mediaItems objectAtIndex:[download ownerIndex]] setImageLink:[download newName]];
        [[mediaItems objectAtIndex:[download ownerIndex]] setImage_downloaded:TRUE];
		[[mediaItems objectAtIndex:[download ownerIndex]] setImage_handle:[download newName]];
        [[mediaItems objectAtIndex:[download ownerIndex]] updateMediaItem:database];
	}
	
	if ([[download ownerName] isEqualToString:@"MediaItem"] && [[download mediaType] isEqualToString:@"audio"])     {
        NSLog(@"Audio has been downlaoded, marking it on DB %@", [download newName]);
		//[[mediaItems objectAtIndex:[download ownerIndex]] setImageLink:[download newName]];
        [[mediaItems objectAtIndex:[download ownerIndex]] setAudio_downloaded:TRUE];
		[[mediaItems objectAtIndex:[download ownerIndex]] setAudio_handle:[download newName]];
        [[mediaItems objectAtIndex:[download ownerIndex]] updateMediaItem:database];
	}
	
	if ([[mediaItems objectAtIndex:[download ownerIndex]] image_downloaded] == TRUE && [[mediaItems objectAtIndex:[download ownerIndex]] audio_downloaded] == TRUE) {
		addedFile = [NSString stringWithFormat:@"%@/%@", self.recordingDirectory, [[mediaItems objectAtIndex:[download ownerIndex]] audio_handle]];
		NSLog(@"MARKDOWNLOAD: Adding new file to play list with url = %@", addedFile);
		NSLog([NSString stringWithFormat:@"Song information: Pos start %d pos fade %d and pos chain %d and duration: %d", 
			   [[mediaItems objectAtIndex:[download ownerIndex]]posStart], [[mediaItems objectAtIndex:[download ownerIndex]] posFadeOut], [[mediaItems objectAtIndex:[download ownerIndex]] posChain] , [[mediaItems objectAtIndex:[download ownerIndex]] posEnd]]);
		newFile = [[AudioFile alloc] initWithFileURL:addedFile 
										  withOffset:[[mediaItems objectAtIndex:[download ownerIndex]]posStart]
							andWithFadeOutMilisecond:[[mediaItems objectAtIndex:[download ownerIndex]] posFadeOut] 
									 andWithPosChain:[[mediaItems objectAtIndex:[download ownerIndex]] posChain] 
										withDuration: [[mediaItems objectAtIndex:[download ownerIndex]] posEnd] 
										   withImage: [[mediaItems objectAtIndex:[download ownerIndex]] image_handle]
										   withTitle: [[mediaItems objectAtIndex:[download ownerIndex]] title]
									   andWithSinger:[[mediaItems objectAtIndex:[download ownerIndex]] artist]];
		[avc addAudioToPlayList:newFile];	
		
		progressValue =  ((([[avc fileList] count] * 100) / [mediaItems count])) ;
		finalProgress = (double) progressValue /100;
		[mainView setProgress:(float)finalProgress];
		
	}
}

- (void) displaySongInfo:(NSInteger)songIndex {
	/*
	if ((int)songIndex == -1) 
		self.currentSongIndex = songIndex = (self.currentSongIndex + 1) % [mediaItems count];
	//NSLog(@"DisplaySongInfo sonidex = %i and mediaitems count is %i",([songIndex intValue]), [mediaItems count]);
	// Get the information about the media item
    NSString *imgHandle    = [[self.mediaItems objectAtIndex:(int)songIndex] image_handle];
	NSString *mediaName    = [[self.mediaItems objectAtIndex:(int)songIndex ] title];
//	NSString *lyricsText   = [[self.mediaItems songIndex ] lyrics];
	NSString *Artist       = [[self.mediaItems objectAtIndex:(int)songIndex ] artist];
	
	//lyricsText = ([lyricsText length] == 0) ? @"No lyrics available" : lyricsText;
	//self.currentSongId = [[mediaItems objectAtIndex:([songIndex intValue])] primaryKey];
	
	// change displays on views
	mainView.forwardButton.titleLabel.text =[[self.mediaItems objectAtIndex:(int)songIndex] title];
	[mainView.lblLyricsTitle setText:mediaName];
	//[mainView.viewLyrics   setText:lyricsText];
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
	//if (img) {[img release];}*/
	
	// check to see if this song has a popup associated with it.
//	if ([[[self.mediaItems objectAtIndex:([songIndex intValue])] popUpHandle] length] != 0) {
//		//NSLog(@"This song has an popUp called %@",[[self.mediaItems objectAtIndex:([songIndex intValue])] popUpHandle]);
//		// activate the popUpTimer
//		popUpTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / ksecondsBeforePopUpDisplay) target:self selector:@selector(popUpTimerAction) userInfo:nil repeats:NO];
//	}
}

- (void) initPlayer {	

	avc = [[APAudioPlayer alloc] initWithRepeatPlayList:YES withFadeInOutOnSkip:YES];
	avc.parent = self;
	[avc setVolume:1.0];
}

- (void) syncAudioPlayList {

	
}

- (void) addPopUpsToPlayList {
	//int				totalPopUps =  [popUpItems count];
//	int				currentPopUpIndex = 0;
//	int				totalMediaItems = [mediaItems count];
//	int				taggedTotal = kPopUpRate * totalMediaItems / 100; 
//	int				tagged = 0;
//	NSUInteger		randomPick;
//	
//	//NSLog(@"taggedTotal = %i",taggedTotal);
//	while (tagged < taggedTotal) {
//		randomPick = random() % totalMediaItems;
//		if ([[[mediaItems objectAtIndex:randomPick] popUpHandle] length] == 0) {
//			//NSLog(@"The popUpHandle was empty tagged = %i and taggedTotal= %i, currentPopUpIndex = %i", tagged, taggedTotal,currentPopUpIndex);
//			[[mediaItems objectAtIndex:randomPick] setPopUpHandle:[[popUpItems objectAtIndex:currentPopUpIndex] handle]];
//			tagged++;
//			currentPopUpIndex++;
//			currentPopUpIndex = currentPopUpIndex % totalPopUps;
//		}
//	}	
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
