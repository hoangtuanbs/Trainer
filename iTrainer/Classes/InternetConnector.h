//
//  InternetConnector.h
//  iTrainer
//
//  Created by Tuan VU on 6/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InternetConnector : NSObject {

}

- (id) init;
- (NSInteger) registerUser: (NSString*) name withEmail: (NSString*) email andGender: (NSInteger) gender ;
@end
