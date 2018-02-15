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
@synthesize fadeInOutOnSkip, repeatSong, repeatPlayList;
@synthesize fileList;
@synthesize isPaused;
@synthesize parent;

#define INDEX_STOP -1
#define DEFAULT_PLAYBACK_POSITION 0

//@synthesize player1, player2, activePlayer;
// init with options
- (id) initWithCrossFadeSeconds: (int) miliseconds 
				 repeatPlayList: (bool) repeatPL
			  //withAudioPlayList: (NSArray*) playList 
			withFadeInOutOnSkip: (bool) fadeInOut {
	[super init];
	pool = [[NSAutoreleasePool alloc] init];
	crossFadeMiliseconds	= miliseconds/1000.0;
	repeatPlayList		= repeatPL;
	//fileList			= (NSMutableArray*) playList;
	fileList			= [[NSMutableArray alloc] init];
	fadeInOutOnSkip		= fadeInOut;

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
	
	
	if (flag== YES) {
		[parent naturalEndOfSong];
		index = [self getNextPlayingIndex];
		if (index != INDEX_STOP) 
			if (fadeInOutOnSkip== TRUE) {
				NSTimeInterval duration, delay;
				//
				if (mainPlayer)
					[mainPlayer release];
				mainPlayer = [slavePlayer retain];
					
				duration = [mainPlayer duration];
					
				if (duration > 2*crossFadeMiliseconds ) delay = duration - 2 * crossFadeMiliseconds;
				else delay = duration;
					
				//NSLog([NSString stringWithFormat:@"%f, %f", delay, duration]);
				slavePlayer = [self initNewPlayer:index];
				[slavePlayer PlayAfter:delay];
			} else {
				mainPlayer = [self initNewPlayer:index];
				[mainPlayer Play];
			}
		
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

	// create new player 
	if (mainPlayer) {
		if ([mainPlayer isPlaying]||[mainPlayer isOnQueue]) {
			[mainPlayer Stop];
		}
		[mainPlayer release];
	}
	mainPlayer = [[ self initNewPlayer:index] autorelease];
		[mainPlayer  Play];
	// and scheduling next player
	if (fadeInOutOnSkip == TRUE) {
		NSLog([ NSString stringWithFormat: @"Enqueue next player in %f seconds", [mainPlayer duration] -10.0]);
		[self enqueueSlavePlayer];
		//[self performSelector:@selector(enqueueSlavePlayer) withObject: nil afterDelay: [mainPlayer duration] -10.0];
	}
}

- (void) enqueueSlavePlayer {
	index = [self getNextPlayingIndex];
	if (index != INDEX_STOP) {
		slavePlayer = [self initNewPlayer:index];
		NSTimeInterval delay = [mainPlayer duration]-[mainPlayer currentTime];
		if (fadeInOutOnSkip) delay -= crossFadeMiliseconds;
		//[slavePlayer setDelegate:self];
		[slavePlayer PlayAfter:delay];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: stop 
// Method will cancel all fading effect request
// and will stop players from playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) stop { 
	//[NSObject cancelPreviousPerformRequestsWithTarget:self];
	// if fading mode is on
	if (fadeInOutOnSkip) {
		// check if mainPlayer is not null
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
	else {
		[mainPlayer stop];	// if not, then only one is On
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: pause
// Method is used for temporary pause player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) pause { /*
	isPaused = YES;
	if (mainPlayer)
	[mainPlayer Pause];
	if (slavePlayer)
	[slavePlayer Pause];*/
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: pause
// Method is used for temporary pause player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) resume {/*
	isPaused = NO;
	if ([mainPlayer isResumable])
		[mainPlayer Play];
	if (slavePlayer && [slavePlayer isResumable]) {
		NSTimeInterval delay = [mainPlayer duration] -[mainPlayer currentTime];
		if (fadeInOutOnSkip) delay -= crossFadeSeconds;
		//[slavePlayer setDelegate:self];
		[slavePlayer PlayAfter:delay];
		//[slavePlayer Play];
	}*/
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: pause
// Method is used for temporary pause player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) skipBack {
	index = [self getPreviousPlayingIndex];
	[self stop];
	[self play];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: pause
// Method is used for temporary pause player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) skipForward {
	 index = [self getNextPlayingIndex];
	if ([self isPlaying]) 
	[self stop];
	[self play];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: pause
// Method is used for temporary pause player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) playAudioAtIndex: (int) audioIndex {
	
}
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: pause
// Method is used for temporary pause player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) setCrossFade: (bool) setCFade withSeconds: (double) miliseconds {
	[self stop];
	crossFadeMiliseconds = miliseconds;
	fadeInOutOnSkip = setCFade;
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
// Method name: getAudioTimeLength
// Get length of the audio in seconds
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (NSTimeInterval) getAudioTimeLength {
	APCustomPlayer * player = [[self getMainPlayer] autorelease];
	if (player) return [player duration];
	else
		return 0;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: getAudioTimeRemaining
// Get time remaining of the current playing audio
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (NSTimeInterval) getAudioTimeRemaining {
	APCustomPlayer * player = [[self getMainPlayer] autorelease];
	if (player) return [player duration] - [player currentTime];
	else
		return 0;
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
// Method name: setFading (bool)
// change fading mode of the player
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) setFading: (bool) sender {
	[self stop];
	fadeInOutOnSkip = sender;
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
	AudioFile *tempFile = [fileList objectAtIndex:newIndex];
	/*APCustomPlayer *player =  [[[APCustomPlayer alloc] initWithContentOfUrl: tempFile.fileURL
													withOffsetInMiliseconds: tempFile.offset
															  andFadingMode: tempFile.willFadeWhenStop
																  inSeconds: tempFile.fadeOutTime/1000] retain];*/
	APCustomPlayer *player = [[[APCustomPlayer alloc] initWithAudioFile:tempFile] retain];
	player.delegate = self;
	[player setVol:[self getVolume]];
	[player prepareToPlay];
	//[tempFile release];
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

@end
