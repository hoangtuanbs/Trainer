#import <UIKit/UIKit.h>
#import "InternetFileManager.h"
#import "PopupView.h"
#import "InTheNewsPopup.h"
//#import "AudioQueueObject.h"
//#import "AudioPlayer.h"


#define audioPlayerPlayingState	0
#define audoPlayerPausedState	1
#define audioPlayerStoppedState	2

@class MediaItem;

@interface MainView : UIView {
	
	PopupView *popUpNeedleView;
	InTheNewsPopup *newsPopupView;

    IBOutlet UIImageView		*imgMain;

	// secondary view elements
	IBOutlet UILabel		*imgInTheNews;
	IBOutlet UIImageView		*imgYesMeter;
	IBOutlet UIImageView		*imgNoMeter;
	//IBOutlet UIImageView		*imgMeter;
	//IBOutlet UIImageView		*imgNeedle;
	
	IBOutlet UILabel			*lblYes;
	IBOutlet UILabel			*lblNo;
	IBOutlet UILabel			*lblVoteNow;
	
	IBOutlet UITextField		*txbEmail;
	IBOutlet UITextField		*txbLocation;
	IBOutlet UITextField		*txbGender;
	IBOutlet UITextField		*txbAge;
	
	IBOutlet UITextView			*lblBigTextView;
	
	IBOutlet UIButton			*btnYes;
	IBOutlet UIButton			*btnNo;
	IBOutlet UIButton			*btnRegister;
	
	//IBOutlet UIImageView		*imgPopUps;
    IBOutlet UIView				*infoInterface;
	//IBOutlet UIView				*newsFeedView;
	IBOutlet UIView				*downloadInterface;
	IBOutlet UIProgressView		*progressBar;
    IBOutlet UILabel			*lblSongName;
	IBOutlet UILabel			*lblArtistName;
    IBOutlet UIView				*radioInterface;
	IBOutlet UIView				*debugInterface;
	IBOutlet UIView				*lyricsInterface;
	IBOutlet UIView				*popUpMotherView;
	IBOutlet UIView				*registerView;
	IBOutlet UIView				*stationsView;   
	IBOutlet UIView				*photoView;
	IBOutlet UIView				*chatView;
	IBOutlet UIView				*volumeBackGroundView;
	IBOutlet UITableView		*stationsTableView;
    IBOutlet UISlider			*sldVolume;
	IBOutlet UIButton	*playButton;
	IBOutlet UIButton	*forwardButton;
	IBOutlet UIButton	*hateItButton;
	
	IBOutlet UIBarButtonItem	*moreButton;
	IBOutlet UIBarButtonItem	*photosButton;
	IBOutlet UIBarButtonItem	*favoritesButton;
	IBOutlet UIBarButtonItem	*stationsButton;
	IBOutlet UIBarButtonItem	*backButton;
	IBOutlet UIButton	*chatButton;
	
	IBOutlet UISegmentedControl *soundQualityOptions;
	MediaItem					*mediaItem;
	IBOutlet UILabel			*lblLyricsTitle;
	IBOutlet UILabel			*lblLyricsArtist;
	// DEBUG
	IBOutlet UILabel			*lblQueuedSongs;
	IBOutlet UILabel			*lblDownloadedSongs;
	IBOutlet UITextView			*viewCurrentDownload;
	// END DEBUG
	IBOutlet UITextView			*viewLyrics;
	IBOutlet UIToolbar			*menuButtons;
	IBOutlet UIToolbar			*menuButtons2;
	IBOutlet UILabel			*songLabel;
	IBOutlet UILabel			*singerLabel;
	UIView * flipView;
}

@property (nonatomic, retain) UILabel *songLabel;
@property( nonatomic, retain) UILabel *singerLabel;
@property (nonatomic, retain)   IBOutlet UITextField		*txbEmail;
@property (nonatomic, retain)   IBOutlet UITextField		*txbLocation;
@property (nonatomic, retain)   IBOutlet UITextField		*txbGender;
@property (nonatomic, retain)   IBOutlet UITextField		*txbAge;

