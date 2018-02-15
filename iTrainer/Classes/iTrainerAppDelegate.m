//
//  iTrainerAppDelegate.m
//  iTrainer
//
//  Created by Tuan VU on 5/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iTrainerAppDelegate.h"
#import "RegisterViewController.h"


@implementation iTrainerAppDelegate

@synthesize window;
@synthesize navMainMenuController;
@synthesize tabBarRootViewController;
@synthesize appData, dataSource, internetConnector;
#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    appData = [[NSDictionary alloc]  initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] 
															 stringByAppendingPathComponent:@"lang-en.plist"]];
	
	dataSource = [[DataSource alloc] init];
	
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	//NSString *currentLanguage = [languages objectAtIndex:0];
	
	//NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	
	
	internetConnector = [[InternetConnector alloc] init];
    // Override point for customization after app launch 
	if (![dataSource isRegistered]) {
		RegisterViewController * registerView = [[RegisterViewController alloc] initWithNibName:@"RegisterView" bundle:nil] ;
		registerView.view.frame = CGRectMake(0, 20.0, 320, 480);
		[window addSubview:registerView.view];
		
	} else if (dataSource.user.program == 0 ) {
		RegisterViewController * registerView = [[RegisterViewController alloc] initWithDataSource:dataSource.user] ;
		[window addSubview:registerView.view];
	}
	else {
		[window addSubview: tabBarRootViewController.view];
	}	
	
	[window makeKeyAndVisible];
	NSLog(@"Application delegate: created");
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	

}

#pragma mark -
#pragma mark Loading view 
- (void) displayLoadingView {
	if (!loadingView ) {
		loadingView = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
	}
	//[tabBarRootViewController.view removeFromSuperview];
	[window addSubview: loadingView.view];
	
}


- (void) removeLoadingView {
	//[window addSubview:tabBarRootViewController.view];
	[loadingView.view performSelector:@selector(removeFromSuperview) withObject: nil afterDelay: 1.0];
}	


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[dataSource release];
	[tabBarRootViewController release];
	[navMainMenuController release];
	[appData release];
	[window release];
	[tabBarRootViewController release];
	[navMainMenuController release];
	
	NSLog(@"Application delegate: Destroyed");
	[super dealloc];
}


@end

