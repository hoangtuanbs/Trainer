//
//  InternetFileManager.m
//  HitMusic
//
//  Created by Joshwa Marcalle on 10/14/08.
//  Copyright 2008 Wavem. All rights reserved.
//


#import "InternetFileManager.h"
#import "HitMusicAppDelegate.h"

@implementation InternetFileManager

@synthesize defaultPath, urlAddress;
@synthesize fileManager, downloadFileName, downloadFileNewName;
@synthesize downloadQueue,receivedData, theRequest, theConnection;
@synthesize downloadQueueNumber;
@synthesize readyQueue;
@synthesize fileManagerState, mediaItem;


- (id)initWithPath: (NSString*)dPath withUrl:(NSString *)url {
	self = [super init];
	
	if (self != nil) {
		self.defaultPath = [dPath stringByAppendingString:@"/"];
		
		self.urlAddress  = url;
		NSFileManager *fm = [NSFileManager alloc];
		self.fileManager = fm;
		[fm release];
	}
	
	downloadQueueNumber = 0;
	fileManagerState	= 0;
	
	NSMutableArray *downloadQueueArray		= [[NSMutableArray alloc] init];
	NSMutableArray *readyQueueArray			= [[NSMutableArray alloc] init];

    self.downloadQueue					= downloadQueueArray;
	self.readyQueue						= readyQueueArray;

    [downloadQueueArray release];
	[readyQueueArray release];

	return self;
}

- (void) startDownload {
	NSLog(@"******* download queue ***********");
	for (int t=0; t < [downloadQueue count]; t++){
		NSLog(@"%i object= %@",t,[downloadQueue objectAtIndex:t]);
		//NSLog(@"The popUpHandle for this media item is %@",[[appDelegate.mediaItems objectAtIndex:t] popUpHandle] );
	}
	NSLog(@"******* download wueue ***********");
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//[NSThread detachNewThreadSelector:@selector(downLoadFiles) toTarget:self withObject:self];
	[self downLoadFiles];
	//[pool release];
}

// This method startes the dowloadinf process, one file at a time.
- (void)downLoadFiles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(downloadQueueNumber == 0) {
		NSLog(@"The total items in the download queue is %i and the items are:",[downloadQueue count]);
		for (int t=0; t < [downloadQueue count]; t++){
			NSLog(@"%i object= %@",t,[downloadQueue objectAtIndex:t]);
		}
	}
	
	//NSLog(@"Started to download");
	//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"The downloadFiles method has been called");
	if ([downloadQueue count] <  1) {
		NSLog(@"The downloadQueue has no items");
		return;
	}
	
	//NSLog(@"The downloadQueue is %i", [self.downloadQueue count]);
	fileManagerState = 1;
	//NSLog(@"There are %i files to download", [self.downloadQueue count]);
	NSString *mediaName;
	
	mediaName = [downloadQueue objectAtIndex:downloadQueueNumber];
	self.downloadFileNewName = [defaultPath stringByAppendingString:[downloadQueue objectAtIndex:downloadQueueNumber]];
//	NSLog(@"******* The new name of the downloadfile is %@",self.downloadFileNewName);
	//NSLog(@"Downloading file %@ on queue no %i",self.downloadFileNewName,self.downloadQueueNumber);
	downloadQueueNumber++;
	//NSLog(@"url is %@",[self.urlAddress stringByAppendingString:mediaName]);
    NSURL *url		= [[NSURL alloc] initWithString:[self.urlAddress stringByAppendingString:mediaName]];
    receivedData	= [[NSMutableData data] retain];
	theRequest		= [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	theConnection	= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		self.downloadFileNewName = [self.defaultPath stringByAppendingString:mediaName];
		//NSLog(@"Conection was made");
		

	} else {
		NSLog(@"The connection could not be made");
	}
	// TODO this line has to be uncommmented so that we can have tru multithreading when app is downloading songs
	[[NSRunLoop currentRunLoop ] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
	[pool release];
}

//This is the method that searches the media queue for files to download. If it reaches the end of the queue and there are no more to download then the download operation finally stops.
- (void) downloadNextFileIfAny{
	//NSLog(@"downloadqueuenumner is %i and downloadQueue count is %i",downloadQueueNumber, [downloadQueue count]);
	if (downloadQueueNumber < [downloadQueue count]) {
		[self downLoadFiles];
	} else {
		fileManagerState == 0;
		NSLog(@"Download ended succesfully and the ready queue has %d items", [readyQueue count]);
		//HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
//		NSLog(@"************ mediaItems array elements %i *************", [appDelegate.mediaItems count]);
//		for (int d = 0; d < [appDelegate.mediaItems count]; d++) {
//			NSLog(@"%i) mediaItem E= %@,I= %@ AD= %i, ID=%i",d,
//				  [[appDelegate.mediaItems objectAtIndex:d] handle],
//				  [[appDelegate.mediaItems objectAtIndex:d] image_handle],
//				  [[appDelegate.mediaItems objectAtIndex:d] audio_downloaded],
//				  [[appDelegate.mediaItems objectAtIndex:d] image_downloaded]);
//		}
//		NSLog(@"************ END OF media items array elements *************");

		
	//	NSLog(@"The ready queue now has %i items",[readyQueue count]);
	}
}

