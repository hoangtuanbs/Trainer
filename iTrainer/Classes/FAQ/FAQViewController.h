//
//  FAQViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
//#import "ConsultTrainerForm.h"
@interface FAQViewController : UIViewController {
	UITableViewController *tableView;
	iTrainerAppDelegate *delegate ;
	//ConsultTrainerForm *consultTrainer;
}

//@property (nonatomic, retain) ConsultTrainerForm * consultTrainer;
@property (nonatomic, retain) iTrainerAppDelegate *delegate;
@property (nonatomic, retain) IBOutlet UITableViewController *tableView;

-(void) submitQuestion ;

@end
