//
//  DetailCellView.m
//  iTrainer
//
//  Created by Tuan VU on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailCellView.h"


@implementation DetailCellView
@synthesize seri, imageView, text, image, background, buttImage;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction) buttonPressed : (id) sender {
	if (!delegate) delegate = [[UIApplication sharedApplication] delegate];
	if (!seri.status) {
		seri.status = 1;
		if ([delegate.dataSource updateProgressOfSeri:seri]) {
			if (!image) image = [UIImage imageNamed:@"checkmark-steel.png"];
			imageView.image = image;
		}
		else {
			seri.status = 0;
			[delegate.dataSource updateProgressOfSeri:seri];
		}
	}
	else {
		seri.status = 0;
		if ([delegate.dataSource updateProgressOfSeri:seri]) {
			if (!buttImage) buttImage = [UIImage imageNamed:@"checkmar-steel-off.png"];
			imageView.image = buttImage;
		}
		else {
			seri.status = 1;
			[delegate.dataSource updateProgressOfSeri:seri];
		}
	}
}


@end
