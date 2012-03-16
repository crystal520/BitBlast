//
//  ChunkManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "ChunkManager.h"


@implementation ChunkManager

@synthesize currentChunks, curSpeedLevel;

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
	
	if(firstChunk && [firstChunk convertToWorldSpace:ccp(firstChunk.dummyPosition.x + firstChunk.dummySize.width, 0)].x < firstChunk.dummyStartPosition) {
		[self removeChunk];
		[self addRandomChunk];
		
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kChunkCompletedNotification object:nil]];
	}
}

- (void) resetWithLevel:(NSString*)level {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLoadLevelNotification object:nil]];
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
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kChunkAddedNotification object:nil]];
	
	// set z order based on previous chunk
	if([currentChunks count] > 1) {
		Chunk *prevChunk = [currentChunks objectAtIndex:[currentChunks count]-1];
		[self addChild:newChunk z:[prevChunk zOrder]-1];
	}
	else {
		[self addChild:newChunk];
	}
}

- (void) addRandomChunk {
	
	// get last chunk and new chunk's offset
	Chunk *lastChunk = [currentChunks lastObject];
	float offset = 0;
	if(lastChunk) {
		offset = lastChunk.endPosition;
	}
	
	// generate random number based on number of chunks
	int ranChunk = floor(CCRANDOM_0_1() * [[chunks objectAtIndex:curSpeedLevel] count]);
	
	if(ranChunk < [[chunks objectAtIndex:curSpeedLevel] count]) {
		[self addChunk:[[chunks objectAtIndex:curSpeedLevel] objectAtIndex:ranChunk] withOffset:ccp(offset, 0)];
	}
	else {
		NSLog(@"ERROR: Failed to add random chunk for index \"%i\" because it is out of bounds of the chunks array with length \"%i\"", ranChunk, [[chunks objectAtIndex:curSpeedLevel] count]);
	}
}

- (void) removeChunk {
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kChunkWillRemoveNotification object:nil]];
	
	// get first chunk
	Chunk *firstChunk = [currentChunks objectAtIndex:0];
	[self removeChild:firstChunk cleanup:YES];
	[currentChunks removeObjectAtIndex:0];
	
	// reorder chunks' zorder
	for(int i=0,j=[currentChunks count];i<j;i++) {
		Chunk *c = [currentChunks objectAtIndex:i];
		[self reorderChild:c z:j-i];
	}
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

- (Chunk*) getChunkAtIndex:(int)index {
	return [currentChunks objectAtIndex:index];
}

- (Chunk*) getLastChunk {
	return [currentChunks lastObject];
}

#pragma mark -
#pragma mark setters
- (void) setCurSpeedLevel:(int)newCurSpeedLevel {
	// make sure the new level doesn't go out of bounds
	curSpeedLevel = MIN(newCurSpeedLevel, [chunks count]-1);
}

#pragma mark -
#pragma mark loading chunks
- (void) loadChunksForLevel:(NSString*)levelName {
	
	// grab plist from bundle
	NSDictionary *levelPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"]];
	
	// make sure it exists
	if(levelPlist) {
		// reset speed level
		curSpeedLevel = 0;
		// grab first chunk
		NSString *firstChunk = [levelPlist objectForKey:@"firstChunk"];
		
		// grab array of chunks
		[chunks setArray:[levelPlist objectForKey:@"chunks"]];
		
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
