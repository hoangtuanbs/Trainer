#import "XMLParser.h"
 	


@implementation XMLParser
@synthesize  parseLock;
static XMLParser *sharedInstance = nil;

// Use just one parser instance at any time
+(XMLParser *) sharedInstance{
 	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
 	}
 	return sharedInstance;
}
 	
// Public parser returns the tree root. You may have to go down on

- (TreeNode *)parseXMLFromURL: (NSURL *) url
{
	[parseLock lock];
	//NSLog(@"****** parser started");
	 	stack = [NSMutableArray array];
		root = [TreeNode treeNode];
	 	root.parent = nil;
	 	root.leafvalue = nil;
	 	root.children = [NSMutableArray array];
	 	
	 	[stack addObject:root];
	 	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	[pool drain];
	[pool release];

	// pop down to real root
	 	
	TreeNode *realroot = [[root children] lastObject];
	root.children = nil;
	root.parent = nil;
	root.leafvalue = nil;
	root.key = nil;
		
	realroot.parent = nil;
	[parseLock unlock];
	return realroot;
}

// parser finished
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//NSLog(@"***** parser ended");
}

// Descend to a new element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDictionary {
	if (qName) elementName = qName;
	
	TreeNode *leaf = [TreeNode treeNode];
 	leaf.parent = [stack lastObject];
 	[(NSMutableArray *)[[stack lastObject] children] addObject:leaf];
 	
 	leaf.key = [NSString stringWithString:elementName];
	leaf.leafvalue = nil;
	leaf.children = [NSMutableArray array];
	[stack addObject:leaf];
	
	if ([attributeDictionary count] > 0) {
		leaf.attributeDict = [attributeDictionary copy];
	} else {
		leaf.attributeDict = NULL;
	}	
}
 	
// Pop after finishing element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	[stack removeLastObject];
}
 	
// Reached a leaf
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![[stack lastObject] leafvalue]){
		[[stack lastObject] setLeafvalue:[NSString stringWithString:string]];
		return;
 	}
	[[stack lastObject] setLeafvalue:[NSString stringWithFormat:@"%@%@", [[stack lastObject] leafvalue], string]];
}
 	
@end