//
//  ViewHolderController.h
//  iTrainer
//
//  Created by Tuan VU on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatisticMenuController.h"
#import "Piechart.h"
@interface ViewHolderController : UIViewController {
	StatisticMenuController * statsController;
	Piechart *pieChartView;
}

@end
