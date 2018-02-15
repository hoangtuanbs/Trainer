//
//  WorkOutDetailTableViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WorkOutDetailTableViewController : UITableViewController 
<UITableViewDelegate, UITableViewDataSource> {
	NSArray *dataSource;
}

@property (nonatomic, retain) NSArray *dataSource;

- (void) initDataSource: (id) sender;
@end

