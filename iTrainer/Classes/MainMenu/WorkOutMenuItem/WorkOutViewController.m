//
//  WorkOutViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WorkOutViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface WorkOutViewController () 
- (NSString*) getWeekdayFromTime:(NSDate*) date;
- (BOOL) isToday : (NSDate*) today ;
- (void) backToToday: (id) sender;
@end

#pragma mark -
@implementation WorkOutViewController
@synthesize tableView;
@synthesize delegate;
@synthesize menuTitle, noworkout;
@synthesize buttonPrv, buttonNxt;
@synthesize header, dayHeader;
#define kAnimationKey @"Animation"
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}*/


- (void) viewWillAppear: (BOOL) animated {
	if ([tableView.dataSource count]<1) {
		noworkout.hidden = NO;
	} else noworkout.hidden = YES;
	
	//init tool bar
	[delegate.navMainMenuController setToolbarHidden:YES animated:animated];
	[delegate.navMainMenuController setNavigationBarHidden:NO animated:animated];
	// reload data for display
	[tableView.tableView reloadData]; 
	
	if ([tableView.dataSource count] > 0) {
		tableView.tableView.separatorColor = [UIColor blackColor];
		tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	}
	else
		tableView.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
	
	[super viewWillAppear:animated];
}

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// Methods will create a navigation button 
//-------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	
	// Custom initialization
	inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateStyle:NSDateFormatterMediumStyle];
	[inputFormatter setTimeStyle: NSDateFormatterNoStyle];
	
	
	//NSLog(@"Workout View Controller did loaded");
	if (!delegate ) {
		delegate = [[UIApplication sharedApplication] delegate];
	}
	if (!menuTitle) {
		menuTitle = [delegate.appData objectForKey:@"WorkoutMenu"];
	}
	
	//self.navigationItem.leftBarButtonItem.title = @"Done";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Done", "")
																			 style: UIBarButtonItemStyleBordered 
																			target:self 
																			action:@selector(popRootView)];
	tableView.tableView.separatorColor = [UIColor blackColor];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Today", "" ) 
																			  style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(backToToday:)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.title = NSLocalizedString(@"Workout", "");
	
	// display today in black color
	header.text =  [inputFormatter stringFromDate:[NSDate date]];
	header.textColor = [UIColor blackColor];
	dayHeader.text = [self getWeekdayFromTime:[NSDate date]];
	dayHeader.textColor = [UIColor blackColor];
	
    [super viewDidLoad];
}

- (void) popRootView {
	
	[delegate.navMainMenuController popToRootViewControllerAnimated:YES];
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
	NSLog(@"Dealloc workout view controller");
	[header release];
	[buttonNxt release];
	[buttonPrv release];
	[tableView release];
	[menuTitle release];
	[delegate release];
    [super dealloc];
}


