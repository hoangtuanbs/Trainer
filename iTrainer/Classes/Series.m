//
//  Series.m
//  iTrainer
//
//  Created by Tuan VU on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Series.h"


@implementation Series
enum STRENGTH {
	LOW = 1, 
	MEDIUM = 2 ,
	HEAVY = 3
};
@synthesize iid, order, status, repeat, strength, progressID;

- (id) initWithIID: (NSInteger) newIID {
	if (self = [super init] ) {
		iid = newIID;
	}
	return self;
}
- (NSString*) getStatusString {
	NSString *result;
	switch (strength) {
		case LOW:
			result = [NSString stringWithFormat:NSLocalizedString( @"small weight", "")];
			break;
		case MEDIUM:
			result = [NSString stringWithFormat:NSLocalizedString( @"medium weight", "")];
			break;
		case HEAVY:
			result = [NSString stringWithFormat:NSLocalizedString( @"heavy weight", "")];
			break;
		default:
			result = [NSString stringWithFormat:@"any weight"];
			break;
	}
	return result;
}


- (NSString*) getStatusShortString {
	NSString *result;
	switch (strength) {
		case LOW:
			result = [NSString stringWithFormat:@"%ds", repeat];
			break;
		case MEDIUM:
			result = [NSString stringWithFormat:@"%dm", repeat];
			break;
		case HEAVY:
			result = [NSString stringWithFormat:@"%dh", repeat];
			break;
		default:
			result = [NSString stringWithFormat:@"%d ", repeat];
			break;
	}
	return result;
}
@end
