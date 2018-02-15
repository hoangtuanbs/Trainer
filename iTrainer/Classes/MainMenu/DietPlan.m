//
//  DietPlan.m
//  iTrainer
//
//  Created by Tuan VU on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DietPlan.h"

@interface DietPlan () 

- (void) changePlan: (id) sender;
- (void) reloadView ;
@end

@implementation DietPlan
@synthesize tableview;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	dataSource = [[NSMutableArray alloc] init];
	tempArr= [[NSArray alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath]  
															   stringByAppendingPathComponent:@"diet.plist"]];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	//int gender = appDelegate.dataSource.user.gender ;
	//int program = appDelegate.dataSource.user.program;
	[self reloadView];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Change", "") style:UIBarButtonItemStyleBordered target:self action:@selector(changePlan:)] autorelease];
	NSLog(@"DietPlan: Created");
	//tableview.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"stats-bg.png"]];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) viewWillAppear: (BOOL) animated {
	//[appDelegate.navMainMenuController setToolbarHidden:YES animated:animated];
	// hide navigation bar
	//[appDelegate.navMainMenuController setNavigationBarHidden:NO animated:animated];
	[self.navigationController setToolbarHidden:YES animated:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}
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
	NSLog(@"Dietplan: Destroyed");
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataSource count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *dictionary = [dataSource objectAtIndex:section];
	NSArray *array = [dictionary objectForKey:@"Menu"];
	return [array count];
   
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSDictionary *dictionary = [dataSource objectAtIndex:indexPath.section];
	NSArray *array = [dictionary objectForKey:@"Menu"];
	NSString *cellValue = [array objectAtIndex:indexPath.row];
	cell.textLabel.text = cellValue;
    // Set up the cell...
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDictionary *dictionary = [dataSource objectAtIndex:section];
	//NSArray *array = [dictionary objectForKey:@"Menu"];
	return [dictionary objectForKey:@"Name"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (void) changePlan: (id) sender {
	if (!changeDietPlanView) {
		changeDietPlanView = [[ChangeDietPlan alloc] initWithNibName:@"ChangeDietPlan" bundle:nil];
		changeDietPlanView.parentView = self;
	}
	[self.view addSubview:changeDietPlanView.view];
	//[self.navigationController pushViewController:changeDietPlanView animated:YES];
}	

- (void) reloadView {
	int selectedDiet = 0;
	if (appDelegate.dataSource.user.dietPlan == 0) {
		selectedDiet = (appDelegate.dataSource.user.gender  ? 2 : 3);
	} else {
		selectedDiet = (appDelegate.dataSource.user.gender ? 0 : 1 );
	}
	dataSource = [[NSArray alloc] initWithArray:[[tempArr objectAtIndex:selectedDiet] objectForKey:@"Plan"]];
	
}

- (void) viewShouldReload {
	[self reloadView];
	[self.tableview reloadData];
}
@end
