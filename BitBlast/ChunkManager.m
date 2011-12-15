//
//  ChunkManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "ChunkManager.h"


@implementation ChunkManager

+ (ChunkManager*) sharedSingleton {
	
	static ChunkManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[ChunkManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	
	if((self = [super init])) {
		
		chunks = [NSMutableArray new];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	
	[chunks release];
}

- (void) updateWithSpeed:(float)speed {
	
	for(Chunk *c in chunks) {
		[c setPosition:ccp(c.position.x + speed, c.position.y)];
		[c scrollWithSpeed:-speed/PTM_RATIO];
	}
}

- (void) addChunk:(NSString*)chunkName {
	
	Chunk *newChunk = [[Chunk alloc] initWithFile:chunkName];
	[chunks addObject:newChunk];
	[self addChild:newChunk];
}

- (void) loadChunksForLevel:(NSString*)levelName {
	
	// grab plist from bundle
	NSDictionary *levelPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"]];
	
	// make sure it exists
	if(levelPlist) {
		// grab first chunk
		NSString *firstChunk = [levelPlist objectForKey:@"firstChunk"];
		
		// grab array of chunks
		//NSArray *chunks = [levelPlist objectForKey:@"chunks"];
		
		// grab override chunk
		//NSString *overrideChunk = [levelPlist objectForKey:@"overrideChunk"];
		
		[self addChunk:firstChunk];
	}
	else {
		NSLog(@"ERROR: Failed to load chunks for level \"%@\" because it doesn't exist", levelName);
	}
}

@end
