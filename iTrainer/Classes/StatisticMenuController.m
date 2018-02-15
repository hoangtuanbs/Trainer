//
//  StatisticMenuController.m
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatisticMenuController.h"
#import "DayProgress.h"
#import "Piechart.h"
#import "PiechartViewController.h"
#define DAY_PER_WEEK 7
#define INITIAL_X 3
#define INITIAL_Y 55
#define BUTTON_SIZE_X 45
#define BUTTON_SIZE_Y 45
#define SEPERATOR_X 0 
#define SEPERATOR_Y 0
@interface StatisticMenuController() 
- (void) reloadView;
- (int) getMaxDaysFor : (NSInteger) month andYear: (NSInteger) year;
- (int) getMaxDaysForPreviousMonthOf: (NSInteger) month andYear : (NSInteger )year;
@end

@implementation StatisticMenuController


@synthesize   imgView01,   imgView02,   imgView03,   imgView04,   imgView05,   imgView06,   imgView07,   imgView08,   imgView09,
  imgView10,   imgView11,   imgView12,   imgView13,   imgView14,   imgView15,   imgView16,   imgView17,   imgView18,   imgView19,
  imgView20,   imgView21,   imgView22,   imgView23,   imgView24,   imgView25,   imgView26,   imgView27,   imgView28,   imgView29,
  imgView30,   imgView31,   imgView32,   imgView33,   imgView34,   imgView35,   imgView36,   imgView37,   imgView38,   imgView39,
imgView40,   imgView41,   imgView42, imageView;

