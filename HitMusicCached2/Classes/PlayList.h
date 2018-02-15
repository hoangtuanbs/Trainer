//
//  PlayList.h
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/27/08.
//  Copyright 2008 Wavem. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlayList : NSObject {
	NSInteger	primaryKey;
	NSInteger	currentPositionOnArray;		// This is where the last played index on the mediaContent Array is kept
}
@property (nonatomic, assign)	NSInteger	primaryKey;
@property (nonatomic, assign)   NSInteger	currentPositionOnArray;	

- (id)createWithId:(NSInteger)pk;
//- (NSInteger) currentPosition;

@end
