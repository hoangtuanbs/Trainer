
#import <CoreFoundation/CoreFoundation.h>

@interface TreeNode : NSObject
{
	TreeNode		*parent;
	NSMutableArray  *children;
	NSString		*key;
	NSString		*leafvalue;
	NSDictionary	*attributeDict;
}

@property (nonatomic, retain)   TreeNode		*parent;
@property (nonatomic, retain)   NSMutableArray  *children;
@property (nonatomic, retain)   NSString		*key;
@property (nonatomic, retain)   NSString		*leafvalue;
@property (nonatomic, retain)   NSDictionary	*attributeDict;

+ (TreeNode *) treeNode;

- (void) dump;

- (BOOL) isLeaf;
- (NSMutableArray *) keys;
- (TreeNode *)				objectForKey:			(NSString *)	aKey;
- (NSMutableArray *)		objectsForKey:			(NSString *)	aKey;
- (TreeNode *)				objectForKeys:			(NSArray *)		keys;
- (TreeNode *)				objectForKey:			(NSString *)	keys    withAttribute:  (NSString*) aAttribute withAttributeValue:(NSString*)attributeValue;
- (NSString *)				leafForKey:				(NSString *)	aKey;
- (NSString *)				myLeafValue;
- (NSString *)				attributeValueForKey:	(NSString *)	aKey	forAttribute:	(NSString*)	aAttribute;
- (NSMutableDictionary *)	dictionaryForChildren;
- (NSMutableArray *)		createArrayForKey:		(NSString*)		aKey	withObject:		(NSObject*)	object	withTranslationTable:(NSDictionary*)dict;
- (TreeNode*)				getChildAtIndex:		(NSInteger)		aIndex;

@end