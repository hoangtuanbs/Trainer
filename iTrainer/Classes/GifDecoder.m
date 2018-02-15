//
//  GifDecoder.m
//  iTrainer
//
//  Created by Tuan VU on 7/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GifDecoder.h"
#define GIF_HEADER_LENGTH 6
#define GIF_LOGICAL_SCREEN_DESCRIPTOR_LENGTH 7
#define GIF_BIT_FIELD_LSD_BYTE 4
#define GIF_GLOBAL_COLOR_TABLE_FLAG_MASK 0x80 
#define GIF_COLOR_TABLE_SORT_FLAG_MASK 0x08
#define GIF_GLOBAL_COLOR_TABLE_SIZE_MASK 0x07
#define GIF_BLOCK_CODE_EXTENSION 0x21
#define GIF_BLOCK_CODE_IMAGE 0x2C
#define GIF_BLOCK_CODE_TERMINATOR 0x3B
#define GIF_EXTENTION_TYPE_PLAIN_TEXT 0x01
// plain text length is 1 + 12
#define GIF_PLAIN_TEXT_HEADER_LENGTH 13
#define GIF_EXTENTION_TYPE_GRAPHIC_CONTROL 0xF9
// graphic control length is 1 + 4 + 1
#define GIF_GRAPHIC_CONTROL_HEADER_LENGTH 0x06
#define GIF_EXTENTION_TYPE_COMMENT 0xFE
#define GIF_EXTENTION_TYPE_APPLICATION 0xFF
#define GIF_TRANSPARENT_COLOR_FLAG_MASK 0x01
@interface GifDecoder() 
// gif decoder

- (void)ReadExtensions;
- (void)ReadDescriptor;
- (int)GetBytes:(int)length;
- (void)PutBytes:(NSData *)bytes;

@end


@implementation GifDecoder

- (id) initDecoder {
	if (self = [super init]) {
		buffer = [[NSMutableData alloc] init];
		GIF_screen = [[NSMutableData alloc] init];
		GIF_delays = [[NSMutableArray alloc] init];
		GIF_framesData = [[NSMutableArray alloc] init];
		GIF_string = [[NSMutableData alloc] init];
		GIF_global = [[NSMutableData alloc] init];
	}
	return self;
}
- (NSArray* )decodeGIF:(NSData *)GIFData
// decodes GIF image data into separate frames
{
	gifData = [NSData dataWithData:GIFData];
	
	[buffer setData:[NSData data]];
	[GIF_screen setData:[NSData data]];
	[GIF_delays removeAllObjects];
	[GIF_framesData removeAllObjects];
	[GIF_string setData:[NSData data]];
	[GIF_global setData:[NSData data]];
	
	dataPointer = 0;
	frameCounter = 0;
	
	// read GIF header, usually we skip this data 
	[self GetBytes:GIF_HEADER_LENGTH]; // GIF89a
	
	// read glocal screen descriptor
	[self GetBytes:GIF_LOGICAL_SCREEN_DESCRIPTOR_LENGTH];; // Logical Screen Descriptor
	
	// get LSD data
	[GIF_screen setData:buffer];
	size_t length = [buffer length];
	
	// copy data to buffer
	unsigned char aBuffer[length];
	[buffer getBytes:aBuffer length:length];
	
	// check enable using global color 
	globalColorTableFlag = (aBuffer[GIF_BIT_FIELD_LSD_BYTE] & GIF_GLOBAL_COLOR_TABLE_FLAG_MASK);
	/*
	if (aBuffer[GIF_BIT_FIELD_LSD_BYTE] & GIF_GLOBAL_COLOR_TABLE_FLAG_MASK) 
		globalColorTableFlag = TRUE; 
	else 
		globalColorTableFlag = FALSE;
	*/
	// check enable color table sort flag
	colorTableSortFlag = (aBuffer[GIF_BIT_FIELD_LSD_BYTE] & GIF_COLOR_TABLE_SORT_FLAG_MASK) ;
	/*
	if (aBuffer[GIF_BIT_FIELD_LSD_BYTE] & GIF_COLOR_TABLE_SORT_FLAG_MASK) 
		colorTableSortFlag = TRUE; 
	else 
		colorTableSortFlag = FALSE;
	*/
	
	globalColorTableSize = (aBuffer[GIF_BIT_FIELD_LSD_BYTE] & GIF_GLOBAL_COLOR_TABLE_SIZE_MASK);
	
	// 2^(n+1) is the number of entries in the global color table
	gColorTableSize =3*( 2 << globalColorTableSize);
	
	// if using global color table
	if (globalColorTableFlag) {
		[self GetBytes:( gColorTableSize)];
		[GIF_global setData:buffer];
	}
	
	BOOL isNotDone;
	unsigned char byteBuffer[1];
	do {
		isNotDone = [self GetBytes:1];
		if (isNotDone) {
			[buffer getBytes:byteBuffer length:1];
			switch (byteBuffer[0]) {
				case GIF_BLOCK_CODE_EXTENSION:
					[self ReadExtensions];
					break;
				case GIF_BLOCK_CODE_IMAGE:
					[self ReadDescriptor];
					break;
				default:
					isNotDone = TRUE;
					break;
			}
		}
		
	} while (isNotDone);
		
	// clean up stuff
	[buffer setData:[NSData data]];
	[GIF_screen setData:[NSData data]];
	[GIF_string setData:[NSData data]];
	[GIF_global setData:[NSData data]];	
	return GIF_framesData;
}


