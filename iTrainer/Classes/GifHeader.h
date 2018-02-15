//
//  GifHeader.h
//  iTrainer
//
//  Created by Tuan VU on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct  {
	char signature[3];
	char version[3];
} GIFHeaderStruct;

@interface GifHeader : NSObject {
	
}

@end
