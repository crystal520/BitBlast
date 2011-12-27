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
		CCTMXLayer *collisionTop = [self layerNamed:@"CollisionTop"];
		CCTMXLayer *collisionBottom = [self layerNamed:@"CollisionBottom"];
		for(int x=0;x<self.mapSize.width;x++) {
			for(int y=0;y<self.mapSize.height;y++) {
				
				[self makeTileAt:ccp(x, y) withLayer:collision withOffset:offset withTag:TAG_COLLISION_TILE];
				[self makeTileAt:ccp(x, y) withLayer:collisionTop withOffset:offset withTag:TAG_COLLISION_TILE_TOP];
				[self makeTileAt:ccp(x, y) withLayer:collisionBottom withOffset:offset withTag:TAG_COLLISION_TILE_BOTTOM];
			}
		}
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	//[map release];
}

- (void) makeTileAt:(CGPoint)point withLayer:(CCTMXLayer*)layer withOffset:(CGPoint)offset withTag:(int)tag {
	
	int gid = [layer tileGIDAt:point];
	if(gid != 0) {
		CCSprite *tile = [layer tileAt:point];
		tile.tag = tag;
		BBPhysicsObject *newTile = [[BBPhysicsWorld sharedSingleton] createPhysicsObjectFromFile:@"physicsBasicTile" withPosition:ccp(point.x * self.tileSize.width + offset.x, (self.mapSize.height - (point.y+1)) * self.tileSize.height + offset.y) withData:tile];
		[collidables addObject:newTile];
	}
}

- (void) cleanupPhysics {
	
	// get rid of physics bodies
	for(BBPhysicsObject *c in collidables) {
		[BBPhysicsWorld sharedSingleton].world->DestroyBody(c.body);
	}
	[collidables release];
}

@end
