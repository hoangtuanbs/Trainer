//
//  APCustomPlayer.m
//  AudioPlayer
//
//  Created by Tuan VU on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APCustomPlayer.h"


@implementation APCustomPlayer
@synthesize fading;
@synthesize  error;
@synthesize isResumable;
@synthesize isOnQueue;
#define VOLUME_STEP 0.01

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Initialize the player 
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (id) initWithContentOfUrl: (NSURL *) url withOffsetInMiliseconds: (NSInteger) off andFadingMode: (Boolean) fadingMode inSeconds: (double) seconds{
	error = [[NSError alloc] init];
	[super initWithContentsOfURL:url error:&error];
	NSLog([NSString stringWithFormat:@"File path: %@.", [url absoluteString]]);
	pool = [[NSAutoreleasePool alloc] init];
	fading  = fadingMode;
	fadingTime = seconds;
	Vol = self.volume;
	isResumable = NO;
	isOnQueue = NO;
	offset = off;
	self.currentTime = offset/1000.0;
	return self;
}

- (id) initWithAudioFile : (AudioFile*) file {
	if (file) {
		error = [[NSError alloc] init];
		[super initWithContentsOfURL:file.fileURL error:&error];
		//NSLog([NSString stringWithFormat:@"File path: %@.", [file.fileURL absoluteString]]);
		pool = [[NSAutoreleasePool alloc] init];
		fading  = file.willFadeWhenStop;
		fadingTime = file.fadeOutTime/1000.0;
		Vol = self.volume;
		isResumable = NO;
		isOnQueue = NO;
		offset = file.offset;
		self.currentTime = offset/1000.0;
		
		return self;
	}
	else return nil;
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Fade sound in when start playing
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) fadeIn {/*
	[self setVVol = [self volume];
	if (volumeThread && [volumeThread isExecuting]) {
		[volumeThread cancel];
		
		[volumeThread release];
	}*/
	/*
	volumeThread = [[NSThread alloc] initWithTarget:self selector:@selector(fadeInThread) object:nil] ;

	[volumeThread start];*/
	//[NSThread detachNewThreadSelector:@selector(fadeInThread) toTarget:self withObject:nil];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Internal fading thread
// called by Fade in
- (void) fadeInThread {
	/*
	self.volume = 0.0;
	while (self.volume < Vol) {
		self.volume += VOLUME_STEP;
		[NSThread sleepForTimeInterval:fadingTime*VOLUME_STEP];
	}*/
	self.volume = Vol;
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
		//[NSThread exit];
	}
	volumeThread = [[NSThread alloc] initWithTarget:self selector:@selector(fadeOutThread) object:nil];
	
	[volumeThread start];

}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method call by fadeOut method
- (void) fadeOutThread {
	
	while (self.volume >0.0) {
		//NSLog([NSString stringWithFormat:@"%f"]);
		//NSLog([NSString stringWithFormat:@"Volume reduced: %f", self.volume]);
		self.volume = [self volume]- 1.3*VOLUME_STEP;
		[NSThread sleepForTimeInterval:fadingTime*VOLUME_STEP];
	}
	self.volume = 0.0;
}


//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: Play
// An replacement to orginial play method
// with fading in and out effect
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) Play {
	isOnQueue = FALSE;
	isResumable = NO;
	// if fade mode in ON
	//NSLog(error)
	if (volumeThread)
		if ([volumeThread isExecuting]) [volumeThread cancel];
	if (fading && ([self duration] > 2*fadingTime)) {
		//[self fadeIn]; // fade in when start
		NSLog([NSString stringWithFormat:@"%f, %f", [self currentTime], [self duration]]);
		// fade out when stop
		[self performSelector:@selector(fadeOut) withObject: nil afterDelay: ([self duration]- [self currentTime] - fadingTime)];
	}
	[self play];
	
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: Stop
// A replacement to original method
// !!! Must be used when playing using fading effect
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------

- (void) Stop {
	isOnQueue = NO;
	if (fading && ([self duration] - [self currentTime] > fadingTime))  {
		if (![self isPlaying]) {
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector: @selector(Play) object: nil];		}
		// fade out
		[self fadeOut];
		//remove fade out timer
		[self performSelector: @selector(stop) withObject: nil afterDelay: fadingTime];
	}
	else {
		if (volumeThread)
			if ([volumeThread isExecuting]) [volumeThread cancel];
		[self stop];
	}
	//[self autorelease];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: SeekTo
// Seek to a new position
// Input: pos ranged from 0.0 to 1.0
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) SeekTo: (double) pos {
	[self pause];
	// remove fade out timer
	//(void)cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector: @selector(Play) object: nil];
	// set new position
	self.currentTime = pos* self.currentTime;
	[self Play];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: PlayAfter
// Play song after a particular delay with fading effect
// Input: delay
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) PlayAfter: (NSTimeInterval) delay {
	isOnQueue = TRUE;
	NSLog(@"Setting Queue to true");
	[self performSelector:@selector(Play) withObject: nil afterDelay: delay];
}


//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: PlayAfter
// Play song after a particular delay with fading effect
// Input: delay
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
- (void) Pause {
	isResumable = YES;
	if (volumeThread)
		if ([volumeThread isExecuting]) [volumeThread cancel];
	if (fading && ([self duration] - [self currentTime] > fadingTime))  {
		if (![self isPlaying]) [NSObject cancelPreviousPerformRequestsWithTarget:self selector: @selector(Play) object: nil];
		//[self fadeOut];
		[self pause];
		//[self performSelector:@selector(pause) withObject:nil afterDelay: fadingTime];
	}
	else  [self pause];
}
//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: increaseVolume
// Increase volume to new value 
// increase volume with fading effect
- (void) increaseVolume: (double) toVolume {
	//[NSThread detachNewThreadSelector:@selector(increaseVolumeThread:) toTarget:self withObject:((NSObject*)&toVolume)];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: increaseVolumeThread
// Internal thread used by increaseVolume
- (void) increaseVolumeThread: (double) toVolume {
	while (self.volume < toVolume) {
		self.volume += VOLUME_STEP;
		[NSThread sleepForTimeInterval:fadingTime*VOLUME_STEP];
	}
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: decreaseVolume
// Decrease volume to new value 
// decrease volume with fading effect
- (void) decreaseVolume: (double) toVolume {
	//[NSThread detachNewThreadSelector:@selector(decreaseVolumeThread) toTarget:self withObject:(NSObject*) &toVolume];
}

//-----------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------
// Method name: decreaseVolumeThread
// Internal thread used by decreaseVolume
- (void) decreaseVolumeThread: (double) toVolume {
	while (self.volume > toVolume) {
		self.volume -= 1.1*VOLUME_STEP;
		[NSThread sleepForTimeInterval:fadingTime*VOLUME_STEP];
	}
}

//
- (void) setVol: (double) newVolume {
	Vol = newVolume;
	//self.volume = newVolume;
}

- (void) dealloc {
	[pool release];
	[error release];
	[super dealloc];
}
@end
