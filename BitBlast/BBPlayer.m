//
//  BBPlayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPlayer.h"

@implementation BBPlayer

@synthesize velocity;

- (id) init {
	if((self = [super initWithFile:@"playerProperties"])) {
		
		self.tag = TAG_PLAYER;
		
		// create and load basic weapon
		weapon = [[BBWeapon alloc] init];
		[self addChild:weapon];
		
		// load values from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue];
		minSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"minSpeed"] floatValue];
		maxSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"maxSpeed"] floatValue];
		speedIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"incrementPercent"] floatValue];
		chunksToIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"numChunksToIncrement"] intValue];
		maxJumpTime = [[dictionary objectForKey:@"maxJumpTime"] floatValue];
		gravity = [[dictionary objectForKey:@"gravity"] floatValue];
		shootAngle = [[dictionary objectForKey:@"shootAngle"] floatValue];
		
		[self reset];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkCompleted) name:kChunkCompletedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkWillRemove) name:kChunkWillRemoveNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	if(!dead) {
		// keep track of previous position
		prevPosition = self.position;
		
		// apply jump
		if(jumping) {
			jumpTimer += delta;
			if(jumpTimer >= maxJumpTime) {
				jumping = NO;
			}
			velocity = ccp(velocity.x, jumpImpulse);
		}
		// apply gravity
		if(!jumping) {
			velocity = ccp(velocity.x, velocity.y - gravity);
		}
		// apply velocity to position
		self.position = ccp(self.position.x + velocity.x, self.position.y + velocity.y);
		
		[self checkCollisions];
		
		// keep track of previous size. done here so that a change in sprite frame size won't affect prevSize
		prevSize = sprite.contentSize;
		
		// update score
		[ScoreManager sharedSingleton].distance = floor(self.position.x / 64);
		
		// check for falling death
		if(self.position.y + sprite.contentSize.height < [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
			[self die:@"fall"];
		}
	}
}

#pragma mark -
#pragma mark notifications
- (void) chunkCompleted {
	
	// increment the number of chunks completed
	curNumChunks++;
	// see if we've reached the amount of chunks completed to increment the player's speed
	if(curNumChunks >= chunksToIncrement) {
		// reset the number of chunks
		curNumChunks = 0;
		// increment the player's speed
		float speed = velocity.x + speedIncrement * velocity.x;
		// make sure we don't go over the maximum speed allowed
		speed = MIN(speed, maxSpeed);
		NSLog(@"Player speed is now %.2f after incrementing", speed);
		velocity = ccp(speed, velocity.y);
	}
	
	[[[ChunkManager sharedSingleton] getCurrentChunk] addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
	[self release];
}

- (void) chunkWillRemove {
	[self retain];
	[[[ChunkManager sharedSingleton] getCurrentChunk] removeChild:self cleanup:NO];
	
	self.sprite.position = ccp(self.sprite.position.x - [[ChunkManager sharedSingleton] getCurrentChunk].width, self.sprite.position.y);
}

#pragma mark -
#pragma mark actions
- (void) reset {
	
	// set initial values
	[self playAnimation:@"walk"];
	[weapon loadFromFile:@"pistol"];
	self.position = ccp(64, 192);
	velocity = ccp(minSpeed, 0);
	curNumChunks = 0;
	jumpTimer = 0.0f;
	prevSize = sprite.contentSize;
	dead = NO;
	
	// add to current chunk
	[self.parent removeChild:self cleanup:NO];
	[[[ChunkManager sharedSingleton] getCurrentChunk] addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
}

- (void) die:(NSString*)reason {
	
	if([reason isEqualToString:@"fall"]) {
		dead = YES;
	}
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerDeadNotification object:nil]];
}

- (void) jump {
	
	// only jump if we're not jumping already
	if(touchingPlatform) {
		touchingPlatform = NO;
		jumping = YES;
		jumpTimer = 0;
	}
}

- (void) endJump {
	jumping = NO;
}

- (void) shoot:(CGPoint)touchPos {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	// split screen up into halves
	float shootPortion = winSize.height/2.0f;
	// bottom half of screen. player is shooting diagonally down
	if(touchPos.y <= shootPortion) {
		weapon.angle = -shootAngle;
	}
	// top half of screen. player is shooting diagonally up
	else {
		weapon.angle = shootAngle;
	}
}

