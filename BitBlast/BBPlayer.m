//
//  BBPlayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPlayer.h"

@implementation BBPlayer

@synthesize velocity, maxVelocity, touchingPlatform, gravity, jumping, dead;

- (id) init {
	if((self = [super initWithFile:@"playerProperties"])) {
		
		self.tag = TAG_PLAYER;
		[self loadAnimations];
		self.sprite.anchorPoint = ccp(0.5, 0);
		[self setState:kPlayerUnknown];
		
		// create and load basic weapon
		weapon = [[BBWeapon alloc] init];
		[self addChild:weapon];
		
		// setup torso
		[self setupTorso];
		
		// load values from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue];
		minSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"minSpeed"] floatValue];
		maxVelocity = ccp([[[dictionary objectForKey:@"speedRamp"] objectForKey:@"maxSpeed"] floatValue], [[dictionary objectForKey:@"maxDownwardSpeed"] floatValue]);
		speedIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"incrementPercent"] floatValue];
		chunksToIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"numChunksToIncrement"] intValue];
		maxJumpTime = [[dictionary objectForKey:@"maxJumpTime"] floatValue];
		gravity = [[dictionary objectForKey:@"gravity"] floatValue];
		shootAngle = [[dictionary objectForKey:@"shootAngle"] floatValue];
		tileOffset = [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale;
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkCompleted) name:kChunkCompletedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkWillRemove) name:kChunkWillRemoveNotification object:nil];
		
		// create node to hold all player pieces
		offsetNode = [CCNode new];
		[offsetNode addChild:spriteBatch];
		[self addChild:offsetNode];
	}
	
	return self;
}

- (void) dealloc {
	[offsetNode release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) setupTorso {
	// create and position torso
	torso = [CCSprite new];
	[self setWeaponAngle:0];
	[spriteBatch addChild:torso z:1];
	torso.anchorPoint = ccp(0.5, 1);
	// create and load array of torsoOffsets
	torsoOffsets = [[NSMutableArray alloc] initWithArray:[dictionary objectForKey:@"torsoOffsets"]];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	if(!dead) {
		// keep track of previous position
		prevDummyPosition = dummyPosition;
		
		// apply jump
		if(jumping) {
			jumpTimer += delta;
			if(jumpTimer >= maxJumpTime) {
				jumping = NO;
				[self setState:kPlayerMidJump];
				[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerEndJumpWithoutTouchNotification object:self]];
			}
			velocity = ccp(velocity.x, jumpImpulse);
		}
		// apply gravity
		if(!jumping) {
			velocity = ccp(velocity.x, MAX(velocity.y - gravity, -maxVelocity.y));
		}
		// apply velocity to position
		dummyPosition = ccp(dummyPosition.x + (velocity.x * delta), dummyPosition.y + (velocity.y * delta));
		self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
		
		[self checkCollisions];
		
		// update score
		[ScoreManager sharedSingleton].distance = floor(dummyPosition.x / 64);
		// update torso position
		[self updateTorso];
		
		// check for falling death
		if(dummyPosition.y < [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
			[self die:@"fall"];
		}
		
		// post player update notification
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delta] forKey:@"delta"]]];
	}
}

- (void) updateTorso {
	// see which frame the legs are currently at and position the torso based on that
	for(NSDictionary *d in torsoOffsets) {
		if([sprite isFrameDisplayed:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[d objectForKey:@"imageName"]]]) {
			torso.position = ccp([[[d objectForKey:@"offset"] objectForKey:@"x"] floatValue], [[[d objectForKey:@"offset"] objectForKey:@"y"] floatValue]);
			break;
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
		speed = MIN(speed, maxVelocity.x);
		NSLog(@"Player speed is now %.2f after incrementing", speed);
		velocity = ccp(speed, velocity.y);
	}
	
	[[[ChunkManager sharedSingleton] getCurrentChunk] addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
	[self release];
}

- (void) chunkWillRemove {
	[self retain];
	[[[ChunkManager sharedSingleton] getCurrentChunk] removeChild:self cleanup:NO];
	
	offsetNode.position = ccp(offsetNode.position.x - [[ChunkManager sharedSingleton] getCurrentChunk].dummySize.width, offsetNode.position.y);
}

#pragma mark -
#pragma mark setters
- (void) setState:(PlayerState)newState {
	if(state != newState) {
		//NSLog(@"Changing state from: %i --- to: %i", state, newState);
		switch(newState) {
			case kPlayerRunning:
				[self repeatAnimation:@"run"];
				break;
			case kPlayerBeginJump:
				[self playAnimation:@"beginJump"];
				break;
			case kPlayerMidJump:
				[self playAnimation:@"middleJump"];
				break;
			case kPlayerEndJump:
				[self playAnimation:@"endJump" target:self selector:@selector(endJumpAnimation)];
				break;
			default:
				break;
		}
	}
	prevState = state;
	state = newState;
}

- (void) setWeaponAngle:(int)newAngle {
	if(newAngle > 0) {
		[torso setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"torso_up.png"]];
	}
	else if(newAngle < 0) {
		[torso setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"torso_down.png"]];
	}
	else {
		[torso setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"torso.png"]];
	}
	weapon.angle = newAngle;
}

#pragma mark -
#pragma mark animations
- (void) endJumpAnimation {
	[self setState:kPlayerRunning];
}

