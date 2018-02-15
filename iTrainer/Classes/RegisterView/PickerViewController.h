//
//  PickerViewController.h
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PickerViewController : UIViewController 
<UIPickerViewDataSource, UIPickerViewDelegate> {
	UIPickerView *pickerView;
	NSArray *dataSource;
	UITextField *text;
}

@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) UITextField *text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData: (NSArray*) data andSelectionObject: (id) sender;
- (void) pickerSelect;
- (IBAction) resign: (id) sender;
- (void) reloadViewWithData: (NSArray*) data andSelectionObject: (id) object;
@end
