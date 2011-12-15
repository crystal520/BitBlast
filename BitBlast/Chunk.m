//
//  Chunk.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Chunk.h"


@implementation Chunk

- (id) initWithFile:(NSString*)chunkName {
	
	if((self = [super init])) {
		
		collidables = [NSMutableArray new];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:chunkName];
		[self addChild:map z:0];
		
		// get collision layer
		CCTMXLayer *collision = [map layerNamed:@"Collision"];
		for(int x=0;x<map.mapSize.width;x++) {
			for(int y=0;y<map.mapSize.height;y++) {
				
				// make sure we have a tile
				int gid = [collision tileGIDAt:ccp(x, y)];
				if(gid != 0) {
					
					[collidables addObject:[[BBPhysicsWorld sharedSingleton] createBoxAt:ccp(x * map.tileSize.width, (map.mapSize.height - (y+1)) * map.tileSize.height) size:CGSizeMake(map.tileSize.width, map.tileSize.height) dynamic:NO friction:1 density:0 restitution:0 anchor:ccp(0.5f, 0.5f) userData:nil]];
				}
			}
		}
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
}

- (void) scrollWithSpeed:(float)speed {
	
	// update collidable tiles
	for(BBPhysicsObject *c in collidables) {
		b2Vec2 pos = c.body->GetPosition();
		pos.x -= speed;
		c.body->SetTransform(pos, 0);
	}
}

@end
