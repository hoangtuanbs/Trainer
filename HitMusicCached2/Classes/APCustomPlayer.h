//
//  APCustomPlayer.h
//  AudioPlayer
//
//  Created by Tuan VU on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioFile.h"
@protocol APCustomPlayerDelegate<AVAudioPlayerDelegate> 
@optional 
- (void) playerShouldPrepareForNextSong;
- (void) playerShouldStartPlayingNextSong;
@end

@interface APCustomPlayer : AVAudioPlayer {
	NSTimeInterval fadingTime;
	double Vol;
	NSError *error;
	NSAutoreleasePool *pool;
	NSThread *volumeThread;
	NSThread *watchDog;
	NSThread *fadingWatchDog;
	
	// locker for avoiding recall delegate methods
	bool isFaded;
	bool isNextSongPrepared;
	bool isNextSongPlay;
	
	AudioFile * audioFile;
	id <APCustomPlayerDelegate> delegate;
}

//@property (nonatomic, retain) AudioFile *audioFile;



@property (nonatomic, retain) NSError *error;
@property (assign) id <APCustomPlayerDelegate> delegate;


- (id) initWithAudioFile: (AudioFile*) file;
- (void) setVol: (double) newVolume;
- (void) Play;
- (void) Stop;
@end
