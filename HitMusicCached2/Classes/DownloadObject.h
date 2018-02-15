//
//  DownloadObject.h
//  MobileTV
//
//  Created by iphone on 6/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DownloadObject : NSObject {
	NSString  *urlAddress;
	NSString  *newName;
	NSString  *ownerName;
	NSInteger ownerId;
	NSInteger ownerIndex;
	NSString  *mediaType;
}
-(id) initWithUrl:(NSString*)pUrlAddress withame:(NSString*)pName fromOwner:(NSString*)pOwnerName withOwnerId:(NSInteger)pOwnerId withOwnerIndex:(NSInteger)pOwnerIndex withType:(NSString*)type;

@property (nonatomic, retain) NSString  *urlAddress;
@property (nonatomic, retain) NSString  *newName;
@property (nonatomic, retain) NSString  *ownerName;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, assign) NSInteger ownerIndex;
@property (nonatomic, retain) NSString  *mediaType;
@end
