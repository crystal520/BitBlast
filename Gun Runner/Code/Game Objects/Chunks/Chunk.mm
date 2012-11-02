//
//  Chunk.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Chunk.h"


@implementation Chunk

@synthesize width, height, playerZ, dummyPosition, dummySize;
@synthesize endPosition, startPosition, lowestPosition, dummyStartPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset {
	
    NSLog(@"LOADING CHUNK: %@", chunkName);
	if((self = [super initWithTMXFile:chunkName])) {
		
		dummyPosition = offset;
		self.position = ccpMult(offset, [ResolutionManager sharedSingleton].positionScale);
		
		// keep track of player's z value
		if([self layerNamed:@"Foreground"]) {
			playerZ = [[self layerNamed:@"Foreground"] zOrder]-1;
		}
		else if([self layerNamed:@"Background"]) {
			playerZ = [[self layerNamed:@"Background"] zOrder]+1;
		}
		else {
			playerZ = 1;
		}
		
		// keep track of width and height
		width = self.mapSize.width * self.tileSize.width;
		height = self.mapSize.height * self.tileSize.height;
		dummySize = CGSizeMake(width * [ResolutionManager sharedSingleton].positionScale, height * [ResolutionManager sharedSingleton].positionScale);
		
		// generate end position based on width and offset
		endPosition = offset.x + width;
		// keep track of startPosition for removing chunk
		startPosition = offset.x;
		dummyStartPosition = offset.x * [ResolutionManager sharedSingleton].imageScale;
		// keep track of lowestPosition for killing player
		lowestPosition = offset.y;
        
        // loop through layers and set texture parameters
        for(HKTMXLayer *t in self.children) {
            [t.texture setAliasTexParameters];
        }
		
		// generate levels from this chunk
		[self generateLevels];
	}
	
	return self;
}

- (void) dealloc {
	[levelTypes release];
	[levels release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) generateLevels {
	// make set
	levels = [[NSMutableArray alloc] initWithCapacity:CHUNK_LEVEL_COUNT];
	levelTypes = [[NSMutableArray alloc] initWithCapacity:CHUNK_LEVEL_COUNT];
    for(int i=0;i<CHUNK_LEVEL_COUNT;i++) {
        int level = CHUNK_LEVEL_COUNT-(i+1);
        [levels addObject:[NSNumber numberWithInt:self.tileSize.height * ((level * 2) + 0.5)]];
        [levelTypes addObject:[NSNumber numberWithInt:i]];
    }
}

#pragma mark -
#pragma mark getters
- (int) getRandomLevel {
	// generate a random number from the array
	int ran = CCRANDOM_MIN_MAX(0, [levels count]);
	// make sure this is a valid number
	if(ran >= 0 && ran < [levels count]) {
		return ran;
	}
	return 0;
}

- (ChunkLevel) getLevelType:(int)index {
	return (ChunkLevel)([[levelTypes objectAtIndex:index] intValue]);
}

- (int) getLevel:(int)index {
	return [[levels objectAtIndex:index] intValue];
}

- (BOOL) isLowestLevel:(CGPoint)position {
    // grab the lowest level Y value for this chunk
    int lowestLevel = [self getLevel:CHUNK_LEVEL_BOTTOM];
    // see if the distance between the given position's y and the lowest level are less than 1 tile's height away
    return (position.y * [ResolutionManager sharedSingleton].inversePositionScale - lowestLevel <= self.tileSize.height);
}

@end
