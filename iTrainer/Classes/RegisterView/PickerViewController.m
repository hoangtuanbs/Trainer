//
//  PickerViewController.m
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PickerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PickerViewController
@synthesize pickerView;
@synthesize dataSource;
@synthesize text;

// init view with given nib, bundle, datasource and object
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData: (NSArray*) data andSelectionObject: (id) sender {
	
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		dataSource = [[NSArray alloc] initWithArray:data];
		text= (UITextField*) sender;
		[text resignFirstResponder];

        // Custom initialization
    }
    return self;
}

// set up when view going to appear
- (void) viewWillAppear: (BOOL) animated {
	if (animated) {
		CATransition *animation = [CATransition animation];
		[animation setType:kCATransitionFade];
		[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
	}
	[super viewWillAppear:animated];
}

- (void) reloadViewWithData: (NSArray*) data andSelectionObject:(id) object{
	if (dataSource) [dataSource release];
	dataSource = [[NSArray alloc] initWithArray:data];
	text= (UITextField*) object;
	[text resignFirstResponder];
	[pickerView reloadAllComponents];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self becomeFirstResponder];
	    [super viewDidLoad];
}

// action to resign responder
- (IBAction) resign: (id) sender {
	[self pickerSelect];
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

- (void) pickerSelect {
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[super.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
	// remove current view 
	[self.view removeFromSuperview];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
	return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
	return [dataSource count];
}

- (NSString*) pickerView: (UIPickerView *) pickerView titleForRow: (NSInteger) row forComponent:(NSInteger) component {
	return [dataSource objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	text.text = [dataSource objectAtIndex:row];
	[self pickerSelect];
}
@end
