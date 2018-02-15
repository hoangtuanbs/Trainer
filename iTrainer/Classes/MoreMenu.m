//
//  MoreMenu.m
//  iTrainer
//
//  Created by Tuan VU on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MoreMenu.h"
#import "Piechart.h"

@implementation MoreMenu
@synthesize changeInforLabel, aboutLabel;
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
	delegate = [[UIApplication sharedApplication] delegate];
	self.navigationController.title = NSLocalizedString( @"More", "");
	self.navigationItem.title = NSLocalizedString( @"More", "");
	[changeInforLabel setText: NSLocalizedString(@"Change information", "")];
	[changeInforLabel setText: NSLocalizedString(@"About", "")];
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
	[self.navigationController setNavigationBarHidden:YES animated: animated];
	[delegate.navMainMenuController setNavigationBarHidden:YES animated:animated];
	[delegate.navMainMenuController setToolbarHidden:YES animated:animated];
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear: (BOOL) animated {
	[delegate.navMainMenuController setNavigationBarHidden:YES animated:animated];
	[delegate.navMainMenuController setToolbarHidden:NO animated:animated];
	[super viewWillDisappear:animated];
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
    [super dealloc];
}


- (IBAction) changeInformation {
	if (!registerView) 
		registerView = [[RegisterViewController alloc] initWithDataSource:delegate.dataSource.user];
	registerView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:registerView animated:YES];

	 
}

- (IBAction) changeProgramClicked {
	//[delegate.window addSubview:pieChart];
	//Piechart *piechart = [[Piechart alloc] initWithFrame:self.view.frame];
	//[self.view addSubview:piechart];
	//[delegate.dataSource createSeries];
	//[delegate.dataSource clearAllProgressFromDay:[NSDate date]];
	
	if (!aboutPage) {
		aboutPage = [[AboutPage alloc] initWithNibName:@"AboutPage" bundle:nil];
	}
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:aboutPage animated:YES];
}


@end
