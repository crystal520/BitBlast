//
//  BBMovingCoin.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/15/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBMovingCoin.h"

@implementation BBMovingCoinShape
@end

@implementation BBMovingCoin

@synthesize recycle, enabled, type;

- (id) init {
	if((self = [super initWithFile:@"coinExplosion"])) {
		[self repeatAnimation:@"coinIdle" startFrame:-1];
		enabled = NO;
		recycle = YES;
		self.visible = NO;
		
		// load extra variables from dictionary
		gravity = CGPointFromString([dictionary objectForKey:@"gravity"]);
		xVelRange = ccpMult(CGPointFromString([dictionary objectForKey:@"xMovementRange"]), [ResolutionManager sharedSingleton].inversePositionScale);
		yVelRange = ccpMult(CGPointFromString([dictionary objectForKey:@"yMovementRange"]), [ResolutionManager sharedSingleton].inversePositionScale);
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
	}
}

#pragma mark -
#pragma mark super
- (void) checkPlatformCollisions:(float)delta {
	// special note about tile collisions: tiles' origin is at (0, 0) instead of the normal (0.5, 0.5) anchor
	touchingPlatform = NO;
	for(Chunk *c in [ChunkManager sharedSingleton].currentChunks) {
		
		// get tile position from player's current position
		CGPoint playerTilePos = [self positionInChunk:c];
        // get tile size
        CGSize tileSize = [c layerNamed:@"CollisionTop"].mapTileSize;
		
		// return if player's tile position is invalid
		if(playerTilePos.y >= c.mapSize.height || playerTilePos.y < 0 || playerTilePos.x < 0 || playerTilePos.x >= c.mapSize.width) {
			continue;
		}
		
		// check for normal collision layer
		uint gid = [[c layerNamed:@"Collision"] tileGIDAt:playerTilePos];
		if(gid) {
            CGPoint tilePos = [[c layerNamed:@"Collision"] positionAt:playerTilePos];
			// if the lowest part of the sprite is less than the middle of the tile
			// set its position so the lowest part of the sprite is at the middle of the tile
			float actualTilePos = tilePos.y * [ResolutionManager sharedSingleton].inversePositionScale;
			if(dummyPosition.y <= actualTilePos + tileSize.height * 0.5 + tileOffset.y) {
				dummyPosition = ccp(dummyPosition.x + tileOffset.x, actualTilePos + (tileSize.height * 0.5) + tileOffset.y);
				touchingPlatform = YES;
				velocity = ccp(velocity.x * restitution, restitution * -velocity.y);
				break;
			}
		}
		
		// check for collision top layer
		gid = [[c layerNamed:@"CollisionTop"] tileGIDAt:playerTilePos];
		if(gid) {
            CGPoint tilePos = [[c layerNamed:@"CollisionTop"] positionAt:playerTilePos];
			// if the lowest part of the sprite is less than the middle of the tile,
			// the sprite is moving downwards, and previous lowest part of the sprite is greater than the middle of the tile
			float actualTilePos = tilePos.y * [ResolutionManager sharedSingleton].inversePositionScale;
            int tileMid = actualTilePos + (tileSize.height * 0.5) + tileOffset.y;
			if(dummyPosition.y <= tileMid && velocity.y < 0 && prevDummyPosition.y >= tileMid) {
				dummyPosition = ccp(dummyPosition.x + tileOffset.x, actualTilePos + (tileSize.height * 0.5) + tileOffset.y);
				touchingPlatform = YES;
				velocity = ccp(velocity.x * restitution, restitution * -velocity.y);
				break;
			}
		}
		
		// check for collision bottom layer
		gid = [[c layerNamed:@"CollisionBottom"] tileGIDAt:playerTilePos];
		if(gid) {
            CGPoint tilePos = [[c layerNamed:@"CollisionBottom"] positionAt:playerTilePos];
			// if the highest part of the sprite is greater than the lowest part of the tile,
			// the sprite is moving upwards, and the previous highest part of the sprite is less than the lowest part of the tile
			float actualTilePos = tilePos.y * [ResolutionManager sharedSingleton].inversePositionScale;
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
    [self repeatAnimation:@"coinIdle" startFrame:-1];
	dummyPosition = newPosition;
    self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	// generate random x and y velocity
	float xVel = CCRANDOM_MIN_MAX(xVelRange.x, xVelRange.y) + [Globals sharedSingleton].playerVelocity.x;
	float yVel = CCRANDOM_MIN_MAX(yVelRange.x, yVelRange.y);
	velocity = ccp(xVel, yVel);
	lifeTimer = lifeTime;
	[self setEnabled:YES];
    type = MOVING_COIN_TYPE_COIN;
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
