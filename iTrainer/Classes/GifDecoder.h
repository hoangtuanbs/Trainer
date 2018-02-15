//
//  GifDecoder.h
//  iTrainer
//
//  Created by Tuan VU on 7/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GifDecoder : NSObject {
	NSData *gifData;
	NSMutableData *buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableData *GIF_string;
	
	NSMutableArray *GIF_delays;
	NSMutableArray *GIF_framesData;
	
	BOOL colorTableSortFlag;
	int gColorTableSize;
	int globalColorTableSize;
	BOOL globalColorTableFlag;
	BOOL transparentColorFlag;
	int transparentColorIndex; 
	int dataPointer;
	int frameCounter;
}

- (id) initDecoder;
- (NSArray*)decodeGIF:(NSData *)GIF_Data;

@end
