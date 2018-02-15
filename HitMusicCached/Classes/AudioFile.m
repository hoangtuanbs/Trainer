//
//  AudioFile.m
//  HitMusic
//
//  Created by Tuan VU on 6/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AudioFile.h"


@implementation AudioFile
@synthesize willFadeWhenStop;
@synthesize fileURL;
@synthesize offset, fadeOutTime;
- (id) initWithFileURL: (NSString*) url withOffset: (NSInteger) off andWithFadeOutMilisecond: (NSInteger) fade {
	fileURL = [[NSURL alloc] initFileURLWithPath:url];
	if (!fileURL) return nil;
	//off = offset;
	offset = off;
	fadeOutTime = fade;
	willFadeWhenStop = YES;
	return self;
}

- (id) initWithURL: (NSString*) url withOffset: (NSInteger) off andWithFadeOutMilisecond: (NSInteger) fade {
	fileURL = [[NSURL alloc] initWithString:url];
	if (!fileURL) return nil;
	offset = off;
	fadeOutTime = fade;
	willFadeWhenStop = YES;
	return self;
}


- (void) dealloc {
	[fileURL release];
	[super dealloc];
}
@end
