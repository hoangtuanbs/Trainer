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
@synthesize offset;
@synthesize fadeOutTime, posChain, duration, imageURL, title, artist;

- (id) initWithFileURL: (NSString*) url   withOffset: (NSInteger) off 
							andWithFadeOutMilisecond: (NSInteger) fade 
									 andWithPosChain: (NSInteger) posChainMs 
		                                withDuration: (NSInteger) d 
			 withImage:(NSString*) img 
			 withTitle:(NSString *)tt 
		 andWithSinger: (NSString*) sing {
	NSLog(@"Created new Audio file");
	fileURL = [[NSURL alloc] initFileURLWithPath:url];
	if (!fileURL) return nil;
	self.offset = off/1000.0;
	self.posChain =   posChainMs/1000.0;
	self.fadeOutTime = fade/1000.0;
	NSLog([NSString stringWithFormat:@"Fade out of file: %d", fade]);
	self.willFadeWhenStop = YES;

	duration = d;
	imageURL = img;
	title = tt;
	artist = sing;
	switch (d) {
		case 246747:
			duration = 241.900;
			posChain = 238.000;
			fadeOutTime = 236.000;
			//self.offset = 200000;
			break;
		case 12859:
			posChainMs = 9.000;
			break;
		case 221831:
			posChain= 220.000;
			fadeOutTime = 219.000;
			break;
		case 208899:
			duration = 156.000;
			posChain = 154.000;
			fadeOutTime = 156.000;
			break;
		case 234300:
			fadeOutTime = 232.000;
			break;
		case 235141:
			duration = 243.000;
			break;
		case 7763:
			posChain = 6.000;
			break;
		case 28932:
			duration = 30.000;
			break;
		case 44309:
			duration = 46.200;
			break;
		case 28937:
			fadeOutTime = 27.000;
			break;
		default:
			break;
	}
	return self;
}



- (void) dealloc {
	[fileURL release];
	[super dealloc];
}
@end