@property (nonatomic, retain)   IBOutlet UIView				*radioInterface;
@property (nonatomic, retain)   IBOutlet UIView				*stationsView;
@property (nonatomic, retain)	MediaItem					*mediaItem;
@property (nonatomic, retain)   IBOutlet UISlider			*sldVolume;
@property (nonatomic, retain)   IBOutlet UIProgressView		*progressBar;


// DEBUG
@property (nonatomic, retain)   IBOutlet UILabel			*lblQueuedSongs;
@property (nonatomic, retain)   IBOutlet UILabel			*lblDownloadedSongs;
@property (nonatomic, retain)   IBOutlet UITextView			*viewCurrentDownload;
// END DEBUG
// secondary view elelements
@property (nonatomic, retain)	IBOutlet UILabel		*imgInTheNews;
@property (nonatomic, retain)	IBOutlet UIImageView		*imgYesMeter;
@property (nonatomic, retain)	IBOutlet UIImageView		*imgNoMeter;
//@property (nonatomic, retain)	IBOutlet UIImageView		*imgMeter;
//@property (nonatomic, retain)	IBOutlet UIImageView		*imgNeedle;

@property (nonatomic, retain)	IBOutlet UILabel			*lblYes;
@property (nonatomic, retain)	IBOutlet UILabel			*lblNo;
@property (nonatomic, retain)	IBOutlet UILabel			*lblVoteNow;

@property (nonatomic, retain)	IBOutlet UITextView			*lblBigTextView;

@property (nonatomic, retain)	IBOutlet UIButton			*btnYes;
@property (nonatomic, retain)	IBOutlet UIButton			*btnNo;
@property (nonatomic, retain)	IBOutlet UIButton			*btnRegister;

@property (nonatomic, retain)   IBOutlet UILabel			*lblSongName;
@property (nonatomic, retain)   IBOutlet UILabel			*lblArtistName;
@property (nonatomic, retain)   IBOutlet UIImageView		*imgMain;

@property (nonatomic, retain)	IBOutlet UIButton	*playButton;
@property (nonatomic, retain)	IBOutlet UIButton	*forwardButton;
@property (nonatomic, retain)	IBOutlet UIButton	*hateItButton;

@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*moreButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*photosButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*favoritesButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*stationsButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*backButton;
@property (nonatomic, retain)	IBOutlet UIButton	*chatButton;
@property (nonatomic, retain)   IBOutlet UILabel			*lblLyricsTitle;
@property (nonatomic, retain)   IBOutlet UILabel			*lblLyricsArtist;
@property (nonatomic, retain)   IBOutlet UITextView			*viewLyrics;
@property (nonatomic, retain)	IBOutlet UIToolbar			*menuButtons;
@property (nonatomic, retain)	IBOutlet UIToolbar			*menuButtons2;
@property (nonatomic, retain)   IBOutlet UISegmentedControl *soundQualityOptions;
@property (nonatomic, retain) IBOutlet UIView *flipView;
// Methods and actions
- (IBAction)	backToRadioClicked;
- (IBAction)	binItClicked;
- (IBAction)	debugClicked;
- (IBAction)	exitClicked;
- (IBAction)	fowardClicked;
- (IBAction)	infoClicked;
- (IBAction)	loveItClicked;
- (IBAction)	playClicked;
- (IBAction)	volumnChanged;
- (IBAction)	lyricsClicked;
- (IBAction)	backToRadioFromLyrics;
- (void)		DisplayAlert: (NSString*)msg;
- (IBAction)	registerClicked;
- (IBAction)	doneButtonOnKeyboardPressed: (id)sender;
- (IBAction)	backgroundButtonClicked: (id) sender;

// secondary menu actions
- (IBAction)	moreClicked;
- (IBAction)	photosClicked;
- (IBAction)	favoritesClicked;
- (IBAction)	stationsClicked;
- (IBAction)	backToMenuClicked;
- (IBAction)	chatClicked;
- (IBAction)	surveyYesClicked;
//- (IBAction)	showVolume;
- (IBAction) showFlipView: (id) sender;
- (void) displayNewsView;
- (void) askForVote;
- (void) setProgress:(float)value;
@end