- (void) endShoot {
	weapon.angle = 0;
}

- (void) checkCollisions {
	
	// special note about tile collisions: tiles' origin is at (0, 0) instead of the normal (0.5, 0.5) anchor
	touchingPlatform = NO;
	for(Chunk *c in [ChunkManager sharedSingleton].currentChunks) {
		
		NSSet *playerVerts = [self positionsInChunk:c];
		
		for(NSValue *v in playerVerts) {
			// get tile position from player's current position
			CGPoint playerTilePos;
			[v getValue:&playerTilePos];
			
			// return if player's tile position is invalid
			if(playerTilePos.y >= c.mapSize.height || playerTilePos.y < 0 || playerTilePos.x < 0 || playerTilePos.x >= c.mapSize.width) {
				continue;
			}
			
			// check for normal collision layer
			uint gid = [[c layerNamed:@"Collision"] tileGIDAt:playerTilePos];
			if(gid) {
				CCSprite *tile = [[c layerNamed:@"Collision"] tileAt:playerTilePos];
				// if this is a special half collision block and the lowest part of the sprite is less than the middle of the tile
				// set its position so the lowest part of the sprite is at the middle of the tile
				if(/*gid == 2 &&*/ self.position.y - (sprite.contentSize.height * 0.5) <= tile.position.y + tile.contentSize.height * 0.5) {
					self.position = ccp(self.position.x, tile.position.y + (tile.contentSize.height + sprite.contentSize.height) * 0.5);
					touchingPlatform = YES;
					velocity = ccp(velocity.x, 0);
				}
			}
			
			// check for collision top layer
			gid = [[c layerNamed:@"CollisionTop"] tileGIDAt:playerTilePos];
			if(gid) {
				CCSprite *tile = [[c layerNamed:@"CollisionTop"] tileAt:playerTilePos];
				// if this is a special half collision block, the lowest part of the sprite is less than the middle of the tile,
				// the sprite is moving downwards, and previous lowest part of the sprite is greater than the middle of the tile
				if(/*gid == 2 &&*/ self.position.y - (sprite.contentSize.height * 0.5) <= tile.position.y + (tile.contentSize.height * 0.5) && velocity.y < 0 && prevPosition.y - (prevSize.height * 0.5) >= tile.position.y + (tile.contentSize.height * 0.5)) {
					self.position = ccp(self.position.x, tile.position.y + (tile.contentSize.height + sprite.contentSize.height) * 0.5);
					touchingPlatform = YES;
					velocity = ccp(velocity.x, 0);
				}
			}
			
			// check for collision bottom layer
			gid = [[c layerNamed:@"CollisionBottom"] tileGIDAt:playerTilePos];
			if(gid) {
				CCSprite *tile = [[c layerNamed:@"CollisionBottom"] tileAt:playerTilePos];
				// if this is a special half collision block, the highest part of the sprite is greater than the lowest part of the tile,
				// the sprite is moving upwards, and the previous highest part of the sprite is less than the lowest part of the tile
				if(/*gid == 2 &&*/ self.position.y + (sprite.contentSize.height * 0.5) >= tile.position.y && velocity.y > 0 && prevPosition.y + (sprite.contentSize.height * 0.5) <= tile.position.y) {
					self.position = ccp(self.position.x, tile.position.y - (sprite.contentSize.height * 0.5));
					velocity = ccp(velocity.x, 0);
					jumping = NO;
				}
			}
		}
	}
}

#pragma mark -
#pragma mark convenience functions
- (CGPoint) positionInChunk:(Chunk*)chunk {
	return ccp(floor((self.position.x - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor(self.position.y / chunk.tileSize.height) - 1);
}

- (NSSet*) positionsInChunk:(Chunk*)chunk {
	
	NSMutableSet *positions = [NSMutableSet set];
	// top left corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((self.position.x - (sprite.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((self.position.y + (sprite.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	// top right corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((self.position.x + (sprite.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((self.position.y + (sprite.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	// bottom left corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((self.position.x - (sprite.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((self.position.y - (sprite.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	// bottom right corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((self.position.x + (sprite.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((self.position.y - (sprite.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	
	return positions;
}

@end
