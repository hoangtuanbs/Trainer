//
//  iTrainerAppDelegate.h
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "MainMenuNavigationController.h"
#import "DataSource.h"
#import "InternetConnector.h"
#import "LoadingViewController.h"
@interface iTrainerAppDelegate : NSObject <UIApplicationDelegate> {


	LoadingViewController *loadingView;
    UIWindow *window;
	UITabBarController *tabBarRootViewController;
	MainMenuNavigationController *navMainMenuController;
	NSDictionary *appData;
	DataSource *dataSource;
	InternetConnector *internetConnector;

}



@property (nonatomic, retain) NSDictionary *appData;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarRootViewController;
@property (nonatomic, retain) IBOutlet MainMenuNavigationController *navMainMenuController;

@property (nonatomic, retain) DataSource *dataSource;
@property (nonatomic, retain) 	InternetConnector *internetConnector;


@property (nonatomic, retain) IBOutlet UIWindow *window;


- (void) removeLoadingView ;
- (void) displayLoadingView;
@end

