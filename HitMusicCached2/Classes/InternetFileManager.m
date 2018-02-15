//
//  InternetFileManager.m
//  
//
//  Created by Joshwa Marcalle on 10/14/08.
//  Copyright 2008 Wavem. All rights reserved.
//

#import "InternetFileManager.h"
#import "DownloadObject.h"
#import "HitMusicAppDelegate.h"

@implementation InternetFileManager

@synthesize defaultPath;
@synthesize fileManager,  downloadFileNewName;
@synthesize downloadQueue,receivedData, theRequest, theConnection;
@synthesize downloadQueueNumber;
@synthesize fileManagerState;

- (id)init { 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.defaultPath = documentsDirectory;
	//NSLog(@"*/*/*/**/*/ The default path is %@",defaultPath);
	return self;
}

// This method startes the dowloadinf process, one file at a time.
- (void)downLoadFiles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([downloadQueue count] <  0) {
		NSLog(@"The downloadQueue has no items");
		return;
	}
	
//	NSLog(@"Download list");
//	for (int t = 0 ; t < [downloadQueue count] ; t++) {
//		NSLog(@" file %i, url = %@", t,[[downloadQueue objectAtIndex:t] urlAddress]);
//				
//	}

	//return;
	
	//NSLog(@"Started download of files on the manager");
	//NSLog(@"The downloadQueue is %i", [self.downloadQueue count]);
	fileManagerState = 1;
	//NSLog(@"There are %i files to download", [self.downloadQueue count]);
	NSString *mediaName;
	
	mediaName = [[downloadQueue objectAtIndex:(downloadQueueNumber)] urlAddress];
//	NSLog(@"Started to download and mediaName = %@", mediaName);
//	self.downloadFileNewName = [defaultPath stringByAppendingString:[[downloadQueue objectAtIndex:downloadQueueNumber] newName]];
	self.downloadFileNewName = [NSString stringWithFormat:@"%@/%@",defaultPath, [[downloadQueue objectAtIndex:downloadQueueNumber] newName]];
//	NSLog(@"The newFileName to download is %@",self.downloadFileNewName);
	
	//NSLog(@"Downloading file %@ on queue no %i",self.downloadFileNewName,self.downloadQueueNumber);
	
	downloadQueueNumber++;
	//NSLog(@"url is %@",mediaName);
	if (mediaName == nil) return;
    NSURL *url		= [[NSURL alloc] initWithString:mediaName];
    receivedData	= [[NSMutableData data] retain];
	theRequest		= [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	theConnection	= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
	//	self.downloadFileNewName = [self.defaultPath stringByAppendingString:mediaName];
		self.downloadFileNewName = [NSString stringWithFormat:@"%@/%@",defaultPath, [[downloadQueue objectAtIndex:(downloadQueueNumber -1)] newName]];
		//NSLog(@"Conection was made");
	} else {
		NSLog(@"The connection could not be made");
	}
	NSLog(@"The routine finished");

	[[NSRunLoop currentRunLoop ] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
	[pool release];
}

//This is the method that searches the media queue for files to download. If it reaches the end of the queue and there are no more to download then the download operation finally stops.
- (void) downloadNextFileIfAny{
	NSLog(@"downloadqueuenumner is %i and downloadQueue count is %i",downloadQueueNumber, [downloadQueue count]);
	if ( downloadQueueNumber  < [downloadQueue count] ) {
		NSLog(@"Calling next download");
		[self downLoadFiles];
	} else {
		fileManagerState == 0;
		NSLog(@"Download ended succesfully ");
	}
}

- (void) addFileToQueue:(NSString*)urlAddress withNewName:(NSString*)newName fromOwner:(NSString*)ownerName withOwnerId:(NSInteger)ownerId withOwnerIndex:(NSInteger)pOwnerIndex withType:(NSString*)type {
	//NSLog(@"Added new file to download queue and the name is %@ from owner %@",newName, ownerName);
	DownloadObject * newDownload = [[DownloadObject alloc] initWithUrl:urlAddress withame:newName fromOwner:ownerName withOwnerId:ownerId withOwnerIndex:pOwnerIndex withType:type];
	
	if (downloadQueue == nil) {
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		self.downloadQueue = tempArray;
		[tempArray release];
	}	
	//NSLog(@"*/*/*/**/*/ adding new file to queue (%@)",urlAddress);
	[self.downloadQueue addObject:newDownload];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSLog(@"Connection didReceiveResponse");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//	NSLog(@"Received data");
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	 // inform the user
	NSLog(@"*******************************************");
	NSLog(@"Connection failed! Error - %@  for file %@",[error localizedDescription], [[downloadQueue objectAtIndex:(downloadQueueNumber - 1 )] urlAddress]);
	NSLog(@"*******************************************");
	// release the connection, and the data object
	[connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	[self downloadNextFileIfAny];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//	// TODO refactor
	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	[receivedData writeToFile:[NSString stringWithFormat:@"%@/%@",self.defaultPath,[[downloadQueue objectAtIndex:(downloadQueueNumber - 1)] newName]] atomically:YES];	
    //[[downloadQueue objectAtIndex:(downloadQueueNumber - 1)] setNewName:
//			[NSString stringWithFormat:@"%@/%@",self.defaultPath,[[downloadQueue objectAtIndex:(downloadQueueNumber - 1)] newName]]];
	[[downloadQueue objectAtIndex:(downloadQueueNumber - 1)] setNewName:[[downloadQueue objectAtIndex:(downloadQueueNumber - 1)] newName]];
	[appDelegate performSelectorOnMainThread:@selector(markReadyDownload:) withObject:[downloadQueue objectAtIndex:(downloadQueueNumber - 1)] waitUntilDone:NO];
	[theConnection release];
    [receivedData release];
	[self downloadNextFileIfAny];
}

- (BOOL) deleteFile:(NSString*)fileName {
	BOOL result = TRUE;
	NSFileManager *defaultManager;
	NSString *pathAndFile = [defaultPath stringByAppendingString:fileName];
	NSLog(pathAndFile);
	defaultManager = [NSFileManager defaultManager];
	[defaultManager removeItemAtPath:pathAndFile error:nil];
	[defaultManager release];
	return result;
}

@end