#pragma mark -
#pragma mark actions
- (void) reset {
	
	// set initial values
	[self setState:kPlayerRunning];
	[weapon loadFromFile:@"machinegun"];
	[weapon start];
	dummyPosition = ccp(100, 192);
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	offsetNode.position = ccp(0, 0);
	velocity = ccp(minSpeed, 0);
	curNumChunks = 0;
	jumpTimer = 0.0f;
	dead = NO;
	
	// add to current chunk
	[self.parent removeChild:self cleanup:NO];
	[[[ChunkManager sharedSingleton] getCurrentChunk] addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
}

- (void) die:(NSString*)reason {
	
	// stop firing the equipped weapon
	[weapon stop];
	
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
		[self setState:kPlayerBeginJump];
	}
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerJumpNotification object:self]];
}

- (void) endJump {
	[self setState:kPlayerMidJump];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerEndJumpWithTouchNotification object:self]];
	jumping = NO;
}

- (void) shoot:(CGPoint)touchPos {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	// split screen up into halves
	float shootPortion = winSize.height/2.0f;
	// bottom half of screen. player is shooting diagonally down
	if(touchPos.y <= shootPortion) {
		[self setWeaponAngle:-shootAngle];
	}
	// top half of screen. player is shooting diagonally up
	else {
		[self setWeaponAngle:shootAngle];
	}
}

- (void) endShoot {
	[self setWeaponAngle:0];
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
				// if the lowest part of the sprite is less than the middle of the tile
				// set its position so the lowest part of the sprite is at the middle of the tile
				float actualTilePos = tile.position.y * [ResolutionManager sharedSingleton].inversePositionScale;
				if(dummyPosition.y <= actualTilePos + tile.contentSize.height * 0.5 + tileOffset) {
					dummyPosition = ccp(dummyPosition.x, actualTilePos + (tile.contentSize.height * 0.5) + tileOffset);
					touchingPlatform = YES;
					velocity = ccp(velocity.x, 0);
				}
			}
			
			// check for collision top layer
			gid = [[c layerNamed:@"CollisionTop"] tileGIDAt:playerTilePos];
			if(gid) {
				CCSprite *tile = [[c layerNamed:@"CollisionTop"] tileAt:playerTilePos];
				// if the lowest part of the sprite is less than the middle of the tile,
				// the sprite is moving downwards, and previous lowest part of the sprite is greater than the middle of the tile
				float actualTilePos = tile.position.y * [ResolutionManager sharedSingleton].inversePositionScale;
				if(dummyPosition.y <= actualTilePos + (tile.contentSize.height * 0.5) + tileOffset && velocity.y < 0 && prevDummyPosition.y >= actualTilePos + (tile.contentSize.height * 0.5) + tileOffset) {
					dummyPosition = ccp(dummyPosition.x, actualTilePos + (tile.contentSize.height * 0.5) + tileOffset);
					touchingPlatform = YES;
					velocity = ccp(velocity.x, 0);
				}
			}
			
			// check for collision bottom layer
			gid = [[c layerNamed:@"CollisionBottom"] tileGIDAt:playerTilePos];
			if(gid) {
				CCSprite *tile = [[c layerNamed:@"CollisionBottom"] tileAt:playerTilePos];
				// if the highest part of the sprite is greater than the lowest part of the tile,
				// the sprite is moving upwards, and the previous highest part of the sprite is less than the lowest part of the tile
				float actualTilePos = tile.position.y * [ResolutionManager sharedSingleton].inversePositionScale;
				if(dummyPosition.y >= actualTilePos + tileOffset && velocity.y > 0 && prevDummyPosition.y <= actualTilePos) {
					dummyPosition = ccp(dummyPosition.x, actualTilePos + tileOffset);
					velocity = ccp(velocity.x, 0);
					jumping = NO;
				}
			}
		}
	}
	
	if(touchingPlatform) {
		if(state != kPlayerRunning) {
			[self setState:kPlayerEndJump];
		}
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerCollidePlatformNotification object:self]];
	}
	else {
		if(state == kPlayerRunning) {
			[self setState:kPlayerMidJump];
		}
	}
}

#pragma mark -
#pragma mark convenience functions
- (CGPoint) positionInChunk:(Chunk*)chunk {
	return ccp(floor((dummyPosition.x - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor(dummyPosition.y / chunk.tileSize.height) - 1);
}

- (NSSet*) positionsInChunk:(Chunk*)chunk {
	
	NSMutableSet *positions = [NSMutableSet set];
	// top left corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((dummyPosition.x - (offsetNode.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((dummyPosition.y + (offsetNode.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	// top right corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((dummyPosition.x + (offsetNode.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((dummyPosition.y + (offsetNode.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	// bottom left corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((dummyPosition.x - (offsetNode.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((dummyPosition.y - (offsetNode.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	// bottom right corner of sprite
	[positions addObject:[NSValue valueWithCGPoint:ccp(floor((dummyPosition.x + (offsetNode.contentSize.width * 0.5) - chunk.startPosition) / chunk.tileSize.width), chunk.mapSize.height - floor((dummyPosition.y - (offsetNode.contentSize.height * 0.5)) / chunk.tileSize.height) - 1)]];
	
	return positions;
}

@end
