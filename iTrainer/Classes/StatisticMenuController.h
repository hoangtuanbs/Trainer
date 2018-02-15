//
//  StatisticMenuController.h
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import "DataSource.h"
#import "PiechartViewController.h"
#import "Piechart.h"
#import "DayProgress.h"
@interface StatisticMenuController : UIViewController <PiechartViewDelegate> {

	UIImageView * imgView01, * imgView02, * imgView03, * imgView04, * imgView05, * imgView06, * imgView07, * imgView08, * imgView09,
				* imgView10, * imgView11, * imgView12, * imgView13, * imgView14, * imgView15, * imgView16, * imgView17, * imgView18, * imgView19,
				* imgView20, * imgView21, * imgView22, * imgView23, * imgView24, * imgView25, * imgView26, * imgView27, * imgView28, * imgView29,
				* imgView30, * imgView31, * imgView32, * imgView33, * imgView34, * imgView35, * imgView36, * imgView37, * imgView38, * imgView39,
				* imgView40, * imgView41, * imgView42;
	NSMutableArray * buttonArray;
	NSArray * imgArray;
	UILabel *titleLabel;
	NSDate *currentMonth;
	NSCalendar *gregorianCalendar;
	NSDateFormatter *dateFormatter;
	NSDateComponents *aMonth;
	DataSource *dataSource;
	NSDateComponents *aMinusMonth;
	UIImage * goodImage;
	UIImage * normalImage;
	UIImage * badImage;
	UIImage * veryBadImage;
	
	NSInteger startOfMonthPosition;
	NSInteger startOfNextMonthPosition; 
	NSArray * progressArray;
	UIImageView *imageView;
}
	

@property (nonatomic, retain) IBOutlet UIImageView  * imgView01, * imgView02, * imgView03, * imgView04, * imgView05, * imgView06, * imgView07, * imgView08, * imgView09,
													* imgView10, * imgView11, * imgView12, * imgView13, * imgView14, * imgView15, * imgView16, * imgView17, * imgView18, * imgView19,
													* imgView20, * imgView21, * imgView22, * imgView23, * imgView24, * imgView25, * imgView26, * imgView27, * imgView28, * imgView29,
													* imgView30, * imgView31, * imgView32, * imgView33, * imgView34, * imgView35, * imgView36, * imgView37, * imgView38, * imgView39,
													* imgView40, * imgView41, * imgView42;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction) nextMonth :(id) action;
- (IBAction) previousMonth: (id) action;
- (IBAction) buttonClicked: (id) action;
@end
