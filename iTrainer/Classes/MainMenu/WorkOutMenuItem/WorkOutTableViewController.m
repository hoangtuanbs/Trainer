//
//  WorkOutTableViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "WorkOutTableViewController.h"
#import "WorkOutTableViewCellController.h"

#import "Series.h"
@implementation WorkOutTableViewController
#define animation YES
@synthesize dataSource;
@synthesize  date;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		if (!date) {
			date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
		}
		self.view.opaque =0.0;
    }
    return self;
}

- (id) initWithDate: (NSDate*) cDay {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		date = cDay;
		
	}
	return self;
}

// action when view is load
- (void)viewDidLoad {
	if (!delegate) delegate = [[UIApplication sharedApplication] delegate];
	database = delegate.dataSource;
	
	// load image 
	if (!checkmark) checkmark = [UIImage imageNamed:@"checkmark-steel-part.png"];
	if (!checkmarkFull ) checkmarkFull = [UIImage imageNamed:@"checkmark-steel.png"];
	if (!checkmarkNon) checkmarkNon = [UIImage imageNamed:@"checkmark-steel-off.png"];
	if (!date)
		date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	[self initDataSource];
	selectedIndex = -1;
	controllerView = [[UIViewController alloc] init];

	[super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WorkOutTableViewCellIdentifier";
    
    WorkOutTableViewCellController *cell = (WorkOutTableViewCellController*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WorkOutTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Set up the cell...
	NSUInteger row = [indexPath row];
	WorkoutDetail * workoutDetail = [dataSource objectAtIndex:row];
	cell.header.text = [workoutDetail name];
	NSMutableString *detailString = [[NSMutableString alloc] initWithString:NSLocalizedString( @"Series:", "")];
	Series * tempSeri;
	for (int i = 0; i < [workoutDetail.series count]-1; i++) {
	
		tempSeri = [workoutDetail.series objectAtIndex:i];
		[detailString appendString: [NSString stringWithFormat:@"%@,", [tempSeri getStatusShortString]]];
	}

	// get the seri
	tempSeri = [workoutDetail.series objectAtIndex:[workoutDetail.series count] -1];;
	//if (workoutDetail.display) 
	[detailString appendString: [tempSeri getStatusShortString]];
	if (workoutDetail.display) cell.detail.text = detailString;
	else cell.detail.text = @"";
	cell.state = [dataSource objectAtIndex:row];
	cell.checkmark = checkmarkFull;
	cell.checkmarkNon = checkmarkNon;
	//cell.view.image = midCell;
	
	int statusOfSeries = [cell.state statusOfSeries];
	switch (statusOfSeries) {
		case kStatusEmpty:
			cell.imageView.image = checkmarkNon;
			break;
		case kStatusPartial:
			cell.imageView.image = checkmark;
			break;
		case kStatusFull:
			cell.imageView.image = checkmarkFull;
			break;

		default:
			break;
	}
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedIndex = [indexPath row];
	WorkoutDetail * workoutDetail = [dataSource objectAtIndex:[indexPath row]];
	// if we dont want to display detail workout
	if (!workoutDetail.display) return; 
	if (!currentView) {
		currentView = [[WorkoutDetailV2 alloc] initWithWorkout:[dataSource objectAtIndex:selectedIndex]];
		currentView.viewDelegate = self;
		currentView.hidesBottomBarWhenPushed = YES;
	} else {
		[currentView updateViewWithWorkout:[dataSource objectAtIndex:selectedIndex]];
	}
	
	controllerView.hidesBottomBarWhenPushed = YES;
	[delegate.navMainMenuController pushViewController:controllerView animated:animation];
	[controllerView.view addSubview: currentView.view];
	[currentView viewWillAppear:YES];

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	if (currentView) [currentView release];
	if (hiddenView) [hiddenView release];
	[checkmark release];
	[checkmarkFull release];
	[checkmarkNon release];
	
	[delegate release];
	[dataSource release];
    [super dealloc];
}

#pragma mark -
#pragma mark TableView Custom Methods

// init data for table
- (void) initDataSource {
	if (dataSource ) [ dataSource release];
	dataSource = [database getWorkOutDetailAtTime:date];
}

- (void) viewShouldTransitToNextView: (WorkoutDetailV2*) view {
	
	[delegate displayLoadingView];
	if (selectedIndex < ([dataSource count] - 1)) {
		CATransition * transition ;//= [CATransition animation];
		transition = [[CATransition alloc] init];
		WorkoutDetail*  wk = [dataSource objectAtIndex:++selectedIndex ];
		if (wk.display) {
			if (!hiddenView ) {
				hiddenView = [[WorkoutDetailV2 alloc] initWithWorkout:[dataSource objectAtIndex:selectedIndex]];
				hiddenView.viewDelegate = self;
				hiddenView.hidesBottomBarWhenPushed = YES;
			} else {
				[hiddenView updateViewWithWorkout:wk];
			}
		
			[view viewWillDisappear:YES];
			[view.view removeFromSuperview];
			[controllerView.view addSubview:hiddenView.view];
			[hiddenView viewWillAppear:YES];

			[transition setType:kCATransitionPush];
			[transition setSubtype:kCATransitionFromRight];
			[transition setDuration:0.3];
			[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
			[[controllerView.view layer] addAnimation:transition forKey:@"any animation"];
			WorkoutDetailV2 * temp = currentView;
			currentView = hiddenView;
			hiddenView = temp;
			//[temp release];
		} else {
			selectedIndex --;
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Notice", "") 
																 message:NSLocalizedString( @"This is the end of the training program", "")
																delegate:self 
													   cancelButtonTitle:NSLocalizedString( @"OK" , "")
													   otherButtonTitles:nil] 
									  autorelease];
			[alertView show];
		}

	}
	[delegate removeLoadingView];
}

- (void) viewShouldTransitToPreviousView: (WorkoutDetailV2*) view {
	[delegate displayLoadingView];
	if (selectedIndex >0){
		CATransition * transition  = [[CATransition alloc] init];
		WorkoutDetail*  wk = [dataSource objectAtIndex:--selectedIndex];
		if ([wk display]) { 
			if (!hiddenView ) {
				hiddenView = [[WorkoutDetailV2 alloc] initWithWorkout:wk] ;
				hiddenView.viewDelegate = self;
				hiddenView.hidesBottomBarWhenPushed = YES;
			} else {
				[hiddenView updateViewWithWorkout:wk];
			}
			
			
			[view viewWillDisappear:YES];
			[view.view removeFromSuperview];
			[controllerView.view addSubview:hiddenView.view];
			[hiddenView viewWillAppear:YES];
			
			[transition setType:kCATransitionPush];
			[transition setSubtype:kCATransitionFromLeft];
			[transition setDuration:0.3];
			[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
			[[controllerView.view layer] addAnimation:transition forKey:@"any animation"];
			
			WorkoutDetailV2 * temp = currentView;
			currentView = hiddenView;
			hiddenView = temp;
			//[temp release];
		}
		else {
			selectedIndex ++;
		}
	}
	[delegate removeLoadingView];
}
@end

