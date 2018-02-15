//
//  APCustomPlayer.m
//  AudioPlayer
//
//  Created by Tuan VU on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APCustomPlayer.h"
#import "HitMusicAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
@interface APCustomPlayer ()
- (void) displaySongInfo ;
- (void) display;
- (void) prepareSong;
@end

@implementation APCustomPlayer
@synthesize  error;
@synthesize delegate;

#define VOLUME_STEP 0.01
#define FADEOUT_WATCHDOG_TIME 0.1
#define FADEOUT_AUTOMATIC_TIME 0.1
#define WATCHDOG_TIME 0.1
#define PREPARE_NEXT_SONG_CONSTANT 0.5
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Initialize the player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------


- (id) initWithAudioFile : (AudioFile*) file {
	if (file) {
		
		[super initWithContentsOfURL:file.fileURL error:&error];
		
		// if song is damaged, return nil
		if (error) 		{
			NSLog(@"***********************************  Damaged song ************************************ /n File path: %a", file.fileURL);
			return nil;
		}
		isFaded = FALSE;
		isNextSongPrepared = FALSE;
		isNextSongPlay = FALSE;
		pool = [[NSAutoreleasePool alloc] init];
		Vol = self.volume;
		audioFile = file;
		[self performSelector:@selector(prepareSong) withObject:nil];
		return self;
	}
	else return nil;
}


//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Fade out when stopping playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) fadeOut {
	self.volume = Vol;
	if (volumeThread && [volumeThread isExecuting]) {
		[volumeThread cancel];
		[volumeThread release];
	}
	volumeThread = [[NSThread alloc] initWithTarget:self selector:@selector(fadeOutThread) object: nil];
	[volumeThread start];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method call by fadeOut method
- (void) fadeOutThread {
	if (fadingTime < 0.1) return;
	//NSLog(@"PLAYER: Fading out because of: %f > %d or %f - %f> %f", [self currentTime], audioFile.fadeOutTime, [self duration], [self currentTime], FADEOUT_AUTOMATIC_TIME);
	// starting decrease until we reach volume 0
	while (self.volume >0.0) {
		self.volume -= 1.05*VOLUME_STEP;
		[NSThread sleepForTimeInterval:fadingTime*VOLUME_STEP];
	}
	self.volume = 0.0; // stabilize the fade out
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Start guarding for fading out
//-----------------------------------------------------------------------------------------------------------------------------

- (void) startFadeOutWatchDog {
	if (audioFile.willFadeWhenStop) {
		if (!fadingWatchDog) {
			fadingWatchDog = [[NSThread alloc] initWithTarget:self selector:@selector(fadeOutWatchDogThread) object:nil];
		}
		[fadingWatchDog start];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Start guarding for events
//-----------------------------------------------------------------------------------------------------------------------------

- (void) startWatchDog {
	
	if (!watchDog) {
		watchDog = [[NSThread alloc] initWithTarget:self selector:@selector(watchDogThread) object:nil];
	}
	[watchDog start];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Guarding for fading out

- (void) fadeOutWatchDogThread {
	NSLog(@"PLAYER: Fadeout watchdog started");
	while (!isFaded && ([self currentTime] < [self duration])) {
		// when current playback position reach the fade out timer or current time reaching end of song
		if (([self currentTime] > audioFile.fadeOutTime) || ([self duration] - [self currentTime] < FADEOUT_AUTOMATIC_TIME)) {
			fadingTime = [self duration] - [self currentTime];
			[self fadeOut];
			isFaded =  TRUE;
		}
		[NSThread sleepForTimeInterval:FADEOUT_WATCHDOG_TIME];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Guarding for events
		
- (void) watchDogThread {
	NSLog(@"PLAYER: Watchdog started.");
	while ([self currentTime] < [self duration]) {
		
		// tell the delegate to prepare for playing the next song
		if (!isNextSongPrepared && ([self currentTime] > PREPARE_NEXT_SONG_CONSTANT * [self duration]) ) {
			NSLog(@"PLAYER: Method playerShouldPrepareForNextSong triggered.");
			isNextSongPrepared = TRUE;
			if ([delegate respondsToSelector:@selector(playerShouldPrepareForNextSong)]) {
				[delegate playerShouldPrepareForNextSong];
			}
		}
		
		// tell the delegate to play next song
		if (!isNextSongPlay && ([self currentTime] > audioFile.posChain)) {
			NSLog(@"PLAYER: Method playerShouldStartPlayingNextSong triggerred.");
			isNextSongPlay = TRUE;
			if ([delegate respondsToSelector:@selector(playerShouldStartPlayingNextSong)]) {
				[delegate playerShouldStartPlayingNextSong];
			}
		}
		[NSThread sleepForTimeInterval:WATCHDOG_TIME];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: Play
// An replacement to orginial play method
// with fading in and out effect
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) Play {
	self.currentTime = audioFile.offset;
	[self play];
	[self startFadeOutWatchDog];
	[self startWatchDog];
	NSLog(@"PLAYER: Playing song with duration: %f", self.duration);
	[self displaySongInfo];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: Stop
// A replacement to original method
// !!! Must be used when playing using fading effect
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) Stop {
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: setVol
// set new volume

- (void) setVol: (double) newVolume {
	Vol = newVolume;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: dealloc

- (void) dealloc {
	[audioFile release];
	[pool release];
	[error release];
	[volumeThread release];
	[watchDog release];
	[fadingWatchDog release];
	[super dealloc];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Start displaying thread 
//-----------------------------------------------------------------------------------------------------------------------------

- (void) display {
	if (!watchDog) {
		watchDog = [[NSThread alloc] initWithTarget:self selector:@selector(displayThread) object:nil];
	}
	if (![watchDog isExecuting]) {
		[watchDog start];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Thread : display information after a period of time
//-----------------------------------------------------------------------------------------------------------------------------


- (void) displayThread {
	while (self. currentTime < self.duration /2)  {
		[self displaySongInfo];
		[NSThread sleepForTimeInterval:10.0];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: displaySongInfo
// called to display song ifformation from

- (void) displaySongInfo {
	
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	// change displays on views
	appDelegate.mainView.forwardButton.titleLabel.text =audioFile.title;
	[appDelegate.mainView.lblLyricsTitle setText:audioFile.title];
	//[mainView.viewLyrics   setText:lyricsText];
	[appDelegate.mainView.lblSongName setText:audioFile.title];
	[appDelegate.mainView.lblArtistName setText:audioFile.artist];
	[appDelegate.mainView.lblLyricsArtist setText:audioFile.artist];
	[appDelegate.mainView.songLabel setText:audioFile.title];
	[appDelegate.mainView.singerLabel setText:audioFile.artist];
	// Change the main display image of the song
	NSString *imagePath = [NSString stringWithFormat: @"%@/%@", [appDelegate recordingDirectory], audioFile.imageURL] ;
	UIImage *img = [UIImage imageWithContentsOfFile:imagePath] ;
	CATransition * animation = [CATransition animation];
	[animation setType: kCATransitionFade];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[appDelegate.mainView layer] addAnimation:animation forKey:@"animation iamge"];
	[appDelegate.mainView.imgMain setImage:img];
}



- (void) prepareSong {
	[self prepareToPlay];
}
@end
