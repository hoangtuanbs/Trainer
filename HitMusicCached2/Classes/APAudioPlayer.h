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

@interface APAudioPlayer : NSObject <APCustomPlayerDelegate>{
	id parent;
	NSAutoreleasePool *pool;
	
	APCustomPlayer *mainPlayer, *slavePlayer, *tempPlayer ;
	//APCustomPlayer	*player1, *player2 ;
	AVAudioSession	*audioSession;
	NSError			*error;
	NSRunLoop		*runLoop;
	NSMutableArray	*fileList;
	
	NSInteger index;
	
	bool randomMode;
	bool repeatSong;
	bool repeatPlayList;
	double volume;
	bool isPaused;
}

@property (nonatomic, assign) id parent;
@property (nonatomic) bool isPaused;
@property (nonatomic) bool repeatPlayList;
@property (nonatomic) bool repeatSong;

@property (nonatomic, retain) NSMutableArray * fileList;
- (id) initWithRepeatPlayList: (bool) playlist withFadeInOutOnSkip: (bool) fadeInOut;

- (void) addAudioToPlayList: (AudioFile*) file;
- (void) clearPlayList;
- (bool) isPlaying;
- (void) play;
- (void) stop;
- (int) getNextPlayingIndex;
- (void) setVolume: (double) level;
- (double) getVolume;
- (APCustomPlayer*) initNewPlayer: (NSInteger) index;

@end
