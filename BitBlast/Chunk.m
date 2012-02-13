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
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
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

@end
