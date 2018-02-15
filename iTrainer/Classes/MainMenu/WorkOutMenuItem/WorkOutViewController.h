//
//  WorkOutViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import "WorkOutTableViewController.h"
@interface WorkOutViewController : UIViewController {
	WorkOutTableViewController *tableView;
	iTrainerAppDelegate *delegate;
	NSDictionary *menuTitle;
	UIButton *buttonPrv;
	UIButton *buttonNxt;
	UILabel  *header;
	UILabel  *dayHeader;
	NSDateFormatter * inputFormatter;
	NSCalendar *gregorian;
	
	UILabel *noworkout;
}

- (IBAction) buttonPrvPressed: (id) sender;
- (IBAction) buttonNxtPressed: (id) sender;
@property (nonatomic, retain) IBOutlet UILabel *noworkout;
@property (nonatomic, retain) IBOutlet UILabel *dayHeader;
@property (nonatomic, retain) IBOutlet UILabel *header;
@property (nonatomic, retain) IBOutlet UIButton *buttonPrv;
@property (nonatomic, retain) IBOutlet UIButton *buttonNxt;
@property (nonatomic, retain) NSDictionary *menuTitle;
@property (nonatomic, retain) iTrainerAppDelegate *delegate;
@property (nonatomic, retain) IBOutlet WorkOutTableViewController *tableView;

//- (void) popViewFromStack;
- (void) popRootView;
@end
