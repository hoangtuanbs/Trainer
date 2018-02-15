#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "MainView.h"
#import "HitMusicAppDelegate.h"
#import "InternetFileManager.h"
#import "MediaItem.h"
#import "XMLReader.h"
#import "PopupView.h"

#define ANIMATION_DURATION_IN_SECONDS (0.4)
@implementation MainView
@synthesize flipView, songLabel, singerLabel;
@synthesize mediaItem;
@synthesize sldVolume;
@synthesize lblSongName;
@synthesize	lblArtistName;
@synthesize imgMain;//, imgPopUps;
@synthesize playButton;
@synthesize forwardButton;
@synthesize hateItButton;
@synthesize lblLyricsTitle;
@synthesize menuButtons;
@synthesize menuButtons2;
@synthesize soundQualityOptions;
@synthesize viewLyrics;
@synthesize lblLyricsArtist;
@synthesize progressBar;

@synthesize imgInTheNews;
@synthesize imgYesMeter;
@synthesize imgNoMeter;
//@synthesize imgMeter;
//@synthesize imgNeedle;

@synthesize lblYes;
@synthesize lblNo;
@synthesize lblVoteNow;

@synthesize lblBigTextView;

@synthesize btnYes;
@synthesize btnNo;
@synthesize btnRegister;


// DEBUG
@synthesize lblQueuedSongs;
@synthesize lblDownloadedSongs;
@synthesize viewCurrentDownload;
// END DEBUG

@synthesize radioInterface;
@synthesize stationsView;

@synthesize moreButton;
@synthesize photosButton;
@synthesize favoritesButton;
@synthesize stationsButton;
@synthesize backButton;
@synthesize chatButton;

@synthesize txbEmail;
@synthesize txbLocation;
@synthesize txbGender;
@synthesize txbAge;

-(void)awakeFromNib {
	//NSLog(@"Inside awakeFromNib");
	[txbEmail resignFirstResponder];
	//[stationsView setDataSource:self.radioStationsArray];
	//CALayer *layer = [imgNeedle layer];
	//layer.frame = CGRectMake(225.0, 85.0, 81.0, 32.0);
	
	
	//[flipView removeFromSuperview];
	[self addSubview:registerView];
	[sldVolume setMinimumValue:0];
	[sldVolume setMaximumValue:10];
	[progressBar setProgress:0.0];
	/* Actualize progress bar */
	}

- (void) setProgress:(float)value {
	[progressBar setProgress:value];
}
- (IBAction)	moreClicked{
	[menuButtons setHidden:YES];
	[menuButtons2 setHidden:NO];
}

- (IBAction)	photosClicked {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[radioInterface removeFromSuperview];
	[self addSubview:photoView];
	[UIView commitAnimations];	
}

- (IBAction)	backToMenuClicked {
	[menuButtons setHidden:NO];
	[menuButtons2 setHidden:YES];
}

- (IBAction) favoritesClicked {
	
}

- (IBAction)chatClicked {
	[self becomeFirstResponder];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[radioInterface removeFromSuperview];
	[self addSubview:chatView];
	[UIView commitAnimations];	
}

- (IBAction)	stationsClicked {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[radioInterface removeFromSuperview];
	[self addSubview:stationsView];
	[UIView commitAnimations];	
}

- (IBAction) surveyYesClicked {
	//[self moveNeedle:3];
}



// This button can be pressed from info or debug view or any other view to bring back the main view.
- (IBAction)backToRadioClicked {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[infoInterface removeFromSuperview];
	[self addSubview:radioInterface];
	[UIView commitAnimations];
}

- (IBAction)	backToRadioFromLyrics {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[lyricsInterface removeFromSuperview];
	[self addSubview:radioInterface];
	[UIView commitAnimations];	
}

- (IBAction) lyricsClicked{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[radioInterface removeFromSuperview];
	[self addSubview:lyricsInterface];
	[UIView commitAnimations];
}

- (IBAction) registerClicked {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[registerView removeFromSuperview];
	[radioInterface removeFromSuperview];
	[self addSubview:stationsView];
	[UIView commitAnimations];
}

// debug button pressed, this is temporary 
- (IBAction)debugClicked {
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"Setting the volume");
	[appDelegate setGain:5.0];

	
	return;
	NSLog(@"*********************MediaItems*****************************");
//	for (int t=0; t < [appDelegate.mediaItems count]; t++){
//		NSLog(@"%i id= %i, handle = %@ image = %@",t,
//			  [[appDelegate.mediaItems objectAtIndex:t] primaryKey],
//			  [[appDelegate.mediaItems objectAtIndex:t] handle],  [[appDelegate.mediaItems objectAtIndex:t] image_handle]);//,[[appDelegate.mediaItems objectAtIndex:t] popUpHandle],
////			  [[appDelegate.mediaItems objectAtIndex:t] list_category_id], [[appDelegate.mediaItems objectAtIndex:t] media_type],
////			  [[appDelegate.mediaItems objectAtIndex:t] audio_downloaded],
////			  [[appDelegate.mediaItems objectAtIndex:t] image_downloaded]);
////		NSLog(@"The popUpHandle for this media item is %@",[[appDelegate.mediaItems objectAtIndex:t] popUpHandle] );
//	}
	//
