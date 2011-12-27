//
//  Chunk.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Chunk.h"


@implementation Chunk

@synthesize width, height, playerZ;
@synthesize endPosition, startPosition, lowestPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset {
	
	if((self = [super initWithTMXFile:chunkName])) {
		
		collidables = [NSMutableArray new];
		
		self.position = offset;
		
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
		
		// generate end position based on width and offset
		endPosition = offset.x + width;
		// keep track of startPosition for removing chunk
		startPosition = offset.x;
		// keep track of lowestPosition for killing player
		lowestPosition = offset.y;
		
		// get collision layer
		CCTMXLayer *collision = [self layerNamed:@"Collision"];
		for(int x=0;x<self.mapSize.width;x++) {
			for(int y=0;y<self.mapSize.height;y++) {
				
				// make sure we have a tile
				int gid = [collision tileGIDAt:ccp(x, y)];
				if(gid != 0) {
					CCSprite *tile = [collision tileAt:ccp(x, y)];
					tile.tag = TAG_COLLISION_TILE;
					BBPhysicsObject *newTile = [[BBPhysicsWorld sharedSingleton] createPhysicsObjectFromFile:@"physicsBasicTile" withPosition:ccp(x * self.tileSize.width + offset.x, (self.mapSize.height - (y+1)) * self.tileSize.height + offset.y) withData:tile];
					[collidables addObject:newTile];
				}
			}
		}
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	//[map release];
}

- (void) cleanupPhysics {
	
	// get rid of physics bodies
	for(BBPhysicsObject *c in collidables) {
		[BBPhysicsWorld sharedSingleton].world->DestroyBody(c.body);
	}
	[collidables release];
}

@end
