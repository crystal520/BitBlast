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
        [levels addObject:[NSNumber numberWithInt:CHUNK_LEVEL_UNKNOWN]];
        [levelTypes addObject:[NSNumber numberWithInt:CHUNK_LEVEL_UNKNOWN]];
    }
	// get layer
	CCTMXLayer *layer = [self layerNamed:@"CollisionTop"];
	// get size of layer
	CGSize layerSize = [layer layerSize];
	// loop through and compile an array of good ground positions
	for(int x=0;x<layerSize.width;x++) {
		for(int y=0;y<layerSize.height;y++) {
			CCSprite *tile = [layer tileAt:ccp(x,y)];
			// restrict levels to 3 levels. all extra tiles are fluff
			if(tile && (y == layerSize.height-1 || y == layerSize.height-3 || y == layerSize.height-5)) {
				// keep track of this tile's type
				ChunkLevel type = CHUNK_LEVEL_TOP;
				if(y == layerSize.height-3) {
					type = CHUNK_LEVEL_MIDDLE;
				}
				else if(y == layerSize.height-1) {
					type = CHUNK_LEVEL_BOTTOM;
				}
				// keep track of this tile's y position
                [levels replaceObjectAtIndex:(int)type withObject:[NSNumber numberWithFloat:(tile.position.y + tile.contentSize.height * 0.5) * [ResolutionManager sharedSingleton].inversePositionScale]];
                [levelTypes replaceObjectAtIndex:(int)type withObject:[NSNumber numberWithInt:type]];
                // if we have all possible levelTypes, stop looking for them
                if(![levelTypes containsObject:[NSNumber numberWithInt:CHUNK_LEVEL_UNKNOWN]]) {
                    return;
                }
			}
		}
	}
}

#pragma mark -
#pragma mark getters
- (CGPoint) getGroundPositionWithLayer:(NSString *)layerName {
	// get layer
	CCTMXLayer *layer = [self layerNamed:layerName];
	// get size of layer
	CGSize layerSize = [layer layerSize];
	// create array to keep track of ground positions
	NSMutableArray *groundPositions = [NSMutableArray array];
	// loop through and compile an array of good ground positions
	for(int x=0;x<layerSize.width;x++) {
		for(int y=0;y<layerSize.height;y++) {
			CCSprite *tile = [layer tileAt:ccp(x,y)];
			if(tile) {
				// keep track of this tile's position
				[groundPositions addObject:[NSValue valueWithCGPoint:ccpAdd(ccpMult(tile.position, [ResolutionManager sharedSingleton].inversePositionScale), ccp(tile.contentSize.width * 0.5, tile.contentSize.height * 0.5))]];
			}
		}
	}
    // generate a random number from the array
    int ran = MIN(CCRANDOM_MIN_MAX(0, [groundPositions count]), [groundPositions count]-1);
    // make sure this is a valid number
    if(ran >= 0 && ran < [groundPositions count]) {
        CGPoint point;
        [[groundPositions objectAtIndex:ran] getValue:&point];
        return point;
    }
	return ccp(0,0);
}

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

- (BOOL) isPlatformBelowPosition:(CGPoint)position {
    // get layer
	CCTMXLayer *layer = [self layerNamed:@"CollisionTop"];
	// get size of layer
	CGSize layerSize = [layer layerSize];
	// loop through and compile an array of good ground positions
	for(int x=0;x<layerSize.width;x++) {
		for(int y=0;y<layerSize.height;y++) {
			CCSprite *tile = [layer tileAt:ccp(x,y)];
			if(tile) {
				// calculate this tile's position
                CGPoint tilePos = ccpAdd(ccpMult(tile.position, [ResolutionManager sharedSingleton].inversePositionScale), ccp(tile.contentSize.width * 0.5, tile.contentSize.height * 0.5));
                // check if the tile is below the given position
                // check if it's greater than a tile height away
                // check if the tile is to the right of the given position
                // check if the tile is not too far to the right
                if(tilePos.y < position.y && position.y - tilePos.y > (tile.contentSize.height * [ResolutionManager sharedSingleton].inversePositionScale) && tilePos.x > position.x && tilePos.x - position.x <= (tile.contentSize.width * [ResolutionManager sharedSingleton].inversePositionScale)) {
                    return YES;
                }
			}
		}
	}
    return NO;
}

@end