//	NSLog(@"******************downloadQueue*********************************** total items is %i", [appDelegate.songsArray count]);
//	NSLog(@"Download queue has %i elements",[[appDelegate.myFileManager downloadQueue] count]);
//	for (int f=0; f < [[appDelegate.myFileManager downloadQueue] count] ; f++){
//		NSLog(@"%i file to download = %@",f,[[appDelegate.myFileManager downloadQueue] objectAtIndex:f]);
//	}
	NSLog(@"****************************************************************");
	
//		NSLog(@"*********************Clock items****************************");
//		for (int t=0; t < [appDelegate.clockItems count]; t++){
//			NSLog(@"%i list_category_id= %i, number = %i,  isActive = %i",t,[[appDelegate.clockItems objectAtIndex:t] list_category_id],
//		//		  [[appDelegate.clockItems objectAtIndex:t] no],
//				  [[appDelegate.clockItems objectAtIndex:t] isActiveItem]);
//		}
//	
//		NSLog(@"******************popUpItems***********************************");
//		for (int t=0; t < [appDelegate.popUpItems count]; t++){
//			NSLog(@"%i popUp pk= %i, isActive = %i, handle=%@",t,[[appDelegate.popUpItems objectAtIndex:t] primaryKey],
//				  [[appDelegate.popUpItems objectAtIndex:t] isActiveItem], [[appDelegate.popUpItems objectAtIndex:t] handle]);
//		}
//		NSLog(@"****************************************************************");
	
		NSLog(@"******************songsArray*********************************** total items is %i", [appDelegate.songsArray count]);
		for (int f=0; f < [appDelegate.songsArray count]; f++){
			NSLog(@"%i song=%@",f,[appDelegate.songsArray objectAtIndex:f]);
		}
		NSLog(@"****************************************************************");
	
//		NSLog(@"******************songInfoIndex*********************************** total items is %i", [appDelegate.songInfoIndex count]);
//		for (int f=0; f < [appDelegate.songInfoIndex count]; f++){
//			NSLog(@"%i index=%@",f,[appDelegate.songInfoIndex objectAtIndex:f]);
//		}	
//		NSLog(@"****************************************************************");
	
	//[audioPlayer changeVolume];
	//[NSThread detachNewThreadSelector:@selector(startDownload) toTarget:self withObject:nil];
	//	[self startDownload];
	//	[self DisplayAlert:@"Downloading file"];
}

// Exit application click
- (IBAction)exitClicked {
	exit;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//						change:(NSDictionary *)change context:(void *)context
//{
//	if ([keyPath isEqual:@"isPlaying"])
//	{
//		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//		
//		if ([(AudioStreamer *)object isPlaying])
//		{
//			NSLog(@"The file started playing");
//		}
//		else
//		{
//			[streamer removeObserver:self forKeyPath:@"isPlaying"];
//			[streamer release];
//			streamer = nil;
//			NSLog(@"The file ended playing");
//			[self loveItClicked];
//		}
//		
//		[pool release];
//		return;
//	} else {
//		NSLog(@"uncharted else");
//	}
//	
//	[super observeValueForKeyPath:keyPath ofObject:object change:change
//						  context:context];
//}


- (IBAction)	volumnChanged {
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setGain:([self.sldVolume value])];
}

// foward to next song
- (IBAction)fowardClicked {

	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[progressBar setProgress:([progressBar progress] + 0.1)];
	[appDelegate playNextSong];
	//NSLog(@"popped song from queue and its called %@ and now the readyQueue has %i elements", [appDelegate.myFileManager getReadyItem], [[appDelegate.myFileManager readyQueue] count]);
	//[self debugClicked];
	//[appDelegate.myFileManager addToQueue:@"Hello_world.m4a"];
//	[appDelegate.myFileManager downLoadFiles];
}

// Info window invocation
- (IBAction)infoClicked {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
	[radioInterface removeFromSuperview];
	[self addSubview:infoInterface];
	[UIView commitAnimations];
}

//Love it button clicked
- (IBAction)loveItClicked {
HitMusicAppDelegate*
	appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate setSecondaryView:voteNowView];
	if (!popUpNeedleView) {
		popUpNeedleView = [[PopupView alloc] initWithNibName:@"PopupView" bundle:nil];
	}
	
	[appDelegate.window addSubview: popUpNeedleView.view];
	[popUpNeedleView moveNeedle:1];
	[popUpNeedleView performSelector:@selector(removeView) withObject: nil afterDelay: 3.0];
	//[popUpNeedleView performSelector:@selector(removeFromSuperview) withObject: popUpNeedleView afterDelay: 3.0];
	//[self moveNeedle:1];	
	//[appDelegate sendXMLRequest:1];
}

