//
//  WorkOutTableViewCellController.h
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutDetail.h"
#import "iTrainerAppDelegate.h"
@interface WorkOutTableViewCellController : UITableViewCell {
	WorkoutDetail *state;
	UIButton *button;
	UILabel *header;
	UILabel *detail;
	UIImage *checkmark;
	UIImage *checkmarkNon;
	UIImageView *imageView;
	iTrainerAppDelegate *delegateApp;
	UIImageView* view;
}

//- (id) initCellWithHeader: (NSString *) headerText andWithDetail: (NSString *) detailText andWithState: (NSInteger *)status ;
@property (nonatomic, retain) IBOutlet UILabel *header;
@property (nonatomic, retain) IBOutlet UILabel *detail;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, assign)  WorkoutDetail *state;
@property (nonatomic, assign) UIImage * checkmark;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) iTrainerAppDelegate *delegateApp;
@property (nonatomic, assign) IBOutlet UIImageView *view;
@property (nonatomic, assign) UIImage *checkmarkNon;
- (IBAction) changeState: (id) sender ;
@end