//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
// Previous button pressed
// Display data for previous day
//-------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Event Handle
- (IBAction) buttonPrvPressed: (id) sender {
	NSLog(@"Button Pre pressed");
	static NSTimeInterval secondPerDay = 24*60*60;

	NSDate *newDate = [tableView.date addTimeInterval:-secondPerDay];
	WorkOutTableViewController *newTblView =[ [[WorkOutTableViewController alloc] initWithDate: newDate] autorelease];
	
	tableView.date = newDate;
	// init data source and reload data
	if ([self isToday:newDate]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else {
		self.navigationItem.rightBarButtonItem.enabled= YES;
	}
	[tableView viewWillDisappear:YES];
	newTblView.view.frame = tableView.view.frame;
	newTblView.tableView.rowHeight = 50;
	[self.view addSubview:newTblView.view];
	[tableView.view removeFromSuperview];
	//NSLog( [tableView.date description]);
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kAnimationKey];
	
	header.text =  [inputFormatter stringFromDate:newDate];
	if ([self isToday:newDate]) {
		header.textColor = [UIColor blackColor];
		dayHeader.textColor = [UIColor blackColor];
	}
	else {
		header.textColor = [UIColor blueColor];
		dayHeader.textColor = [UIColor blueColor];
	}
	dayHeader.text = [self getWeekdayFromTime:newDate];

	tableView =[ newTblView retain];
	newTblView.tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	if ([tableView.dataSource count] > 0)
		tableView.tableView.separatorColor = [UIColor blackColor];
	else
		tableView.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
	tableView.view = [newTblView view];
	
	if ([tableView.dataSource count]<1) {
		noworkout.hidden = NO;
	} else noworkout.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
// Button next pressed
// Display data for next day
//-------------------------------------------------------------------------------------------------------------------
- (IBAction) buttonNxtPressed:(id) sender {

	NSLog(@"Button Next pressed");
	static NSTimeInterval secondPerDay = 24*60*60;// used to get next, previous day
	NSDate *newDate = [tableView.date addTimeInterval:secondPerDay];
	WorkOutTableViewController *newTblView = [[[WorkOutTableViewController alloc] initWithDate: newDate] autorelease];
	
	//[tableView.date release];
	tableView.date = newDate;
	if ([self isToday:newDate]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else {
		self.navigationItem.rightBarButtonItem.enabled= YES;
	}
	// init data source and reload data
	
	[tableView viewWillDisappear:YES];
	newTblView.view.frame = tableView.view.frame;
	newTblView.view.opaque=0.0;
	
	[self.view addSubview:newTblView.view];
	[tableView.view removeFromSuperview];
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kAnimationKey];
	header.text =  [inputFormatter stringFromDate:newDate];
	if ([self isToday:newDate]) {
		header.textColor = [UIColor blackColor];
		dayHeader.textColor = [UIColor blackColor];
	}
	else {
		header.textColor = [UIColor blueColor];
		dayHeader.textColor = [UIColor blueColor];
	}
	dayHeader.text = [self getWeekdayFromTime:newDate];

	tableView =[ newTblView retain];
	newTblView.tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	if ([tableView.dataSource count] > 0)
		tableView.tableView.separatorColor = [UIColor blackColor];
	else 
		tableView.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
	tableView.view = [newTblView view];
	if ([tableView.dataSource count]<1) {
		noworkout.hidden = NO;
	} else noworkout.hidden = YES;
}

-(NSString*) getWeekdayFromTime: (NSDate*) date {
	// init the calendar
	static const unsigned unitFlags = NSWeekdayCalendarUnit;
	if (!gregorian) gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
	NSDateComponents *weekdayComponents =
    [gregorian components:unitFlags fromDate:date];
	switch ([weekdayComponents weekday] ) {
		case 1:
			return NSLocalizedString(@"Sunday", "");
			break;
		case 2:
			return NSLocalizedString(@"Monday", "");
			break;
		case 3: return NSLocalizedString(@"Tuesday", "");
			break;
		case 4: return NSLocalizedString(@"Wednesday", "");
			break;
		case 5:
			return NSLocalizedString(@"Thursday", "");
			break;
		case 6:
			return NSLocalizedString( @"Friday", "");
			break;
		case 7:
			return  NSLocalizedString( @"Saturday", "");
			break;

		default: return nil;
			break;
	}
}

- (BOOL) isToday: (NSDate *) today {
	NSInteger todayInt ;
	NSDateFormatter* inputFormatterForConversion = [[NSDateFormatter alloc] init];
	[inputFormatterForConversion setDateFormat:@"yyyyMMdd"];
	todayInt = [[inputFormatterForConversion stringFromDate:[NSDate date]] intValue]; 
	
	NSInteger givenDayInt  = [[inputFormatterForConversion stringFromDate:today] intValue]; 
	[inputFormatterForConversion release];
	if (givenDayInt == todayInt) return TRUE;
	else return FALSE;
}

- (void) backToToday: (id) sender {
	NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	NSComparisonResult result = [newDate compare:tableView.date];
	WorkOutTableViewController *newTblView = [[[WorkOutTableViewController alloc] initWithDate: newDate] autorelease];
	
	//[tableView.date release];
	tableView.date = newDate;
	// init data source and reload data
	if ([self isToday:newDate]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else {
		self.navigationItem.rightBarButtonItem.enabled= YES;
	}
	[tableView viewWillDisappear:YES];
	newTblView.view.frame = tableView.view.frame;
	newTblView.view.opaque=0.0;
	
	[self.view addSubview:newTblView.view];
	[tableView.view removeFromSuperview];
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:(result== NSOrderedAscending)?kCATransitionFromLeft: kCATransitionFromRight];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kAnimationKey];
	header.text =  [inputFormatter stringFromDate:newDate];
	if ([self isToday:newDate]) {
		header.textColor = [UIColor blackColor];
		dayHeader.textColor = [UIColor blackColor];
	}
	else {
		header.textColor = [UIColor blueColor];
		dayHeader.textColor = [UIColor blueColor];
	}
	dayHeader.text = [self getWeekdayFromTime:newDate];
	
	tableView =[ newTblView retain];
	newTblView.tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	if ([tableView.dataSource count] > 0)
		tableView.tableView.separatorColor = [UIColor blackColor];
	else 
		tableView.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
	tableView.view = [newTblView view];
	if ([tableView.dataSource count]<1) {
		noworkout.hidden = NO;
	} else noworkout.hidden = YES;}
/*
- (void) reloadView {
	
}
*/
@end
