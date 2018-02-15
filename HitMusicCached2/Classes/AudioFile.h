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
	NSInteger posChain;
	NSInteger duration;
	NSString * imageURL;
	NSString * title;
	NSString * artist;
}

- (id)	   initWithFileURL: (NSString*) url 
				withOffset: (NSInteger) off 
  andWithFadeOutMilisecond: (NSInteger) fade 
		  andWithPosChain: (NSInteger) posChainMs 
			 withDuration: (NSInteger) d 
				withImage:(NSString*) img withTitle:(NSString *)tt andWithSinger: (NSString*) sing;
//- (id) initWithURL: (NSString*) url withOffset: (NSInteger) off andWithFadeOutMilisecond: (NSInteger) fade andWithPosChain:(NSInteger) posChainMs;

@property (nonatomic)	bool willFadeWhenStop;
@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic)	NSInteger fadeOutTime;
@property (nonatomic)	NSInteger offset;
@property (nonatomic) NSInteger posChain;
@property (nonatomic) NSInteger duration;
@property (nonatomic, assign)  NSString * imageURL;
@property (nonatomic, assign)  NSString * title;
@property (nonatomic, assign)  NSString * artist;
@end
