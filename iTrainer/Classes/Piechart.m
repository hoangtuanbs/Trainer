//
//  Piechart.m
//  iTrainer
//
//  Created by Tuan VU on 8/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Piechart.h"


#define PI 3.14159265358979323846
static inline float radians(double degrees) { return degrees * PI / 180; }

@implementation Piechart
@synthesize totalValue, finishedValue;
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame totalValue: (NSInteger) total finishedValue: (NSInteger) finished {
    if (self = [super initWithFrame:frame]) {
        totalValue = total;
		finishedValue = finished;
		srand(time(NULL));
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
		NSString *currentLanguage = [languages objectAtIndex:0];
		
		NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
		NSLog(@"Current language: %@", currentLanguage);
		//NSLog(@"Welcome Text: %@", NSLocalizedString(@"Workout", @""));
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	
	CGRect parentViewBounds = self.bounds;
	// get centre point
	CGFloat x = CGRectGetWidth(parentViewBounds)/2.0;
	CGFloat y = CGRectGetHeight(parentViewBounds)*0.55 - 50.0;
	
    // get the graphics context and clear it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);

	
	
	// need some values to draw pie charts
	
	double remainingCapacity = totalValue - finishedValue ; // 
	double totalCapacity =  totalValue;
	//double systemCapacity = 1;
	
	int offset = 10; // displacement between two pie
	
	// starting point of pie
	// depending start point, we have different snapshot_start
	double snapshot_start = rand() % 360;	
	double snapshot_finish = remainingCapacity * 360.0 / totalCapacity; 
	//double system_finish = systemCapacity * 360.0 / totalCapacity;
	double radius = 120;
	
	// draw remaining part
	
    CGContextSetFillColor(ctx, CGColorGetComponents( [[UIColor greenColor] CGColor]));
	double angle = radians( snapshot_finish/2.0 + snapshot_start);
	
	double X;
	double Y;
	
	X = x + offset * cos (angle);
	Y = y + offset * sin(angle);
	
    CGContextMoveToPoint(ctx, X , Y );
    CGContextAddArc(ctx, X , Y , radius,  radians(snapshot_start), radians(snapshot_start + snapshot_finish), 0); 
    CGContextClosePath(ctx); 
    CGContextFillPath(ctx); 
	
	UIFont *font = [UIFont boldSystemFontOfSize:18];
	CGPoint point = CGPointMake(28,372);
	
	[[NSString stringWithFormat:@"%@ : %.0f %%", NSLocalizedString(@"Total workout waiting", @"") ,100* remainingCapacity/totalCapacity] drawAtPoint:point withFont:font];
	
	/*
	/* data capacity */
	if (finishedValue> 0 ) {
		CGContextSetFillColor(ctx, CGColorGetComponents( [[UIColor blueColor] CGColor]));
		CGContextMoveToPoint(ctx, x, y );     
		if ( finishedValue != totalCapacity) 
			CGContextAddArc(ctx, x, y, radius,  radians(snapshot_start + snapshot_finish), radians(snapshot_start), 0); 
		else
			CGContextAddArc(ctx, x, y, radius, radians(0), radians(360), 0);
		CGContextClosePath(ctx); 
		CGContextFillPath(ctx);	
  
		// draw help text
		point = CGPointMake(28,352);
		double capacity= 100 * ( 1 - remainingCapacity / totalCapacity) ;
		[[NSString stringWithFormat:@"%@: %.0f %%", NSLocalizedString(@"Total workout done", @""),capacity] drawAtPoint:point withFont:font];
	}
	
	//CATransition
}


- (void)dealloc {
    [super dealloc];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
	[self.delegate viewDidFinishedDisplaying: self];
}


@end