- (NSString*)	getReadyItem {
	//NSLog(@"Inside getReadyQuue and the number of items is %i", [readyQueue count]);
	int theIndex = ([readyQueue count] -1);
	NSString* returnMedia;
	//NSLog(@"theIndex = %i",theIndex);
	
	if ([readyQueue count] > 0) {
		returnMedia = (NSString*)[readyQueue objectAtIndex:theIndex];
	//	NSLog(@"returnMedia = %@", returnMedia);
		[readyQueue removeObjectAtIndex:theIndex];
		
	} else {
		returnMedia = @"";
	}
	return returnMedia;
}

- (void) addToQueue:(MediaItem*)newMediaItem {
	mediaItem = newMediaItem;
	//[self.downloadQueue addObject:[newMediaItem handle]];
	
	if ([newMediaItem audio_downloaded] == FALSE && [self isFileAlreadyInQueue:[newMediaItem handle]] == FALSE) {
		[self.downloadQueue addObject:[newMediaItem handle]];
		//NSLog(@"******* added new media item to downloadQueue %@ and new total is %i", [newMediaItem handle], [self.downloadQueue count]);
	}
	if ([newMediaItem image_downloaded] == FALSE && [self isFileAlreadyInQueue:[newMediaItem image_handle]] == FALSE) {
		[self.downloadQueue addObject:[newMediaItem image_handle]];
		//NSLog(@"******* added new image item to downloadQueue %@", [newMediaItem image_handle]);
	}
}

- (void) addSingleFile:(NSString*)fileToDownload {
	if ([self isFileAlreadyInQueue:fileToDownload]) {
		return;
	}
	[self.downloadQueue addObject:fileToDownload];
}

- (BOOL) isFileAlreadyInQueue:(NSString*)searchFile {
	//BOOL fileFound = FALSE;
	for (int t = 0; t < [downloadQueue count] ; t++) {
		if ([[downloadQueue objectAtIndex:t] isEqualToString:searchFile]) {
				NSLog(@"************ internetFileManager: found repeated downloadueue item");
			return TRUE;
		
		}
	}
	
	return FALSE;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
  //  NSLog(@"I have enought information to create a NSURLResponse.");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//NSLog(@"conection didreceve data.");
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	 // inform the user
	NSLog(@"*******************************************");
	NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription]);//	[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	NSLog(@"*******************************************");
	// release the connection, and the data object
	[connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	[self downLoadFiles];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	//NSLog(@"download successful, file saved. %@", self.downloadFileNewName);
	HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];

	int startFrom	= [self.downloadFileNewName rangeOfString:@"/" options:NSBackwardsSearch].location + 1;
	int endIn		= [self.downloadFileNewName	length] - startFrom;
	NSString *mediaName = [self.downloadFileNewName substringWithRange:NSMakeRange(startFrom, endIn)];
	
	[appDelegate performSelectorOnMainThread:@selector(markReadyDownload:) withObject:mediaName waitUntilDone:NO];
	//NSLog(@"InternetFileManager: Calling markReadyDownload for file : %@",mediaName);
	//[appDelegate markReadyDownload:[self.downloadFileNewName substringWithRange:NSMakeRange(startFrom, endIn)]];
	[receivedData writeToFile:self.downloadFileNewName atomically:YES];	
    [theConnection release];
    [receivedData release];

	//if (downloadQueueNumber == [downloadQueue count]){ 
//		return;
//	}
	//NSLog(@"About to add to readyqueue, the downloadQueueNumber is %i and the total on the downloadQueue is %i", downloadQueueNumber, [downloadQueue count]);
	//[self.readyQueue addObject:[downloadQueue objectAtIndex:downloadQueueNumber]];
	[self downloadNextFileIfAny];
}

- (BOOL)deleteFile:(NSString*)fileName {
	BOOL result = TRUE;
	NSFileManager *defaultManager;
	NSString *pathAndFile = [defaultPath stringByAppendingString:fileName];
	NSLog(pathAndFile);
	defaultManager = [NSFileManager defaultManager];
	[defaultManager removeItemAtPath:pathAndFile error:nil];
	[defaultManager release];
	return result;
}

- (BOOL) doesFileExists:(NSString*)fileName {
	BOOL result = FALSE;
	
	if ([fileManager fileExistsAtPath:fileName] == TRUE) {
		result = TRUE;
	}
	return FALSE;
}

@end
