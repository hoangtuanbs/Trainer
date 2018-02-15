
#import "XMLReader.h"
#import "MediaItem.h"
#import "ClockItem.h"
#import "PopUp.h"
#import "HitMusicAppDelegate.h"

static NSUInteger parsedItemsCounter;

@implementation XMLReader

//@synthesize currentEarthquakeObject = _currentEarthquakeObject;
@synthesize contentOfCurrentItemProperty = _contentOfCurrentItemProperty;
@synthesize nameOfCurrentItemProperty	 = _nameOfCurrentItemProperty;
@synthesize parsingObjectName;
@synthesize linkToObjectArray;
@synthesize mediaItem;
@synthesize clockItem;
@synthesize database;
@synthesize	popUpItem;

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    parsedItemsCounter = 0;
}

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error objectName:(NSString  *)objectName withObjectArray:(NSMutableArray *)objectArray withDatabase:(sqlite3 *)db;

{	
	//NSLog(@"Inside parser creation url = %@", URL);
    NSXMLParser *parser= [[NSXMLParser alloc] initWithContentsOfURL:URL];
    self.parsingObjectName = objectName;
	self.linkToObjectArray = objectArray;
	self.database		   = db;
	
	//NSLog(@"Creating new parser");

	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
  //  NSLog(@"going to parser");
	[parser parse];
    NSError *parseError = [parser parserError];
	self.linkToObjectArray = [NSMutableArray array];

    if (parseError && error) {
        *error = parseError;
    }
    
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }
	//	NSLog(@"Started element");
	if ([elementName isEqualToString:self.parsingObjectName]) {
		if ([self.parsingObjectName isEqualToString:@"media_item"]) {
			mediaItem = [MediaItem alloc];
		} else if([self.parsingObjectName isEqualToString:@"clock_item"]) {
			clockItem = [ClockItem alloc];
		}  else if([self.parsingObjectName isEqualToString:@"pop_up_item"]) {
			popUpItem = [PopUp alloc];
		}
	}
	self.contentOfCurrentItemProperty = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{   
	//HitMusicAppDelegate *appDelegate = (HitMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
	//	NSLog(@"Ended Element");
	int foundObjectAtIndex = -1;
    if (qName) {
        elementName = qName;
    }
	
	if (![elementName isEqualToString:self.parsingObjectName]) {
		if ([elementName isEqualToString:@"id"]) {
				elementName = @"primaryKey";
		} 
		if (![elementName isEqualToString:@"root"]) {
			if ([self.parsingObjectName isEqualToString:@"media_item"]) {
				[mediaItem setValue:self.contentOfCurrentItemProperty forKey:elementName];
			} else if([self.parsingObjectName isEqualToString:@"clock_item"]) {
				[clockItem setValue:self.contentOfCurrentItemProperty forKey:elementName];
			}  else if([self.parsingObjectName isEqualToString:@"pop_up_item"]) {
				[popUpItem setValue:self.contentOfCurrentItemProperty forKey:elementName];
			}			
		}
	}
	
	// all properties of the object gathered, now we decide to add the object or not depending on if it is already here.
	if ([elementName isEqualToString:self.parsingObjectName]) {
		// check to see if we already have this object in the given array, if so, update values, if not insert.
		if ([self.parsingObjectName isEqualToString:@"media_item"]) {
			foundObjectAtIndex =  [self searchForObjectInArrayWithId:[self.mediaItem primaryKey]];
		} else if([self.parsingObjectName isEqualToString:@"clock_item"]) {
			foundObjectAtIndex =  [self searchForClockInArrayWithNo:[self.clockItem no]  withListCategoryId:[self.clockItem list_category_id]];
		}  else if([self.parsingObjectName isEqualToString:@"pop_up_item"]) {
			foundObjectAtIndex =  [self searchForObjectInArrayWithId:[self.popUpItem primaryKey]];
		}
		
		// ********** new item, insert it to database
		if (foundObjectAtIndex == -1) { 
			//NSLog(@"object was not found, creating it and adding it to DB");
			if ([self.parsingObjectName isEqualToString:@"media_item"]) {
				[self.mediaItem setIsActiveItem:TRUE];
				[self.mediaItem setImage_downloaded:FALSE];
				[self.mediaItem setAudio_downloaded:FALSE];
				//[self.mediaItem setPop_up_downloaded:FALSE];
				[self.linkToObjectArray addObject:self.mediaItem];
				[self.mediaItem insertIntoDatabase:self.database];
			} else if([self.parsingObjectName isEqualToString:@"clock_item"]) {
				[self.clockItem setIsActiveItem:TRUE];
				[self.linkToObjectArray addObject:self.clockItem];
				[self.clockItem insertIntoDatabase:self.database];
			} else if([self.parsingObjectName isEqualToString:@"pop_up_item"]) {
				[self.popUpItem setIsActiveItem:TRUE];
				[self.popUpItem setDownloaded:FALSE];
				[self.linkToObjectArray addObject:self.popUpItem];
				[self.popUpItem insertIntoDatabase:self.database];
			}		
		} else { // **********  Existing item, change atributes
			if ([self.parsingObjectName isEqualToString:@"media_item"]) {
				[[self.linkToObjectArray objectAtIndex:foundObjectAtIndex] setIsActiveItem:TRUE];
			} else if([self.parsingObjectName isEqualToString:@"clock_item"]) {
				//[self.clockItem setIsActiveItem:TRUE];
				[[self.linkToObjectArray objectAtIndex:foundObjectAtIndex] setIsActiveItem:TRUE];
				[self.clockItem updateClockItem:self.database];
			} else if([self.parsingObjectName isEqualToString:@"pop_up_item"]) {
				//[self.popUpItem setIsActiveItem:TRUE];
				[[self.linkToObjectArray objectAtIndex:foundObjectAtIndex] setIsActiveItem:TRUE];
				//[self.popUpItem updatePopUpItem:self.database];
			  }		
			}
		
		if ([self.parsingObjectName isEqualToString:@"media_item"]) {
			[mediaItem release];
		} else if([self.parsingObjectName isEqualToString:@"clock_item"]) {
			[clockItem release];
		}  else if([self.parsingObjectName isEqualToString:@"pop_up_item"]) {
			[popUpItem release];
		}
	}
}

