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
@interface APCustomPlayer : AVAudioPlayer {
	Boolean fading;
	double fadingTime;
	double Vol;
	NSError *error;
	NSAutoreleasePool *pool;
	NSThread *volumeThread;
	bool isResumable;
	bool isOnQueue;
	NSInteger offset;
}

@property (nonatomic) bool isOnQueue;
@property (nonatomic) bool isResumable;
//@property (nonatomic) double Vol;

@property (nonatomic) Boolean fading;
@property (nonatomic, retain) NSError *error;

- (id) initWithContentOfUrl: (NSURL *) url withOffsetInMiliseconds: (NSInteger) off andFadingMode: (Boolean) fadingMode inSeconds: (double) second;
- (id) initWithAudioFile: (AudioFile*) file;
- (void) setVol: (double) newVolume;
- (void) PlayAfter: (NSTimeInterval) delay;
- (void) Play;
- (void) Stop;
- (void) Pause;
- (void) SeekTo: (double) pos;
@end
