//
//  UserProfile.m
//  iTrainer
//
//  Created by Tuan VU on 6/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserProfile.h"


@implementation UserProfile
@synthesize name, iid, email, gender, monday, tuesday, thursday, friday, saturday, sunday, goal, date, wednesday, complexity, weight, height;
@synthesize program, dietPlan;
- (id) initWithIID: (NSInteger) newIID {
	[super init];
	iid = newIID;
	date = [NSDate date];
	return self;
}
@end
