//
//  WorkOutTableViewCellController.m
//  iTrainer
//
//  Created by Tuan VU on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WorkOutTableViewCellController.h"


@implementation WorkOutTableViewCellController
@synthesize header, delegateApp;
@synthesize detail, button, state, checkmark, imageView, view, checkmarkNon;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		if (!delegateApp) delegateApp = [[UIApplication sharedApplication] delegate];
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) changeState: (id) sender {
	if (!delegateApp) delegateApp = [[UIApplication sharedApplication] delegate];
	if ([state statusOfSeries] == 0 ) {
		[state defineStatus:1];
		if ([delegateApp.dataSource updateProgressOfSeries:state.series]) {
			imageView.image = checkmark;
		} else {
			[state defineStatus:0];
		}
	}
	else {
		[state defineStatus:0];

		if ([delegateApp.dataSource updateProgressOfSeries:state.series]) {
			imageView.image = checkmarkNon;
		} else {
			[state defineStatus:1];;
		}
	}
	;
}

- (void)dealloc {
	[header release];
	[detail release];
	[button release];
	[imageView release];
    [super dealloc];
}



@end
