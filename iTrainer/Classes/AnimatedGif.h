//
//  AnimatedGif.h
//
//  Created by Stijn Spijker (http://www.stijnspijker.nl/) on 03-07-09.
//  Based on gifdecode written april 2009 by Martin van Spanje, P-Edge media.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#ifdef TARGET_OS_IPHONE			
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif TARGET_OS_IPHONE	

@interface AnimatedGif : NSObject {
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableData *GIF_string;
	NSMutableData *GIF_frameHeader;
	
	NSMutableArray *GIF_delays;
	NSMutableArray *GIF_framesData;
	NSMutableArray *GIF_transparancies;

	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;
	int frameCounter;	
}

- (id)init;
- (void)decodeGIF:(NSData *)GIF_Data;
- (void)GIFReadExtensions;
- (void)GIFReadDescriptor;
- (int)GIFGetBytes:(int)length;
- (void)GIFPutBytes:(NSData *)bytes;
- (NSMutableData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;
- (UIImageView*) getAnimation;
- (NSArray*) getAnimatingImages;
- (UIImage *)maskFrame:(UIImage *)image withFrame:(UIImage *)maskImage;
@end
