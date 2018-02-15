//
//  FAQTableViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FAQTableViewController : UITableViewController {
	NSArray *dataSource;
}

@property (nonatomic, retain) NSArray *dataSource;
@end
