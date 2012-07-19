//
//  BBMovingObject.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/4/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingObject.h"


@implementation BBMovingObject

@synthesize touchingPlatform, jumping, maxVelocity, minVelocity, velocity, gravity;

- (id) init {
	if((self = [super init])) {
		[self setDefaults];
	}
	return self;
}

- (id) initWithFile:(NSString *)filename {
	if((self = [super initWithFile:filename])) {
		[self setDefaults];
	}
	return self;
}

- (void) setDefaults {
	clampVelocity = NO;
	needsPlatformCollisions = YES;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// save previous position
	prevDummyPosition = dummyPosition;
	// apply gravity to velocity if object is not jumping
	if(!jumping) {
		velocity = ccpSub(velocity, gravity);
	}
	// clamp velocity to max and min
	if(clampVelocity) {
		velocity = ccp(MIN(velocity.x, maxVelocity.x), MIN(velocity.y, maxVelocity.y));
		velocity = ccp(MAX(velocity.x, minVelocity.x), MAX(velocity.y, minVelocity.y));
	}
	// apply velocity to position
	dummyPosition = ccpAdd(dummyPosition, ccpMult(velocity, delta));
	// check if this object is colliding with any platforms
	if(needsPlatformCollisions) {
		[self checkPlatformCollisions];
	}
	// update actual position
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

#pragma mark -
#pragma mark actions
- (void) checkPlatformCollisions {
	// special note about tile collisions: tiles' origin is at (0, 0) instead of the normal (0.5, 0.5) anchor
	touchingPlatform = NO;
	for(Chunk *c in [ChunkManager sharedSingleton].currentChunks) {
		
		//NSSet *playerVerts = [self positionsInChunk:c];
		
		//for(NSValue *v in playerVerts) {
		// get tile position from player's current position
		CGPoint playerTilePos = [self positionInChunk:c];
		//[v getValue:&playerTilePos];
		
		// return if player's tile position is invalid
		if(playerTilePos.y >= c.mapSize.height || playerTilePos.y < 0 || playerTilePos.x < 0 || playerTilePos.x >= c.mapSize.width) {
			continue;
		}
		
		// check for normal collision layer
		uint gid = [[c layerNamed:@"Collision"] tileGIDAt:playerTilePos];
		if(gid) {
			CCSprite *tile = [[c layerNamed:@"Collision"] tileAt:playerTilePos];
			// if the lowest part of the sprite is less than the middle of the tile
			// set its position so the lowest part of the sprite is at the middle of the tile
			float actualTilePos = tile.position.y * [ResolutionManager sharedSingleton].inversePositionScale;
			if(dummyPosition.y <= actualTilePos + tile.contentSize.height * 0.5 + tileOffset.y) {
				dummyPosition = ccp(dummyPosition.x + tileOffset.x, actualTilePos + (tile.contentSize.height * 0.5) + tileOffset.y);
				touchingPlatform = YES;
				velocity = ccp(velocity.x, 0);
				break;
			}
		}
		
		// check for collision top layer
		gid = [[c layerNamed:@"CollisionTop"] tileGIDAt:playerTilePos];
		if(gid) {
			CCSprite *tile = [[c layerNamed:@"CollisionTop"] tileAt:playerTilePos];
			// if the lowest part of the sprite is less than the middle of the tile,
			// the sprite is moving downwards, and previous lowest part of the sprite is greater than the middle of the tile
			float actualTilePos = tile.position.y * [ResolutionManager sharedSingleton].inversePositionScale;
			if(dummyPosition.y <= actualTilePos + (tile.contentSize.height * 0.5) + tileOffset.y && velocity.y < 0 && prevDummyPosition.y >= actualTilePos + (tile.contentSize.height * 0.5) + tileOffset.y) {
				dummyPosition = ccp(dummyPosition.x + tileOffset.x, actualTilePos + (tile.contentSize.height * 0.5) + tileOffset.y);
				touchingPlatform = YES;
				velocity = ccp(velocity.x, 0);
				break;
			}
		}
		
		// check for collision bottom layer
		gid = [[c layerNamed:@"CollisionBottom"] tileGIDAt:playerTilePos];
		if(gid) {
			CCSprite *tile = [[c layerNamed:@"CollisionBottom"] tileAt:playerTilePos];
			// if the highest part of the sprite is greater than the lowest part of the tile,
			// the sprite is moving upwards, and the previous highest part of the sprite is less than the lowest part of the tile
			float actualTilePos = tile.position.y * [ResolutionManager sharedSingleton].inversePositionScale;
			if(dummyPosition.y >= actualTilePos + tileOffset.y && velocity.y > 0 && prevDummyPosition.y <= actualTilePos) {
				dummyPosition = ccp(dummyPosition.x + tileOffset.x, actualTilePos + tileOffset.y);
				velocity = ccp(velocity.x, 0);
				jumping = NO;
				break;
			}
		}
	}
}

#pragma mark -
#pragma mark convenience functions
- (CGPoint) positionInChunk:(Chunk*)chunk {
	return ccp(floor((dummyPosition.x - (tileOffset.x + chunk.startPosition)) / chunk.tileSize.width), chunk.mapSize.height - floor((dummyPosition.y - tileOffset.y) / chunk.tileSize.height) - 1);
}

@end
