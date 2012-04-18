//
//  BBMovingCoin.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/15/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingCoin.h"


@implementation BBMovingCoin

@synthesize recycle;

- (id) init {
	if((self = [super initWithFile:@"coinExplosion"])) {
		[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"oldCoin1.png"]];
		recycle = YES;
		self.gravity = ccp(0, 50);
		restitution = 0.9;
	}
	return self;
}

- (void) update:(float)delta {
	[super update:delta];
}

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
				velocity = ccp(velocity.x, restitution * -velocity.y);
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
				velocity = ccp(velocity.x, restitution * -velocity.y);
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
				velocity = ccp(velocity.x, restitution * -velocity.y);
				jumping = NO;
				break;
			}
		}
	}
}

- (void) resetWithPosition:(CGPoint)newPosition {
	dummyPosition = newPosition;
	// generate random x and y velocity
	float xVel = CCRANDOM_MIN_MAX(-40, 40);
	float yVel = CCRANDOM_MIN_MAX(200, 300);
	velocity = ccp(xVel, yVel);
	recycle = NO;
}

@end