// According to 89a format, GIF may contains Extension block
- (void)ReadExtensions {
	transparentColorFlag = FALSE;
	// Extension type code
	[self GetBytes:1];
	unsigned char aBuffer[1];
	[buffer getBytes:aBuffer length:1];
	
	unsigned char * headerBuffer;
	switch (aBuffer[0]) {
			
		// plain text case
		case GIF_EXTENTION_TYPE_PLAIN_TEXT:
			[self GetBytes:GIF_PLAIN_TEXT_HEADER_LENGTH];
			headerBuffer = (unsigned char*) malloc(GIF_PLAIN_TEXT_HEADER_LENGTH);
			[buffer getBytes:headerBuffer length:GIF_PLAIN_TEXT_HEADER_LENGTH];
			while (aBuffer[0]) {
				// parsing through the extension
				// since this is not a useful extesion , we dont save it
				[self GetBytes:1];
				[buffer getBytes:aBuffer length:1];
			}
			free(headerBuffer);
			break;
		// graphic control case
		case GIF_EXTENTION_TYPE_GRAPHIC_CONTROL:
			[self GetBytes:GIF_GRAPHIC_CONTROL_HEADER_LENGTH];
			headerBuffer = (unsigned char *) malloc(GIF_GRAPHIC_CONTROL_HEADER_LENGTH);
			[buffer getBytes:headerBuffer length:GIF_GRAPHIC_CONTROL_HEADER_LENGTH];
			NSLog(@"%d , %d, %d, %d, %d, %d", headerBuffer[0], headerBuffer[1], headerBuffer[2], headerBuffer[3], headerBuffer[4], headerBuffer[5]);
			transparentColorFlag =  (headerBuffer[1] & GIF_TRANSPARENT_COLOR_FLAG_MASK) ;
			transparentColorIndex = (headerBuffer[4]);
			free(headerBuffer);
			break;
			
		default:
			while (aBuffer[0]) {
				// parsing through the extension
				// since this is not a useful extesion , we dont save it
				[self GetBytes:1];
				[buffer getBytes:aBuffer length:1];
			}
			break;
	}
}

- (void)ReadDescriptor {	
	NSMutableData *GIF_screenTmp = [[NSMutableData alloc] init];
	[self GetBytes:9];
	[GIF_screenTmp setData:buffer];
	
	size_t alength = [buffer length];
	unsigned char aBuffer[alength];
	[buffer getBytes:aBuffer length:alength];
	
	
	if ((aBuffer[8] & 0x80)) globalColorTableFlag = TRUE; else globalColorTableFlag = FALSE;
	NSLog(@"%d %d %d %d %d %d %d %d %d", aBuffer[0], aBuffer[1], aBuffer[2], aBuffer[3], aBuffer[4], aBuffer[5], aBuffer[6],  aBuffer[7], aBuffer[8]);
	unsigned char GIF_code, GIF_sort;
	
	if (globalColorTableFlag ) {
		GIF_code = (aBuffer[8] & 0x07);
		if (aBuffer[8] & 0x20) GIF_sort = 1; else GIF_sort = 0;
	} else {
		GIF_code = globalColorTableSize;
		GIF_sort = colorTableSortFlag;
	}
	
	int GIF_size = (2 << GIF_code);
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
	
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort) {
		bBuffer[4] |= 0x08;
	}
	
	[GIF_string setData:[[NSString stringWithString:@"GIF87a"] dataUsingEncoding: NSASCIIStringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
	[self PutBytes:GIF_screen];
	
	if (globalColorTableFlag) {
		[self GetBytes:(3 * GIF_size)];
		[self PutBytes:buffer];
	} else {
		[self PutBytes:GIF_global];
	}
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
	
	cBuffer[8] &= 0x40;
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[self PutBytes:GIF_screenTmp];
	[self GetBytes:1];
	[self PutBytes:buffer];
	
	for ( ; ; ) {
		[self GetBytes:1];
		[self PutBytes:buffer];
		
		size_t dlength = [buffer length];
		unsigned char dBuffer[1];
		[buffer getBytes:dBuffer length:dlength];
		
		long u = (int)dBuffer[0];
		if (u == 0x00) {
			break;
		}
		[self GetBytes:u];
		[self PutBytes:buffer];
		char * tempCharForDisplay = (char*) malloc([buffer length]);
		[buffer getBytes:tempCharForDisplay length:[buffer length]];
		
	}
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	// save the frame into the array of frames
	[GIF_framesData addObject:[GIF_string copy]];
}

- (int)GetBytes:(int)length {
	[buffer setData:[NSData data]];
	if ([gifData length] >= dataPointer + length) {
		[buffer setData:[gifData subdataWithRange:NSMakeRange(dataPointer, length)]];
		dataPointer += length;
		return 1;
	} else {
		return 0;
	}
}

- (void)PutBytes:(NSData *)bytes {
	[GIF_string appendData:bytes];
}


@end