@synthesize titleLabel;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void) viewWillAppear: (BOOL) animated {
	NSLog (NSLocalizedString( @"Statistic", ""));
	//[self. titleLabel setText:(NSLocalizedString( @"Statistic", ""))];

	[self reloadView];
	[super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	iTrainerAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);
	
	self.tabBarItem.title = NSLocalizedString( @"Statistic", "");

	dataSource = [delegate dataSource];
	buttonArray = [[NSMutableArray alloc] init];
	for (int i =0; i< 6 ; i++) {
		for (int j =0; j<DAY_PER_WEEK; j++) {
			UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(INITIAL_X + j*BUTTON_SIZE_X, 
																	   INITIAL_Y + i * BUTTON_SIZE_Y,
							 BUTTON_SIZE_X, BUTTON_SIZE_Y)];
			[btn setTitle: [NSString stringWithFormat:@"%d,%d  ", i,j] forState: UIControlStateNormal];
			[btn setBackgroundImage:[UIImage imageNamed:@"daybtn.png"] forState:UIControlStateNormal];
			
			[self.view addSubview:btn];
			[self.view sendSubviewToBack:btn];
			[buttonArray addObject:btn];
			
		}
	}

	imgArray = [[NSArray alloc] initWithObjects:	imgView01,   imgView02,   imgView03,   imgView04,   imgView05,   imgView06,   imgView07,   imgView08,   imgView09,
													imgView10,   imgView11,   imgView12,   imgView13,   imgView14,   imgView15,   imgView16,   imgView17,   imgView18,   imgView19,
													imgView20,   imgView21,   imgView22,   imgView23,   imgView24,   imgView25,   imgView26,   imgView27,   imgView28,   imgView29,
													imgView30,   imgView31,   imgView32,   imgView33,   imgView34,   imgView35,   imgView36,   imgView37,   imgView38,   imgView39,
													imgView40,   imgView41,   imgView42, nil];
	for (int i = 0; i < [buttonArray count]; i++) {
		UIButton *butt = [buttonArray objectAtIndex:i];
		butt.titleLabel.textAlignment = UITextAlignmentLeft;
		[butt addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	currentMonth = [[NSDate alloc] init];
	gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	dateFormatter = [[NSDateFormatter alloc] init];
	//[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateFormat:@"MMMM, yyyy"];
	//[dateFormatter setTimeStyle: NSDateFormatterNoStyle];
	aMonth = [[NSDateComponents alloc] init];
	[aMonth setMonth:1];
	aMinusMonth = [[NSDateComponents alloc] init];
	[aMinusMonth setMonth:-1];
	
	goodImage = [UIImage imageNamed:@"green.png"];
	normalImage = [UIImage imageNamed:@"blue.png"];
	badImage = [UIImage imageNamed:@"yellow.png"];
	veryBadImage = [UIImage imageNamed:@"red.png"];

	
	[self.view sendSubviewToBack:imageView];
	//[self reloadView];
    [super viewDidLoad];

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark IBAction Methods
- (IBAction) nextMonth : (id) action {
	NSDate *newDay = [gregorianCalendar dateByAddingComponents:aMonth toDate:currentMonth options:0];
	[currentMonth release];
	currentMonth = [newDay retain];
	[self reloadView];
	//[aMonth release];
	
}

- (IBAction) previousMonth: (id) action {
	currentMonth = [[gregorianCalendar dateByAddingComponents:aMinusMonth toDate:currentMonth options:0] retain];
	[self reloadView];
	//[aMonth release];
}

- (void) reloadView {
	
	titleLabel.text = [dateFormatter stringFromDate:currentMonth];
	
	NSDateComponents *thisMonth = [gregorianCalendar components:(NSMonthCalendarUnit| NSYearCalendarUnit) fromDate:currentMonth];
	NSInteger cMonth = [thisMonth month];
	NSInteger cYear = [thisMonth year];
	NSInteger currentMonthInt = [[gregorianCalendar components:NSMonthCalendarUnit fromDate:[NSDate date] ] month];
	titleLabel.textColor = (currentMonthInt == cMonth ) ? [UIColor blackColor] : [UIColor blueColor]; 

	// get maximum days of previous month
	NSInteger nTotalDayOfPreviousMonth  = [self getMaxDaysForPreviousMonthOf:cMonth andYear:cYear];
	
	// get maximum days of this month
	NSInteger nTotalDayOfThisMonth = [self getMaxDaysFor: cMonth andYear: cYear];
	
	// get weekday of the beginning of month 
    NSDateComponents *firstDayOfMonthComp = [[NSDateComponents alloc] init];
	[firstDayOfMonthComp setDay:1];
	[firstDayOfMonthComp setMonth:cMonth];
	[firstDayOfMonthComp setYear:cYear];
	
	NSDate *firstDayOfMonth = [gregorianCalendar dateFromComponents:firstDayOfMonthComp]; // first day of the month, used to determine the weekday of the begining of monthh
	
	NSDateComponents *weekdayComp = [gregorianCalendar components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];
	NSInteger weekdayOfBeginOfMonth = [weekdayComp weekday] -1;// Sunday is 1
	
	// 
	NSDate *today = [NSDate date];
	NSDateComponents *todayComponents = [gregorianCalendar components:(NSMonthCalendarUnit || NSYearCalendarUnit) fromDate:today];
	NSInteger whatMonthNow = [todayComponents month];
	NSInteger whatYearNow = [todayComponents year];
	
	// 
	if ((whatYearNow < cYear) || ((whatYearNow == cYear) && ( whatMonthNow < cMonth))) { 
			
		return;
		
	}
	
	progressArray = [dataSource getSeriesStatusForMonth:cMonth andYear:cYear]; 
	// fill current month
	int i, j,k;
	k = 0;
	UIButton *tempButt;
	UIImageView * tempImgView;
	
	DayProgress *tempProgress;

	for (i = 0; i < [buttonArray count]; i++ ) {
		tempImgView = [imgArray objectAtIndex:i];
		tempImgView.image = nil;
		tempButt = [buttonArray objectAtIndex:i];
		tempButt.enabled = FALSE;
	}
	
	
	// fill with images of training day
	for ( i = 0; i< nTotalDayOfThisMonth; i++ ) {
		tempButt = [buttonArray objectAtIndex: (i+weekdayOfBeginOfMonth) ];
		tempImgView = [imgArray objectAtIndex:(i + weekdayOfBeginOfMonth)];
		if (k < [progressArray count]) { 
			 tempProgress = [progressArray objectAtIndex:k];
			int day = tempProgress.day % 100;
			// if today need an image
			if ( i == (day - 1)) {
				int temp = [tempProgress getPercentage];
				
				if (temp > 75.0) tempImgView.image = goodImage;
				else {
					if (temp > 50.0 ) tempImgView.image = normalImage;
					else { if (temp > 25.0) tempImgView.image = badImage;
						else tempImgView.image = veryBadImage;
					}
				}
				k++;
				tempButt.enabled = TRUE;
			} else {
				tempButt. enabled = FALSE;
			}
		}
		[tempButt setTitle: [NSString stringWithFormat:@"%d  ", i+1] forState: UIControlStateNormal];
		[tempButt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		//tempButt.titleLabel.textColor = [UIColor blueColor];

	// Sunday is red
		if (!((i+weekdayOfBeginOfMonth) % 7)) 
			[tempButt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
			//tempButt.titleLabel.textColor = [UIColor redColor];
		tempButt.hidden = FALSE;
	}
	startOfNextMonthPosition = i + weekdayOfBeginOfMonth;
	startOfMonthPosition = weekdayOfBeginOfMonth;
	
	tempButt = nil;
	tempImgView = nil;
	tempProgress = nil;
	
	// fill previous month
	j= weekdayOfBeginOfMonth-1;
	i = nTotalDayOfPreviousMonth;
	while (j>=0) {
		UIButton *tempButt = [buttonArray objectAtIndex: j --];	
		[tempButt setTitle:[NSString stringWithFormat:@"%d  ", i--]  forState: UIControlStateNormal];
		//tempButt.titleLabel.textColor = [UIColor grayColor];
		[tempButt setTitleColor:[UIColor grayColor] forState: UIControlStateNormal];
	}

	// fill next month
	NSInteger occupiedField = weekdayOfBeginOfMonth + nTotalDayOfThisMonth -1 ;
	NSInteger limitField;
	if (occupiedField < 28) limitField = 28;  
	else if (occupiedField < 35) limitField = 35;
	else if (occupiedField < 42) limitField = 42;
	i = occupiedField + 1;
	j = 1;
	while (i< limitField) {
		UIButton *tempButt = [buttonArray objectAtIndex: i ++];	
		[tempButt setTitle:[NSString stringWithFormat:@"%d  ", j++]  forState: UIControlStateNormal];
		[tempButt setTitleColor:[UIColor grayColor] forState: UIControlStateNormal];
		tempButt.hidden = FALSE;
	}
	
	if (limitField != 42) {
		for (i = limitField; i< 42; i++) {
			UIButton *tempButt = [buttonArray objectAtIndex: i ];	
			tempButt.hidden = TRUE;
		}
	}
	//[thisMonth release];
	[progressArray release];
}
									  
- (int) getMaxDaysFor : (NSInteger) month andYear: (NSInteger) year {
	NSInteger result = 0;
	switch (month) {
		case 1: 
		case 3: 
		case 5:
		case 7: 
		case 8: 
		case 10: 
		case 12:
			result = 31;
			break;
		case 4:
		case 6: 
		case 9:
		case 11:
			result = 30;
			break;
		case 2: 
			// check leap year
			if ((!(year % 400)) || ( (!(year % 4))&& (year % 100))) {
				result = 29;
			}
			else {
				result = 28;
			}
			break;
		default:
			break;
	}	
	return result;
}

- (int) getMaxDaysForPreviousMonthOf: (NSInteger) month andYear : (NSInteger )year {
	return (month == 1) ? ([self getMaxDaysFor:12 andYear:(year -1)]) : ([self getMaxDaysFor:month-1 andYear:year]);
}

- (void) clearAllImages {
	for (int i = 0; i < 42; i ++) {
		UIImageView * imgView = [imgArray objectAtIndex:i];
		imgView.image = nil;
	}
}

- (IBAction) buttonClicked: (id) action {
	//UIButton *selectedButton = (UIButton*) action;
	NSInteger selectedButtonPosition;
	NSInteger selectedDay;
	for (int i=0; i< 42; i++ ) {
		if (action == [buttonArray objectAtIndex:i]) {
			selectedButtonPosition = i;
			UIButton *tempButt = [buttonArray objectAtIndex:i];
			selectedDay =[tempButt.titleLabel.text intValue];
			break;
		}
	}
	
	if (selectedButtonPosition > startOfNextMonthPosition || selectedButtonPosition < startOfMonthPosition) {
		// move to other views
		
		//selectedButton.titleLabel.textColor = [UIColor grayColor];
	}
	else {
		DayProgress *tempProgress ;
		for (int i = 0 ; i< [progressArray count]; i++) {
			tempProgress = [progressArray objectAtIndex:i];
			if ((tempProgress.day%100) == selectedDay) break;
		}
		Piechart * pieChart = [[Piechart alloc] initWithFrame:self.view.frame totalValue:tempProgress.totalWorkout finishedValue: tempProgress.workoutCompleted];
		pieChart.delegate = self;
		PiechartViewController *viewController = [[PiechartViewController alloc] init];
		viewController.view = pieChart;
	
		viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:viewController animated:YES];
		//selectedButton.titleLabel.textColor = [UIColor blueColor];
	}

	NSLog(@"Selected button index is : %d" , selectedButtonPosition);
}

- (void) previousMonthClicked: (id) action {
	//NSLog(@"Selected button index is : %d" , selectedButtonPosition)
}

- (void) nextMonthClicked: (id) action {
	
}

- (void) thisMonthClicked {
	
}

- (void) viewDidFinishedDisplaying: (Piechart*) pie {
	[self dismissModalViewControllerAnimated:YES];
}


@end
