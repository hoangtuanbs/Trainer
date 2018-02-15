//
//  APAudioPlayer.m
//  AudioPlayer
//
//  Created by Tuan VU on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APAudioPlayer.h"
#import "HitMusicAppDelegate.h"
#import "AudioFile.h"

@interface APAudioPlayer (Private)
- (void) enqueueSlavePlayer;
@end


@implementation APAudioPlayer
@synthesize repeatSong, repeatPlayList;
@synthesize fileList;
@synthesize isPaused;
@synthesize parent;

#define INDEX_STOP -1
#define DEFAULT_PLAYBACK_POSITION 0

//@synthesize player1, player2, activePlayer;
// init with options
- (id) initWithRepeatPlayList: (bool) repeatPL
			withFadeInOutOnSkip: (bool) fadeInOut {
	[super init];
	pool = [[NSAutoreleasePool alloc] init];
	repeatPlayList		= repeatPL;

	fileList			= [[NSMutableArray alloc] init];


	error = [[NSError alloc] init];
	audioSession = [AVAudioSession sharedInstance];
	
	// enable multiple sound playing
	//[session setCategory:AVAudioSessionCategoryPlayback error:&error];
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
	[audioSession setActive:TRUE error:&error];
	
	// set playback position to default
	index = DEFAULT_PLAYBACK_POSITION;
	isPaused = NO;
	return self;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// MEthod name: addAudioToPlayList
// this is called to add more file to playing list
// it will check whether there are songs to play next and schedule next playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) addAudioToPlayList: (AudioFile*) file {
	[fileList addObject: file]; 
	NSLog(@"PLAYER MANAGER: Added item to play list and total song is %i",[fileList count]);
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Remove songs from play list
// this is called whenever song stop
// it will check whether there are songs to play next and schedule next playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) removeAudioFromPlayList: (NSURL*) audioFile {
	int i , n = [ fileList count] ;
	for (i = 0; i< n; i++)  {
		if ([[[fileList objectAtIndex:i] absoluteString] isEqualToString:[audioFile absoluteString]]) {
			[fileList removeObjectAtIndex:i];
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: clearPlayList
// this is called to clear playing list
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) clearPlayList {
	[fileList removeAllObjects];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Private methods: getNextPlayingIndex 
// Called to get next song index accordinly to current song position.
// will return INDEX_STOP when there are no song to play
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (int) getNextPlayingIndex {
	int x;
	if (repeatSong) x= index;
	else if (randomMode) x= index;
	else x= index+1;
	
	if (x >= [fileList count]) 
		if (repeatPlayList) x %= [fileList count];
		else x = INDEX_STOP;
	return x;
}

- (int) getPreviousPlayingIndex {
	int x;
	if (repeatSong) x= index;
	else if (randomMode) x= index;
	else x= index-1;
	
	if (x <0) 
		if (repeatPlayList) x = [fileList count] -1;
		else x = INDEX_STOP;
	return x;
}
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// APCustomPlayer Delegate methods
// this is called whenever song stop
// it will check whether there are songs to play next and schedule next playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void)audioPlayerDidFinishPlaying:(APCustomPlayer*)player successfully:(BOOL)flag {
	NSLog(@"********* audioPlayerDidFinishPlaying **************");
	
	if (flag== YES) {
	}
	
	else 
		[self play];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {

}


- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	
}


#pragma mark --
#pragma mark Component Main Methods
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: play
// This will play songs accordingly to the given playing mode
// It will release all current player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) play {
	if (mainPlayer) {
		if ([mainPlayer isPlaying]) {
			[mainPlayer Stop];
		}
		[mainPlayer release];
	}
	//index = [self getNextPlayingIndex];
	mainPlayer = [self initNewPlayer:index];
	[mainPlayer Play];
}


//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: stop 
// Method will cancel all fading effect request
// and will stop players from playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) stop { 

		if (mainPlayer) {
			tempPlayer = mainPlayer; // assign to an auto release pointer
			[tempPlayer Stop];
			[tempPlayer autorelease];
			mainPlayer = nil;	// and nil
		}
		if (slavePlayer) {
			index = [self getPreviousPlayingIndex];
			// if slave player is on
			[slavePlayer Stop];
			[slavePlayer autorelease];
		}

}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// get mainPlayer
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (APCustomPlayer *) getMainPlayer {
	return mainPlayer;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// get slave player
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (APCustomPlayer *) getSlavePlayer {
	return slavePlayer;
}


//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: setVolume
// Set new volume level
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) setVolume: (double) level {
	volume = level;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: getVolume
// Get current playing volume
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (double) getVolume {
	return volume;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: isPlaying
// return TRUE is there are player is playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (bool) isPlaying {
	if ([mainPlayer isPlaying]) return TRUE;
	else {
		return FALSE;
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: initNewPlayer: (NSInteger)
// create new player for playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (APCustomPlayer*) initNewPlayer: (NSInteger) newIndex {
	APCustomPlayer *player ;
	do {
		AudioFile *tempFile = [fileList objectAtIndex:newIndex];
		player = [[[APCustomPlayer alloc] initWithAudioFile:tempFile] retain];
		player.delegate = self;
		[player setVol:[self getVolume]];
		NSLog(@"PLAYER MANAGER: Initialized song %d", index);
		if (!player) {
			index = [self getNextPlayingIndex];
			NSLog(@"ERROR: PLAYER MANAGER: Cant initalize song %d", index);
		}
	}
	while (!player);
	return player;	
}




- (void) dealloc {
	[audioSession release];
	[mainPlayer release];
	[slavePlayer release];
	[fileList release];
	[pool release];
	[super dealloc];
}


- (void) playerShouldStartPlayingNextSong {
	NSLog(@"PLAYER MANAGER: Started playing next song.");
	if (tempPlayer) [tempPlayer release];
	tempPlayer = mainPlayer;
	mainPlayer = slavePlayer;
	slavePlayer = nil;
	
	[mainPlayer Play];
}

- (void) playerShouldPrepareForNextSong {
	NSLog(@"PLAYER MANAGER: Prepare for next song.");
	index = [self getNextPlayingIndex];
	slavePlayer = [self initNewPlayer:index];
}
@end
