
#import "TreeNode.h"

@implementation TreeNode
@synthesize parent;
@synthesize children;
@synthesize key;
@synthesize leafvalue;
@synthesize attributeDict;

// Initialize all nodes as branches
- (TreeNode *) init
{
	if (self = [super init]) leafvalue = nil;
	return self;
}

+ (TreeNode *) treeNode
{
	return [[[self alloc] init] autorelease];
}

// Determine whether the node is a leaf or a branch
- (BOOL) isLeaf
{
	return (leafvalue != nil);
}

// Return an array of all child keys
- (NSMutableArray *) keys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in children) [results addObject:[node key]];
	return results;
}

// Return the first child that matches the key
- (TreeNode *) objectForKey: (NSString *) aKey
{
	TreeNode *result = nil;
	for (TreeNode *node in children)
		if ([[node key] isEqualToString: aKey]) result = node;
	return result;
}

- (TreeNode*)				getChildAtIndex:			(NSInteger)		aIndex{
	TreeNode *result = nil;
	int index = 0;
	
	for (TreeNode *node in children) {
	
		if (index == aIndex) {
			result = node;
			break;
		}
		index++;
	}
	return result;
}

// This searches for key with a particular attribute equal to a particular value. If we need to search for more than one attribute then a dictionary can be passed. ( later)
- (TreeNode *)objectForKey:(NSString *)akey withAttribute:(NSString*)aAttribute withAttributeValue:(NSString*)attributeValue {
	TreeNode *result = nil;
	for (TreeNode *node in children) {
		if ([[node key] isEqualToString: akey] && [[node attributeValueForKey:akey forAttribute:aAttribute] isEqualToString:attributeValue]) {
			//NSLog(@"found the package and the name is %@", [node attributeValueForKey:akey forAttribute:@"subName"]);
			result = node;
		}			
	}
	return result;
}

// Return all children that match the key
- (NSMutableArray *) objectsForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in children)
		if ([[node key] isEqualToString: aKey]) [result addObject:node];
	return result;
}

// get the attribute value for a certain leaf with a certain attribute name
- (NSString *) attributeValueForKey:(NSString *)aKey forAttribute:(NSString*)aAttribute {
	NSString *result = nil;
	
	if ([[self key] isEqualToString:aKey] && [self.attributeDict objectForKey:aAttribute] != nil ) {
		//NSLog(@"Found the attribute");
		result = [self.attributeDict objectForKey:aAttribute];
	}
	
	for (TreeNode *node in children) {
		//NSLog(@"Started search with node.key = %@ and clientId = %@",[node key], [[node attributeDict] objectForKey:aAttribute]);
		if ([[node key] isEqualToString:aKey] && [node.attributeDict objectForKey:aAttribute] != nil ) {
			//NSLog(@"Found the attribute");
			result = [node.attributeDict objectForKey:aAttribute];
		}
	}
	if (result) {
		return result;
	}
	
	for (TreeNode *node in children)	{
		result = [node leafForKey:aKey];
		if (result) return result;
	}
	return nil;
}

//return my leaf value
- (NSString *)myLeafValue{
	return [self leafvalue];
}

// Return the last child leaf value that matches the key
- (NSString *) leafForKey: (NSString *) aKey
{
	NSString *result = nil;
	for (TreeNode *node in children)
		if ([[node key] isEqualToString: aKey]) result = [node leafvalue];
	if (result) return result;
	for (TreeNode *node in children)
	{
		result = [node leafForKey:aKey];
		if (result) return result;
	}
	return nil;
}

