//
//  InternetConnector.m
//  iTrainer
//
//  Created by Tuan VU on 6/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InternetConnector.h"


@implementation InternetConnector
- (id) init {
	if (self = [super init]) {
		return self;
	}
	else return nil;
}

- (NSInteger) registerUser: (NSString*) name withEmail: (NSString*) email andGender: (NSInteger) gender  {
	return 112;
}
@end
