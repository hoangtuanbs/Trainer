//
//  DetailCellView.h
//  iTrainer
//
//  Created by Tuan VU on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Series.h"
#import "iTrainerAppDelegate.h"
@interface DetailCellView : UITableViewCell {
	UILabel *text;
	UIImageView *imageView;
	UIImage* image;
	UIImage * buttImage;
	Series *seri;
	iTrainerAppDelegate *delegate;
	UIImageView *background;
}

@property (nonatomic, retain) IBOutlet UILabel *text;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) Series *seri;
@property (nonatomic, assign) UIImage *image;
@property (nonatomic, assign) UIImage *buttImage; 
@property (nonatomic,retain) IBOutlet UIImageView *background;
- (IBAction) buttonPressed: (id) sender ;
@end
