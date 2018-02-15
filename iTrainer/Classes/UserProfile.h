//
//  UserProfile.h
//  iTrainer
//
//  Created by Tuan VU on 6/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserProfile : NSObject {
	NSInteger iid;
	NSString *name;
	NSString *email;
	NSDate *date;
	NSInteger gender;
	NSInteger monday;
	NSInteger tuesday;
	NSInteger wednesday;
	NSInteger thursday;
	NSInteger friday;
	NSInteger saturday;
	NSInteger sunday;
	NSInteger goal;
	NSInteger complexity;
	NSInteger program;
	NSInteger weight;
	NSInteger height;
	NSInteger dietPlan;
}

- (id) initWithIID: (NSInteger) newIID;
@property (nonatomic) NSInteger iid;
@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic) NSInteger gender;
@property (nonatomic) NSInteger monday;
@property (nonatomic) NSInteger tuesday;
@property (nonatomic) NSInteger wednesday;
@property (nonatomic) NSInteger thursday;
@property (nonatomic) NSInteger friday;
@property (nonatomic) NSInteger saturday;
@property (nonatomic) NSInteger sunday;
@property (nonatomic) NSInteger goal;
@property (nonatomic) NSInteger complexity;
@property (nonatomic) NSInteger program;
@property (nonatomic) NSInteger weight;
@property (nonatomic) NSInteger height;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic) NSInteger dietPlan;
@end
