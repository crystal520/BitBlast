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
	levels = [NSMutableSet new];
	levelTypes = [NSMutableSet new];
	// get layer
	CCTMXLayer *layer = [self layerNamed:@"CollisionTop"];
	// get size of layer
	CGSize layerSize = [layer layerSize];
	// loop through and compile an array of good ground positions
	for(int x=0;x<layerSize.width;x++) {
		for(int y=0;y<layerSize.height;y++) {
			CCSprite *tile = [layer tileAt:ccp(x,y)];
			// restrict levels to 3 levels. all extra tiles are fluff
			if(tile && (y == 12 || y == 10 || y == 14)) {
				// keep track of this tile's type
				ChunkLevel type = CHUNK_LEVEL_BOTTOM;
				if(y == 12) {
					type = CHUNK_LEVEL_MIDDLE;
				}
				else if(y == 14) {
					type = CHUNK_LEVEL_TOP;
				}
				// keep track of this tile's y position
				[levels addObject:[NSNumber numberWithInt:(tile.position.y + tile.contentSize.height * 0.5) * [ResolutionManager sharedSingleton].inversePositionScale]];
				[levelTypes addObject:[NSNumber numberWithInt:type]];
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
	while(true) {
		// generate a random number from the array
		int ran = CCRANDOM_MIN_MAX(0, [groundPositions count]);
		// make sure this is a valid number
		if(ran >= 0 && ran < [groundPositions count]) {
			CGPoint point;
			[[groundPositions objectAtIndex:ran] getValue:&point];
			return point;
		}
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
	return (ChunkLevel)([[[levelTypes allObjects] objectAtIndex:index] intValue]);
}

- (int) getLevel:(int)index {
	return [[[levels allObjects] objectAtIndex:index] intValue];
}

@end
