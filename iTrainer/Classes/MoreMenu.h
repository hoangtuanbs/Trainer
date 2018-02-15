//
//  MoreMenu.h
//  iTrainer
//
//  Created by Tuan VU on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTrainerAppDelegate.h"
#import "RegisterViewController.h"
#import "AboutPage.h"
@interface MoreMenu : UIViewController  {
	iTrainerAppDelegate *delegate;
	RegisterViewController *registerView;
	AboutPage *aboutPage;
	
	UILabel *changeInforLabel;
	UILabel *aboutLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *changeInforLabel;
@property (nonatomic, retain) IBOutlet UILabel *aboutLabel;
- (IBAction) changeInformation ;
- (IBAction) changeProgramClicked;
@end
