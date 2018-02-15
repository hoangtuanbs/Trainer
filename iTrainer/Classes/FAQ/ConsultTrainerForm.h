//
//  ConsultTrainerForm.h
//  iTrainer
//
//  Created by Tuan VU on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ConsultTrainerForm : UIViewController <UITextViewDelegate> {
	UITextView *textView;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@end
