//
//  AudioFile.h
//  HitMusic
//
//  Created by Tuan VU on 6/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioFile : NSObject {
	NSURL *fileURL;
	bool	willFadeWhenStop;
	NSInteger fadeOutTime;
	NSInteger offset;
}

- (id) initWithFileURL: (NSString*) url withOffset: (NSInteger) off andWithFadeOutMilisecond: (NSInteger) fade;
- (id) initWithURL: (NSString*) url withOffset: (NSInteger) off andWithFadeOutMilisecond: (NSInteger) fade;

@property (nonatomic)	bool willFadeWhenStop;
@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic)	NSInteger fadeOutTime;
@property (nonatomic)	NSInteger offset;
@end
