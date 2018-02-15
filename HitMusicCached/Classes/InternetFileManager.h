//
//  InternetFileManager.h
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/14/08.
//  Copyright 2008 Wavem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"

@interface InternetFileManager : NSObject {
	
	NSString		*defaultPath;
	NSString		*urlAddress;
	NSFileManager	*fileManager;
	NSString		*downloadFileName;
	NSString		*downloadFileNewName;
	NSMutableData	*receivedData;
	NSURLRequest	*theRequest;
	NSURLConnection *theConnection;
	int				downloadQueueNumber;
	NSMutableArray	*downloadQueue;
	NSMutableArray	*readyQueue;
	int				fileManagerState; // 0 = doing nothing 1 = downloading
	MediaItem		*mediaItem;
}

@property(nonatomic, retain) NSString		 *defaultPath;
@property(nonatomic, retain) NSString	     *urlAddress;
@property(nonatomic, retain) NSMutableArray	 *downloadQueue;
@property(nonatomic, retain) NSMutableArray	 *readyQueue;
@property(nonatomic, retain) NSFileManager	 *fileManager;
@property(nonatomic, retain) NSString		 *downloadFileName;
@property(nonatomic, retain) NSString		 *downloadFileNewName;
@property(nonatomic, retain) NSMutableData	 *receivedData;
@property(nonatomic, retain) NSURLRequest	 *theRequest;
@property(nonatomic, retain) NSURLConnection *theConnection;
@property(nonatomic	)		 int			 downloadQueueNumber;
@property(nonatomic	)		 int			 fileManagerState;
@property(nonatomic,retain)  MediaItem		*mediaItem;

- (id)			initWithPath:(NSString*)dPath								withUrl:(NSString*)url;
- (void)		downLoadFiles;
- (BOOL)		deleteFile:(NSString*)fileName;
- (BOOL)		doesFileExists:(NSString*)fileName;
- (void)		connection:(NSURLConnection *)connection					didReceiveResponse:(NSURLResponse *)response;
- (void)		connection:(NSURLConnection *)connection					didReceiveData:(NSData *)data;
- (void)		connection:(NSURLConnection *)connection					didFailWithError:(NSError *)error;
- (void)		connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)		downloadNextFileIfAny;
- (void)		addToQueue:(MediaItem*)newMediaItem;
- (void)		addSingleFile:(NSString*)fileToDownload;
- (void)		startDownload;
- (NSString*)	getReadyItem;
- (BOOL)		isFileAlreadyInQueue:(NSString*)searchFile;
@end
