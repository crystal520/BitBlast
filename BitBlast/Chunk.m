//
//  Chunk.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Chunk.h"


@implementation Chunk

@synthesize width, height;
@synthesize endPosition, startPosition, lowestPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset {
	
	if((self = [super init])) {
		
		collidables = [NSMutableArray new];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:chunkName];
		self.position = offset;
		[self addChild:map z:0];
		
		// keep track of width and height
		width = map.mapSize.width * map.tileSize.width;
		height = map.mapSize.height * map.tileSize.height;
		
		// generate end position based on width and offset
		endPosition = offset.x + width;
		// keep track of startPosition for removing chunk
		startPosition = offset.x;
		// keep track of lowestPosition for killing player
		lowestPosition = offset.y;
		
		// get collision layer
		CCTMXLayer *collision = [map layerNamed:@"Collision"];
		for(int x=0;x<map.mapSize.width;x++) {
			for(int y=0;y<map.mapSize.height;y++) {
				
				// make sure we have a tile
				int gid = [collision tileGIDAt:ccp(x, y)];
				if(gid != 0) {
					
					[collidables addObject:[[BBPhysicsWorld sharedSingleton] createBoxFromFile:@"physicsBasicTile" withPosition:ccp(x * map.tileSize.width + offset.x, (map.mapSize.height - (y+1)) * map.tileSize.height + offset.y) withData:nil]];
				}
			}
		}
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
}

- (void) cleanupPhysics {
	
	// get rid of physics bodies
	for(BBPhysicsObject *c in collidables) {
		[BBPhysicsWorld sharedSingleton].world->DestroyBody(c.body);
	}
	[collidables release];
}

@end
