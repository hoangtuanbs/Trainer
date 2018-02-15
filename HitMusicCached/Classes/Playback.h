#import <MediaPlayer/MediaPlayer.h>

@interface AVItem : NSObject
@end

@interface MPItem : AVItem
- (id)initWithPath:(NSString *)path error:(id *)anError;
@end

@interface MPAVController : NSObject
+ (id) sharedInstance;
- (id) avController;
@end

@interface AVController : NSObject
- (void) play: (id *) whatever;
- (void) pause;
- (void) setQueueFeeder:(id)fp8;
- (void) setVolume:(float)fp8;

+ (void)setEnableNetworkMode:(BOOL)fp8;
- (BOOL)playNextItem:(id *)fp8;
- (BOOL)setRepeatMode:(int)fp8;
- (void)setCurrentItem:(id)fp8;
- (void)continueAfterRepeatGap;
- (BOOL)beginRepeatGap;
- (BOOL)setIndexOfCurrentQueueFeederItem:(unsigned int)fp8 error:(id *)fp12;
- (BOOL)resumePlayback:(double)fp8 error:(id *)fp16;
- (id)currentItem;

@end

@interface AVQueueFeeder : NSObject
@end

@interface AVArrayQueueFeeder : AVQueueFeeder
@end

@interface MPQueueFeeder : AVQueueFeeder
@end

@interface MPArrayQueueFeeder : MPQueueFeeder
- (id) initWithPaths:(id)fp8;
@end
