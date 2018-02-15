//
//  Piechart.h
//  iTrainer
//
//  Created by Tuan VU on 8/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiechartViewController.h"
@class Piechart;
@protocol PiechartViewDelegate 
@optional
- (void) viewDidFinishedDisplaying: (Piechart*) view;

@end

@interface Piechart : UIView {
	NSInteger totalValue;
	NSInteger finishedValue;
	id <PiechartViewDelegate> delegate;
}

@property (nonatomic, retain) id <PiechartViewDelegate> delegate;
@property (nonatomic) NSInteger totalValue;
@property (nonatomic) NSInteger finishedValue;
- (id)initWithFrame:(CGRect)frame totalValue: (NSInteger) total finishedValue: (NSInteger) finished; 
@end
