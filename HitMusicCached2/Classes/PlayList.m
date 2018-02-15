//
//  PlayList.m
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/27/08.
//  Copyright 2008 Wavem. All rights reserved.
//

#import "PlayList.h"
#import "HitMusicAppDelegate.h"
#import "MainView.h"

@implementation PlayList
@synthesize primaryKey, currentPositionOnArray;

- (id)createWithId:(NSInteger)pk {
	self.primaryKey = pk;
	self.currentPositionOnArray = 0;
	return self;
}



@end
