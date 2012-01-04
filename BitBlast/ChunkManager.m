//
//  ChunkManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "ChunkManager.h"


@implementation ChunkManager

@synthesize currentChunks;

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
		currentChunks = [NSMutableArray new];
		overrideChunk = [NSMutableString new];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	
	[chunks release];
	[currentChunks release];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	// see if any chunks are off screen
	Chunk *firstChunk = [currentChunks objectAtIndex:0];
	
	if(firstChunk && [firstChunk convertToWorldSpace:ccp(firstChunk.position.x + firstChunk.width, 0)].x < firstChunk.startPosition) {
		[self removeChunk];
		[self addRandomChunk];
		
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kChunkCompletedNotification object:nil]];
	}
}

- (void) resetWithLevel:(NSString*)level {
	
	[self removeChunks];
	[self loadChunksForLevel:level];
}

#pragma mark -
#pragma mark adding/removing chunks
- (void) addChunk:(NSString*)chunkName {
	
	[self addChunk:chunkName withOffset:ccp(0,0)];
}

- (void) addChunk:(NSString *)chunkName withOffset:(CGPoint)offset {
	
	// see if there is an override chunk. if there is, only display that one
	if(![overrideChunk isEqualToString:@""]) {
		chunkName = overrideChunk;
	}
	
	Chunk *newChunk = [[Chunk alloc] initWithFile:chunkName withOffset:offset];
	[currentChunks addObject:newChunk];
	[self addChild:newChunk];
}

- (void) addRandomChunk {
	
	// get last chunk and new chunk's offset
	Chunk *lastChunk = [currentChunks lastObject];
	float offset = 0;
	if(lastChunk) {
		offset = lastChunk.endPosition;
	}
	
	// generate random number based on number of chunks
	int ranChunk = floor(CCRANDOM_0_1() * [chunks count]);
	
	if(ranChunk < [chunks count]) {
		[self addChunk:[chunks objectAtIndex:ranChunk] withOffset:ccp(offset, 0)];
	}
	else {
		NSLog(@"ERROR: Failed to add random chunk for index \"%i\" because it is out of bounds of the chunks array with length \"%i\"", ranChunk, [chunks count]);
	}
}

- (void) removeChunk {
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kChunkWillRemoveNotification object:nil]];
	
	// get first chunk
	Chunk *firstChunk = [currentChunks objectAtIndex:0];
	[self removeChild:firstChunk cleanup:YES];
	[currentChunks removeObjectAtIndex:0];
}

- (void) removeChunks {
	
	for(Chunk *c in currentChunks) {
		[self removeChild:c cleanup:YES];
	}
	
	[currentChunks removeAllObjects];
}

#pragma mark -
#pragma mark getting chunks
- (Chunk*) getCurrentChunk {
	return [currentChunks objectAtIndex:0];
}

#pragma mark -
#pragma mark loading chunks
- (void) loadChunksForLevel:(NSString*)levelName {
	
	// grab plist from bundle
	NSDictionary *levelPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"]];
	
	// make sure it exists
	if(levelPlist) {
		// grab first chunk
		NSString *firstChunk = [levelPlist objectForKey:@"firstChunk"];
		
		// grab array of chunks
		[chunks addObjectsFromArray:[levelPlist objectForKey:@"chunks"]];
		
		// grab override chunk
		[overrideChunk setString:[levelPlist objectForKey:@"overrideChunk"]];
		
		[self addChunk:firstChunk];
		[self addRandomChunk];
	}
	else {
		NSLog(@"ERROR: Failed to load chunks for level \"%@\" because it doesn't exist", levelName);
	}
}

@end
