#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "MainView.h"
#import "HitMusicAppDelegate.h"
#import "InternetFileManager.h"
#import "MediaItem.h"
#import "XMLReader.h"

@implementation MainView

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
@synthesize imgMeter;
@synthesize imgNeedle;

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
	CALayer *layer = [imgNeedle layer];
	layer.frame = CGRectMake(225.0, 85.0, 81.0, 32.0);
	
	
	
	[self addSubview:registerView];
	[sldVolume setMinimumValue:0];
	[sldVolume setMaximumValue:10];
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
	[self moveNeedle:3];
}

- (void) moveNeedle:(int)leftRight {	
	[lblBigTextView setText:@"Thank you for voting ! \n Your vote was sent"];
	[lblVoteNow setText:@""];
	int from = leftRight == 1 ? 1.5 : 2;
	int to	 = leftRight == 1 ? 2	: 1.5;
	CALayer *layer = [imgNeedle layer];
	layer.anchorPoint = CGPointMake(0.1, 0.62);
	layer.frame = CGRectMake(225.0, 85.0, 81.0, 32.0);
	
	CABasicAnimation *rotateAnimation = [CABasicAnimation animation];
	rotateAnimation.keyPath = @"transform.rotation.z";
	rotateAnimation.fromValue = [NSNumber numberWithFloat:from * M_PI];
	rotateAnimation.toValue = [NSNumber numberWithFloat:to * M_PI];
	rotateAnimation.duration = 2;
	rotateAnimation.removedOnCompletion = NO;
	// leaves presentation layer in final state; preventing snap-back to original state
	rotateAnimation.fillMode = kCAFillModeForwards;
	rotateAnimation.repeatCount = 1;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	// add the animation to the selection layer. This causes it to begin animating
	[layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
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
	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setGain:([self.sldVolume value])];
}

// foward to next song
- (IBAction)fowardClicked {

	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setSecondaryView:voteNowView];
	[self moveNeedle:1];	
	[appDelegate sendXMLRequest:1];
}

// Bin it button pressed.
- (IBAction)binItClicked {

	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate.changeSecondaryViewTimer invalidate];
	[appDelegate setSecondaryView:voteNowView];
	[self moveNeedle:-1];	

	[appDelegate sendXMLRequest:-1];
	[appDelegate playNextSong];	
}

// Play audio invocation from user. This button also stops audio if it is already playing
- (IBAction)playClicked {
	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playSong];
}

// Custom function that displays pop ups 
- (void)DisplayAlert: (NSString*)msg {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Button clicked" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"OK",nil];
	[alert show];
	[alert release];
}

- (void) dealloc {
	[super dealloc];
}

-(IBAction)doneButtonOnKeyboardPressed: (id)sender {
	
}

@end




