//
//  PopupView.h
//  HitMusic
//
//  Created by Tuan VU on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PopupView : UIViewController {
	UIImageView *meterImageView;
	UIButton *needleImageView;
	
}

- (void) moveNeedle:(int)leftRight;
- (void) removeView;
@property (nonatomic, retain) IBOutlet UIImageView *meterImageView;
@property (nonatomic, retain) IBOutlet UIButton *needleImageView;
@end
