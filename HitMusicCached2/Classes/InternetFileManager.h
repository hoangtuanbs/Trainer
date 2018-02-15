//
//  InternetFileManager.h
//
//  Created by Joshwa Marcalle on 10/14/08.
//  Copyright 2008 Futurice. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownloadObject;

@interface InternetFileManager : NSObject {
	NSString		*defaultPath;
	NSFileManager	*fileManager;
	//NSString		*downloadFileName;
	NSString		*downloadFileNewName;
	NSMutableData	*receivedData;
	NSURLRequest	*theRequest;
	NSURLConnection *theConnection;
	int				downloadQueueNumber;
	NSMutableArray	*downloadQueue;
	int				fileManagerState; // 0 = doing nothing 1 = downloading
}

@property(nonatomic, retain) NSString		 *defaultPath;
@property(nonatomic, retain) NSMutableArray	 *downloadQueue;
@property(nonatomic, retain) NSFileManager	 *fileManager;
//@property(nonatomic, retain) NSString		 *downloadFileName;
@property(nonatomic, retain) NSString		 *downloadFileNewName;
@property(nonatomic, retain) NSMutableData	 *receivedData;
@property(nonatomic, retain) NSURLRequest	 *theRequest;
@property(nonatomic, retain) NSURLConnection *theConnection;
@property(nonatomic	)		 int			 downloadQueueNumber;
@property(nonatomic	)		 int			 fileManagerState;
	
- (id)			init;
- (void)		downLoadFiles;
- (BOOL)		deleteFile:(NSString*)fileName;
- (void)		connection:(NSURLConnection *)connection					didReceiveResponse:(NSURLResponse *)response;
- (void)		connection:(NSURLConnection *)connection					didReceiveData:(NSData *)data;
- (void)		connection:(NSURLConnection *)connection					didFailWithError:(NSError *)error;
- (void)		connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)		downloadNextFileIfAny;
- (void)		addFileToQueue:(NSString*)urlAddress withNewName:(NSString*)newName fromOwner:(NSString*)ownerName withOwnerId:(NSInteger)ownerId withOwnerIndex:(NSInteger)ownerIndex withType:(NSString*)type;

@end
