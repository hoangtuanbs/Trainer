//
//  WorkoutDetailV2.m
//  iTrainer
//
//  Created by Tuan VU on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WorkoutDetailV2.h"
#import "DetailCellView.h"

@implementation WorkoutDetailV2
@synthesize mainLabel, tblView, nextButton, prevButton, imgView, InstructionView, workoutDetail;
@synthesize viewDelegate, scrollView, tableContainer;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithWorkout: (WorkoutDetail*) newWorkout {
    if (self = [super initWithNibName:@"WorkoutDetailV2" bundle:nil]) {
        // Custom initialization
    }
	workoutDetail = newWorkout;
	dataSource = workoutDetail.series;
	image = [UIImage imageNamed:@"checkmark-steel.png"];
	[self setTitle:[NSString stringWithFormat: @"%@", workoutDetail.group]];
	cellBkImage = [UIImage imageNamed: @"cell-bk.png"];
	headerBkImage = [UIImage imageNamed:@"cell-bk-header.png"];
	checkMarkOff =  [UIImage imageNamed:@"checkmark-steel-off.png"];
	if (!appDelegate) appDelegate = [[UIApplication sharedApplication] delegate];
	return self;
}


- (void) updateViewWithWorkout: (WorkoutDetail*) newWorkout {
	workoutDetail = newWorkout;
	dataSource = workoutDetail.series;
	[self setTitle:[NSString stringWithFormat: @"%@", workoutDetail.group]];
	[self viewDidLoad];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	count = 0;
	mainLabel.text = workoutDetail.name;

	
    if (!workoutDetail.display) {
		[tblView removeFromSuperview];
	} else {
		[self.view addSubview:tblView];

	}
	
	NSMutableString *tempString = [[NSMutableString alloc] init];
	if (workoutDetail.preparation ) {
		[tempString appendString:[NSString stringWithFormat: @"%@: %@ ", NSLocalizedString( @"Preparation", ""), workoutDetail.preparation]];
	}
	if (workoutDetail.execution  ) {
		[tempString appendString:[NSString stringWithFormat: @"%@: %@ ", NSLocalizedString(@"Execution", ""),  workoutDetail.execution]];
	}
	if (workoutDetail.comment ) {
		[tempString appendString:[NSString stringWithFormat: @"%@: %@ ", NSLocalizedString( @"Comment", "" ), workoutDetail.comment]];
	}
	
	InstructionView.text = tempString;
	//NSArray *currentImage  = imgView.animationImages;
	
	NSArray *imagesArray =  [appDelegate.dataSource getImagesForWorkoutID:workoutDetail.workoutID];
	if (imagesArray) {
		imgView.animationImages = imagesArray;
		
		imgView.animationDuration = [imagesArray count]*(([imagesArray count] > 10) ? 0.1 : 0.2) ;
		imgView.animationRepeatCount = 0;
	}
	//if (currentImage) [currentImage autorelease];
	scrollView.contentSize = CGSizeMake(320.0, 700.0);
	NSLog(@"Workout detail: Created");
    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL) animated {
	[imgView performSelector:@selector(startAnimating) withObject: nil afterDelay: 0.2];
	if (workoutDetail.group) 
		[self setTitle: workoutDetail.group];
	[super viewWillAppear:animated];
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
	[nextButton release];
	[prevButton release];
	[mainLabel release];
	
	[imgView release];
	//[image release];

	[InstructionView release];
	[dataSource release];

	[scrollView release];
	
	[tableContainer release];
	
	//[headerBkImage release];
	//[cellBkImage release];
	NSLog(@"Workout detail: Destroyed.");
    [super dealloc];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WorkOutTableViewCellIdentifier2";
    
    DetailCellView *cell = (DetailCellView*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Set up the cell...
	NSUInteger row = [indexPath row];
	//if (row % 2==0) {
	cell.background.image = cellBkImage;
	tableView.separatorColor = [UIColor blackColor];
	//}
	//else cell.background.image = evenImage;
	Series *seri = [workoutDetail.series objectAtIndex:row];
	cell.seri = seri;
	if (seri.status) {
		cell.imageView.image = image;
		cell.image = image;
		cell.buttImage = checkMarkOff;
	}
	else {
		cell.imageView.image = checkMarkOff;
		cell.image = image;
		cell.buttImage = checkMarkOff;
	}

	cell.text.text = [NSString stringWithFormat:@"%d %@ %@", seri.repeat, NSLocalizedString( @"times", "") ,[seri getStatusString] ];
	
	return cell;
}

- (IBAction) buttonPreviousPressed: (id) sender {
	if ([viewDelegate respondsToSelector:@selector(viewShouldTransitToPreviousView:)]) {
		[viewDelegate viewShouldTransitToPreviousView:self];
	}
}
- (IBAction) buttonNextPressed: (id) sender { 
	if ([viewDelegate respondsToSelector:@selector(viewShouldTransitToNextView:)]) {
		[viewDelegate viewShouldTransitToNextView:self];
	}
}

- (void) setTitle: (NSString*) title {
	self.navigationItem. title = title;
}
@end
