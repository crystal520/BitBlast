//
//  ChunkManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "ChunkManager.h"
#import "BBDropshipManager.h"

@implementation ChunkManager

@synthesize currentChunks, curSpeedLevel, chunkCount;

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
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseLevel) name:kPlayerLevelIncreaseNotification object:nil];
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
	
    // check to see if this is the first chunk
    if([currentChunks count] != 0) {
        // see if there is an override chunk. if there is, only display that one
        if(![overrideChunk isEqualToString:@""]) {
            chunkName = overrideChunk;
        }
        // see if the tutorial is enabled
        if([Globals sharedSingleton].tutorial) {
            // make sure we don't go outside the bounds of the chunks array
            int chunkLevel = MIN([Globals sharedSingleton].tutorialState, [chunks count]);
            // set chunk to load based on current state of tutorial
            chunkName = [[chunks objectAtIndex:chunkLevel] objectAtIndex:0];
            // see if we should advance to the next tutorial step
            switch([Globals sharedSingleton].tutorialState) {
                case TUTORIAL_STATE_START:
                    [Globals sharedSingleton].tutorialStateCanChange = YES;
                    break;
                case TUTORIAL_STATE_POST_JUMP_UP:
                    [Globals sharedSingleton].tutorialState = TUTORIAL_STATE_DOUBLE_JUMP;
                    [Globals sharedSingleton].tutorialStateCanChange = YES;
                    break;
                case TUTORIAL_STATE_POST_JUMP_DOWN:
                    [Globals sharedSingleton].tutorialState = TUTORIAL_STATE_DROPSHIP;
                    [Globals sharedSingleton].tutorialStateCanChange = YES;
                    break;
                default:
                    break;
            }
        }
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
    
    // increment total number of chunks
    chunkCount++;
    
    // see if tutorial needs to end
    if([Globals sharedSingleton].tutorial && [Globals sharedSingleton].tutorialState == TUTORIAL_STATE_FINISH) {
        // load jungle level chunks
        [self replaceChunksWithLevel:@"jungleLevel"];
        // no longer in the tutorial
        [Globals sharedSingleton].tutorial = NO;
        // reset the dropship level
        [BBDropshipManager sharedSingleton].dropshipLevel = 0;
        // post notification so other classes know that the tutorial is over
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventTutorialOver object:nil]];
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
    [firstChunk release];
    
	// reorder chunks' zorder
	for(int i=0,j=[currentChunks count];i<j;i++) {
		Chunk *c = [currentChunks objectAtIndex:i];
		[self reorderChild:c z:j-i];
	}
}

- (void) removeChunks {
	
	for(Chunk *c in currentChunks) {
		[self removeChild:c cleanup:YES];
        [c release];
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

- (void) replaceChunksWithLevel:(NSString*)levelName {
    // grab plist from bundle
	NSDictionary *levelPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"]];
    
    // make sure it exists
    if(levelPlist) {
        // reset speed level
        curSpeedLevel = 0;
        // grab array of chunks
		[chunks setArray:[levelPlist objectForKey:@"chunks"]];
        // grab override chunk
		[overrideChunk setString:[levelPlist objectForKey:@"overrideChunk"]];
    }
    else {
        NSLog(@"ERROR: Failed to replace chunks with level \"%@\" because the file doesn't exist", levelName);
    }
}

#pragma mark -
#pragma mark notifications
- (void) increaseLevel {
	self.curSpeedLevel++;
}

@end