// create object array from xml, aKey is the name of the individual element that will be searched, object the represantation in xcode of this node and dict the translation table
// nodes are keys, attribute names are also keys and both can be translated.
- (NSMutableArray *) createArrayForKey:(NSString*)aKey withObject:(NSObject*)object withTranslationTable:(NSDictionary*)dict {
	NSMutableArray	*tempArray  = [[NSMutableArray alloc] init];
	NSObject		*tempObject;
	NSString		*tempKeyName;

	// TODO: refactor attribute searching, make it a method to avoid reduncancy
	for (TreeNode *node in children) {
		if (![[node key] isEqualToString:aKey]) continue;

		tempObject = [object performSelector:@selector(newInstance)];
		//NSLog(@"==============");
		// Search for the attributes of this main node
		for (id theKey in [node attributeDict]) {
			//NSLog(@"TheKey Before dict is %@",theKey);
			//[NSString stringWithFormat:@"%@_%@",[node key],[dict objectForKey:theKey]
			
			tempKeyName = [dict objectForKey:[NSString stringWithFormat:@"%@_%@",[node key], theKey]] ? 
						  [dict objectForKey:[NSString stringWithFormat:@"%@_%@",[node key], theKey]] : 
											 [NSString stringWithFormat:@"%@_%@",[node key], theKey];
			//NSLog(@"theKey after dict is  %@ and the value is %@",tempKeyName,[[node attributeDict] objectForKey:theKey]  );
			@try {
				[tempObject setValue:[[node attributeDict] objectForKey:theKey] forKey:tempKeyName];
			}@catch(NSException* ex){
				NSLog(@"Att***** TreeNode: Array creation warning. Object does not have key called %@",tempKeyName);
			};	
		}
			
		// search for sub nodes 
		for (TreeNode *child in [node children]) {
			
			// let's get the attributes and use them as keys for this object 
			for (id theKey in [child attributeDict]) {
				tempKeyName =	[dict objectForKey:[NSString stringWithFormat:@"%@_%@",[child key], theKey]] ? 
								[dict objectForKey:[NSString stringWithFormat:@"%@_%@",[child key], theKey]] : 
												   [NSString stringWithFormat:@"%@_%@",[child key], theKey];
				//NSLog(@"TreeNode: found property: %@ with value %@",tempKeyName, [[child attributeDict] objectForKey:theKey]);
				@try {
					[tempObject setValue:[[child attributeDict] objectForKey:theKey] forKey:tempKeyName];
					//[tempObject setValue:[child leafvalue] forKey:tempKeyName];
				}@catch(NSException* ex){
					NSLog(@"***** TreeNode: att. Array creation warning. Object does not have key called %@",tempKeyName);
				};	
			}
			// If the node also has leafvalue, we use the key as another property of the object
			if (![child leafvalue]) continue;
			tempKeyName = ([dict objectForKey:[child key]])  ? [dict objectForKey:[child key]] : [child key];
			//	NSLog(@"TreeNode: found property: %@ with value %@",tempKeyName,[child leafvalue] );
			@try {
				[tempObject setValue:[child leafvalue] forKey:tempKeyName];
			}@catch(NSException* ex){
				NSLog(@"***** TreeNode: Array creation warning. Object does not have key called %@",tempKeyName);
			};
		}
		
		//NSLog(@"Adding new object to array with key %i",[tempObject primaryKey]);
		[tempArray addObject:tempObject];
		tempObject = nil;
		[tempObject release];
	}
	
	
	return tempArray;
}

// Follow a key path that matches each first found branch
- (TreeNode *) objectForKeys: (NSArray *) keys
{
	if ([keys count] == 0) return self;
	
	NSMutableArray *nextArray = [NSMutableArray arrayWithArray:keys];
	[nextArray removeObjectAtIndex:0];
	
	for (TreeNode *node in children)
	{
		if ([[node key] isEqualToString:[keys objectAtIndex:0]])
			return [node objectForKeys:nextArray];
	}
	
	return nil;
}

// Print out the tree
- (void) dumpAtIndent: (int) indent
{
	for (int i = 0; i < indent; i++) printf("--");
	
	printf("[%2d] Key: %s ", indent, [key UTF8String]);
	if (leafvalue) printf("(%s)", [leafvalue UTF8String]);
	printf("\n");
	
	for (TreeNode *node in children) [node dumpAtIndent:indent + 1];
}

- (void) dump
{
	[self dumpAtIndent:0];
}

// When you're sure you're the parent of all leaves, transform to a dictionary
- (NSMutableDictionary *) dictionaryForChildren
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	
	for (TreeNode *node in children)
		if ([node isLeaf]) [results setObject:[node leafvalue] forKey:[node key]];
	
	return results;
}

- (void) dealloc
{
	self.parent = nil;
	self.children = nil;
	self.key = nil;
	self.leafvalue = nil;
	
	[super dealloc];
}

@end