// search an object array for specific object with id = ?
- (int)searchForObjectInArrayWithId:(int)pk {
	int foundAtIndex = -1;
	//NSLog(@"Inside the search Method, pk = %i and array count = %i",pk, [self.linkToObjectArray count]);
	if ([self.linkToObjectArray count] != 0) {
		for (int t = 0; t < [self.linkToObjectArray count]; ++t) {
			if ([[self.linkToObjectArray objectAtIndex:t] primaryKey] == pk) {
				foundAtIndex = t;
				break;
			}
		}
	}
	return foundAtIndex;
}

// search for specific object in clockItem array
- (int)searchForClockInArrayWithNo:(NSInteger)clockNo withListCategoryId:(NSInteger)listCategoryId {
	int foundAtIndex = -1;
	//NSLog(@"Inside the search Method, pk = %i and array count = %i",pk, [self.linkToObjectArray count]);
	if ([self.linkToObjectArray count] != 0) {
		for (int t = 0; t < [self.linkToObjectArray count]; ++t) {
			if ([[self.linkToObjectArray objectAtIndex:t] list_category_id] == listCategoryId && 
					[[self.linkToObjectArray objectAtIndex:t] no] == clockNo) {
				//NSLog(@"This clock item is already in");
				foundAtIndex = t;
				break;
			}
		}
	}
	return foundAtIndex;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.contentOfCurrentItemProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.contentOfCurrentItemProperty appendString:string];
    }
}

@end




