//
//  APAudioPlayer.h
//  AudioPlayer
//
//  Created by Tuan VU on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "APCustomPlayer.h"
#import "AudioFile.h"

@interface APAudioPlayer : NSObject <AVAudioPlayerDelegate>{
	id parent;
	NSAutoreleasePool *pool;
	
	APCustomPlayer *mainPlayer, *slavePlayer, *tempPlayer ;
	//APCustomPlayer	*player1, *player2 ;
	AVAudioSession	*audioSession;
	NSError			*error;
	NSRunLoop		*runLoop;
	NSMutableArray	*fileList;
	//NSString			*audioFilesAddress;
	
	NSInteger index;
	NSThread * watchDog; 
	
	bool randomMode;
	bool repeatSong;
	bool repeatPlayList;
	bool fadeInOutOnSkip;
	double volume;
	double crossFadeMiliseconds;	

	bool isPaused;
}

@property (nonatomic, assign) id parent;
@property (nonatomic) bool isPaused;
@property (nonatomic) bool repeatPlayList;
@property (nonatomic) bool repeatSong;
@property (nonatomic) bool fadeInOutOnSkip;
@property (nonatomic, retain) NSMutableArray * fileList;
- (id) initWithCrossFadeSeconds: (int) miliseconds repeatPlayList: (bool) playlist withFadeInOutOnSkip: (bool) fadeInOut;

- (void) addAudioToPlayList: (AudioFile*) file;
- (void) removeAudioFromPlayList: (NSURL *) audioFile;
- (void) clearPlayList;

- (bool) isPlaying;
- (void) play;
- (void) stop;
- (void) pause; 
- (void) resume;
- (int) getNextPlayingIndex;
- (void) skipBack;
- (void) skipForward;
- (void) playAudioAtIndex: (int) audioIndex;
- (void) setCrossFade: (bool) setCFade withSeconds: (double) miliseconds;
- (double) getAudioTimeLength;
- (double) getAudioTimeRemaining;
- (void) setVolume: (double) level;
- (double) getVolume;
- (void) setFading: (bool) sender;
- (APCustomPlayer*) initNewPlayer: (NSInteger) index;
@end
