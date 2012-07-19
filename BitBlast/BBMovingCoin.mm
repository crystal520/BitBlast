//
//  BBMovingCoin.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/15/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingCoin.h"

@implementation BBMovingCoinShape
@end

@implementation BBMovingCoin

@synthesize recycle, enabled;

- (id) init {
	if((self = [super initWithFile:@"coinExplosion"])) {
		[self loadAnimations];
		[self repeatAnimation:@"coinExplosionIdle" startFrame:-1];
		enabled = NO;
		recycle = YES;
		self.visible = NO;
		
		// load extra variables from dictionary
		gravity = ccpMult(CGPointFromString([dictionary objectForKey:@"gravity"]), [ResolutionManager sharedSingleton].positionScale);
		xVelRange = ccpMult(CGPointFromString([dictionary objectForKey:@"xMovementRange"]), [ResolutionManager sharedSingleton].positionScale);
		yVelRange = ccpMult(CGPointFromString([dictionary objectForKey:@"yMovementRange"]), [ResolutionManager sharedSingleton].positionScale);
		restitution = [[dictionary objectForKey:@"bounciness"] floatValue];
		lifeTime = [[dictionary objectForKey:@"lifetime"] floatValue];
		tileOffset = ccp(0, [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale);
        collisionShape = [[BBMovingCoinShape alloc] initWithDynamicBody:@"oldCoin1" node:self];
        [collisionShape setActive:NO];
	}
	return self;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if enabled
	if(enabled) {
		[super update:delta];
		
		// count down the lifetime of this coin. once it passes 0, kill it
		lifeTimer -= delta;
		if(lifeTimer <= 0) {
			[self setEnabled:NO];
		}
		
		// clamp X velocity if Y velocity is at or close to 0
		if(abs(velocity.y) <= 1) {
			velocity.x = 0;
		}
	}
}

#pragma mark -
#pragma mark super
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
				velocity = ccp(velocity.x * restitution, restitution * -velocity.y);
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
				velocity = ccp(velocity.x * restitution, restitution * -velocity.y);
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
				velocity = ccp(velocity.x * restitution, restitution * -velocity.y);
				jumping = NO;
				break;
			}
		}
	}
}

#pragma mark -
#pragma mark actions
- (void) resetWithPosition:(CGPoint)newPosition {
	dummyPosition = newPosition;
    self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	// generate random x and y velocity
	float xVel = CCRANDOM_MIN_MAX(xVelRange.x, xVelRange.y) + [Globals sharedSingleton].playerVelocity.x;
	float yVel = CCRANDOM_MIN_MAX(yVelRange.x, yVelRange.y);
	velocity = ccp(xVel, yVel);
	lifeTimer = lifeTime;
	[self setEnabled:YES];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(newEnabled && !enabled) {
		self.visible = YES;
		recycle = NO;
        [collisionShape setActive:YES];
	}
	else if(enabled && !newEnabled) {
		self.visible = NO;
		recycle = YES;
        [collisionShape setActive:NO];
	}
	enabled = newEnabled;
}

@end