// Bin it button pressed.
- (IBAction)binItClicked {
	
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!popUpNeedleView) {
		popUpNeedleView = [[PopupView alloc] initWithNibName:@"PopupView" bundle:nil];
	}
	[appDelegate.window addSubview: popUpNeedleView.view];
	[popUpNeedleView moveNeedle:-1];
	[popUpNeedleView performSelector:@selector(removeView) withObject: nil afterDelay: 3.0];
	
	//[appDelegate sendXMLRequest:-1];
	//[appDelegate playNextSong];	
}

// Play audio invocation from user. This button also stops audio if it is already playing
- (IBAction)playClicked {
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playSong];
}

// Custom function that displays pop ups 
- (void)DisplayAlert: (NSString*)msg {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Button clicked" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"OK",nil];
	[alert show];
	[alert autorelease];
}

- (void) dealloc {
	[super dealloc];
}

-(IBAction)doneButtonOnKeyboardPressed: (id)sender {
	
}


- (IBAction) backgroundButtonClicked: (id)sender {
	[sender resignFirstResponder];
}


- (void) displayNewsView {
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!newsPopupView) {
		newsPopupView = [[InTheNewsPopup alloc] initWithNibName:@"InTheNewsPopup" bundle:nil];
	}
	[appDelegate.window addSubview: newsPopupView.view];
	[newsPopupView performSelector:@selector(removeView) withObject: nil afterDelay: 5.0];
}

- (void) askForVote {
	HitMusicAppDelegate* appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!popUpNeedleView) {
		popUpNeedleView = [[PopupView alloc] initWithNibName:@"PopupView" bundle:nil];
	}
	[appDelegate.window addSubview: popUpNeedleView.view];
	//[popUpNeedleView moveNeedle:-1];
	[popUpNeedleView performSelector:@selector(removeView) withObject: nil afterDelay: 5.0];
	
}


- (CAAnimationGroup *)_flipAnimationWithDuration:(CGFloat)duration isFront:(BOOL)isFront;
{
	/*
    // Rotating halfway (pi radians) around the Y axis gives the appearance of flipping
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	
    // The hidden view rotates from negative to make it look like it's in the back
	#define LEFT_TO_RIGHT (isFront ? -M_PI : M_PI)
	#define RIGHT_TO_LEFT (isFront ? M_PI : -M_PI)
    flipAnimation.toValue = [NSNumber numberWithDouble:[flipView isHidden] ? LEFT_TO_RIGHT : RIGHT_TO_LEFT];
    
    // Shrinking the view makes it seem to move away from us, for a more natural effect
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	
    shrinkAnimation.toValue = [NSNumber numberWithDouble: 1.0];
	
    // We only have to animate the shrink in one direction, then use autoreverse to "grow"
    shrinkAnimation.duration = duration / 2.0;
    shrinkAnimation.autoreverses = YES;
    
    // Combine the flipping and shrinking into one smooth animation*/
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	/*
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, shrinkAnimation, nil];
	
    // As the edge gets closer to us, it appears to move faster. Simulate this in 2D with an easing function
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
    // Set ourselves as the delegate so we can clean up when the animation is finished
    animationGroup.delegate = self;
    animationGroup.duration = duration;
	
    // Hold the view in the state reached by the animation until we can fix it, or else we get an annoying flicker
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
	*/
    return animationGroup;
}


- (IBAction) showFlipView : (id) sender {
	
    // Hold the shift key to flip the window in slo-mo. It's really cool!
    CGFloat flipDuration = ANIMATION_DURATION_IN_SECONDS * (1.0);
	
    // The hidden layer is "in the back" and will be rotating forward. The visible layer is "in the front" and will be rotating backward
   // CALayer *hiddenLayer = [imgMain.isHidden ? imgMain : flipView layer];
   CALayer *visibleLayer = [imgMain.isHidden ? flipView : imgMain layer];

	
	[self performSelector:@selector(_swapViews) withObject:nil afterDelay:flipDuration / 2.0];
	CATransition * animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setDuration:flipDuration];
	[visibleLayer addAnimation:animation forKey:@"animation s"];
    // Before we can "rotate" the window, we need to make the hidden view look like it's facing backward by rotating it pi radians (180 degrees). We make this its own transaction and supress animation, because this is already the assumed state
   // [CATransaction begin]; {
     //   [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
        
		//[hiddenLayer setValue:[NSNumber numberWithDouble:M_PI] forKeyPath:@"transform.rotation.y"];

   // } [CATransaction commit];
    
    // There's no way to know when we are halfway through the animation, so we have to use a timer. On a sufficiently fast machine (like a Mac) this is close enough. On something like an iPhone, this can cause minor drawing glitches
    
    /*
     [CATransaction begin]; {
        [hiddenLayer addAnimation:[self _flipAnimationWithDuration:flipDuration isFront:NO] forKey:@"flipGroup"];
        [visibleLayer addAnimation:[self _flipAnimationWithDuration:flipDuration isFront:YES] forKey:@"flipGroup"];
    } [CATransaction commit];
	 */
}

- (void)_swapViews;
{
    // At the point the window flips, change which view is visible, thus bringing it "to the front"
    [imgMain setHidden:![imgMain isHidden]];
    [flipView setHidden:![imgMain isHidden]];
}@end




