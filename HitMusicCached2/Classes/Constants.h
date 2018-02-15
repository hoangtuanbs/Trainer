
//CONSTANTS
#define kPreloadedSongs					70			// Number of songs to preload to list
#define kRefreshPlayList				0.0017		// approaximatly 10 minutes between playlist checkups
#define	kSecondsToAllowForwardClick		0.10		
#define kVotingAddress					"http://orange.wavem.com/RadioAdminPHP/submit_song_vote.php"
#define kPopUpRate						45			// %
#define ksecondsBeforePopUpDisplay		0.10		// 1 / 0.10 = 10 seconds
#define ksecondsDisplayingPopUp			0.05		// 
#define kCheckSystemStatus				0.20		//
#define ksecondsToChangeSecondaryView	0.10		// 20 seconds

enum {
	playerInitializing = 0,
	playerActive,
	playerInactive
};

enum {
	inTheNewsView = 0,
	voteNowView,
	pollView,
	chatView,
	introView
};

struct DownloadFileInfo {
	int itemId ;
	NSString * handle;
};

//	struct { char padding0[64]; volatile bool flag; char padding1[64]; } terminated;