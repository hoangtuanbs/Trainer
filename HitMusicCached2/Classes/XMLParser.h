
#import <CoreFoundation/CoreFoundation.h>
#import "TreeNode.h"

@interface XMLParser : NSObject
{
	NSMutableArray		*stack;
	TreeNode			*root;
	NSLock				*parseLock;
}

@property(nonatomic, retain) 	NSLock				*parseLock;

+ (XMLParser *) sharedInstance;
- (TreeNode *)parseXMLFromURL: (NSURL *) url;

@end