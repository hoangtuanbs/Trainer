

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class MediaItem, ClockItem, PopUp;

@interface XMLReader : NSObject {

@private        
    //Earthquake *_currentEarthquakeObject;
    NSMutableString *_contentOfCurrentItemProperty;
	NSMutableString *_nameOfCurrentItemProperty;
	NSString		*parsingObjectName;
	NSMutableArray  *linkToObjectArray;
	MediaItem		*mediaItem;
	ClockItem		*clockItem;
	PopUp			*popUpItem;
	sqlite3			*database;
}

//@property (nonatomic, retain) Earthquake *currentEarthquakeObject;
@property (nonatomic, retain) NSMutableString	*contentOfCurrentItemProperty;
@property (nonatomic, retain) NSMutableString	*nameOfCurrentItemProperty;
@property (nonatomic, retain) NSString			*parsingObjectName;
@property (nonatomic, retain) NSMutableArray	*linkToObjectArray;
@property (nonatomic, retain) MediaItem			*mediaItem;
@property (nonatomic, retain) ClockItem			*clockItem;
@property (nonatomic, retain) PopUp				*popUpItem;
@property (nonatomic)		  sqlite3			*database;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error objectName:(NSString  *)objectName withObjectArray:(NSMutableArray *)objectArray withDatabase:(sqlite3 *)db;
- (int)searchForObjectInArrayWithId:(int)pk;
- (int)searchForClockInArrayWithNo:(NSInteger)clockNo  withListCategoryId:(NSInteger)listCategoryId;
@end
