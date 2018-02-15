//
//  Series.h
//  iTrainer
//
//  Created by Tuan VU on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Series : NSObject {
	NSInteger iid;
	NSInteger order;
	NSInteger repeat;
	NSInteger strength;
	NSInteger status;
	NSInteger progressID;
}

- (id) initWithIID: (NSInteger) newIID;
- (NSString*) getStatusString;
- (NSString*) getStatusShortString;
@property (nonatomic) NSInteger iid;
@property (nonatomic) NSInteger order;
@property (nonatomic) NSInteger repeat;
@property (nonatomic) NSInteger strength;
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger progressID;
@end
