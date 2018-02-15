//
//  InTheNewsPopup.h
//  HitMusic
//
//  Created by Tuan VU on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InTheNewsPopup : UIViewController {
	UIButton *extendView;
}

@property (nonatomic, retain) IBOutlet UIButton *extendView;

- (IBAction) extendViewClicked : (id) sender;
- (void) removeView;
@end
