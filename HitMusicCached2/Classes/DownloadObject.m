//
//  DownloadObject.m
//  MobileTV
//
//  Created by iphone on 6/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DownloadObject.h"


@implementation DownloadObject
@synthesize urlAddress, newName, ownerName,  ownerId, ownerIndex, mediaType;

-(id) initWithUrl:(NSString*)pUrlAddress withame:(NSString*)pName fromOwner:(NSString*)pOwnerName withOwnerId:(NSInteger)pOwnerId withOwnerIndex:(NSInteger)pOwnerIndex withType:(NSString*)type{
	self.urlAddress	= pUrlAddress;
	self.newName	= pName;
	self.ownerName	= pOwnerName;
	self.ownerId	= pOwnerId;
	self.ownerIndex = pOwnerIndex;
	self.mediaType	= type;
	return self;
}

@end
