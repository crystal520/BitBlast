//
//  BBPlayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPlayer.h"

@implementation BBPlayer

@synthesize health;

- (id) init {
	if((self = [super initWithFile:@"playerProperties"])) {
		
		// make sure to clamp velocity
		clampVelocity = YES;
		
		[self loadAnimations];
		self.sprite.anchorPoint = ccp(0.5, 0);
		[self setState:kPlayerUnknown];
		
		// setup torso
		[self setupTorso];
		
		// load values from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue];
		minVelocity = ccp([[[dictionary objectForKey:@"speedRamp"] objectForKey:@"minSpeed"] floatValue], -[[dictionary objectForKey:@"maxDownwardSpeed"] floatValue]);
		maxVelocity = ccp([[[dictionary objectForKey:@"speedRamp"] objectForKey:@"maxSpeed"] floatValue], [[dictionary objectForKey:@"maxDownwardSpeed"] floatValue]);
		speedIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"incrementPercent"] floatValue];
		chunksToIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"numChunksToIncrement"] intValue];
		maxJumpTime = [[dictionary objectForKey:@"maxJumpTime"] floatValue];
		gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
		tileOffset = ccp(0, [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale);
		
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
	[torsoOffsets release];
	[torso release];
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
	
	if(state != kPlayerDead && state != kPlayerIntro) {
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
		[super update:delta];
		
		// check collisions
		[self checkCollisions];
		// update globals
		[self updateGlobals];
		// update score
		[[SettingsManager sharedSingleton] setInteger:floor(dummyPosition.x / [[ChunkManager sharedSingleton] getCurrentChunk].tileSize.width) keyString:@"currentMeters"];
		[[SettingsManager sharedSingleton] setInteger:previousTotalDistance + [[SettingsManager sharedSingleton] getInt:@"currentMeters"] keyString:@"totalMeters"];
		// update torso position
		[self updateTorso];
		// update weapons
		[self updateWeapons:delta];
		
		// check for falling death
		if(dummyPosition.y + sprite.contentSize.height + torso.contentSize.height < [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
			[self die:@"fall"];
		}
		
		// post player update notification
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delta] forKey:@"delta"]]];
	}
	else if(state == kPlayerIntro) {
		[super update:delta];
		// update torso position
		[self updateTorso];
	}
}

- (void) updateTorso {
	// see which frame the legs are currently at and position the torso based on that
	for(NSDictionary *d in torsoOffsets) {
		if([sprite isFrameDisplayed:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[d objectForKey:@"imageName"]]]) {
			torso.position = ccp([[[d objectForKey:@"offset"] objectForKey:@"x"] floatValue] * [ResolutionManager sharedSingleton].positionScale, [[[d objectForKey:@"offset"] objectForKey:@"y"] floatValue] * [ResolutionManager sharedSingleton].positionScale);
			break;
		}
	}
}

- (void) updateWeapons:(float)delta {
	// loop through weapons and update them
	for(BBWeapon *w in [BBWeaponManager sharedSingleton].weapons) {
		[w setPlayerSpeed:velocity.x];
		[w setPosition:ccpAdd(dummyPosition, ccpMult(torso.position, [ResolutionManager sharedSingleton].inversePositionScale))];
		[w update:delta];
	}
}

- (void) updateGlobals {
	// update global variables so other classes can use them
	[Globals sharedSingleton].playerPosition = dummyPosition;
	[Globals sharedSingleton].playerVelocity = velocity;
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
		velocity = ccp(speed, velocity.y);
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerLevelIncreaseNotification object:nil]];
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
			case kPlayerDead:
				// disable weapons
				[[BBWeaponManager sharedSingleton] setEnabled:NO];
				[self stopAllActions];
				break;
			case kPlayerIntro:
				break;
			default:
				break;
		}
	}
	prevState = state;
	state = newState;
}

- (void) setWeaponAngle:(int)newAngle {
	BOOL laserEquipped = NO;
	// update weapons with new angle
	for(BBWeapon *w in [BBWeaponManager sharedSingleton].weapons) {
		if([w.identifier isEqualToString:@"ultraLaser"]) {
			laserEquipped = YES;
			newAngle = 0;
		}
		[w setAngle:newAngle];
	}
	// update torso image based on new angle
	if(newAngle > 0) {
		[torso setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"torso_up.png"]];
	}
	else if(newAngle < 0) {
		[torso setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"torso_down.png"]];
	}
	else {
		[torso setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"torso.png"]];
	}
}

- (void) setHealth:(int)newHealth {
	health = newHealth;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerHealthNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:health] forKey:@"health"]]];
}

#pragma mark -
#pragma mark animations
- (void) endJumpAnimation {
	[self setState:kPlayerRunning];
}

#pragma mark -
#pragma mark actions
- (void) playIntro {
	[self setState:kPlayerIntro];
	
	// player is unaffected by gravity during the intro
	gravity = ccp(0, 0);
	velocity = ccp(500, 0);
	
	// set these so we can jump out of the chopper
	needsPlatformCollisions = NO;
	touchingPlatform = YES;
	
	dummyPosition = ccp(-150, 500);
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	offsetNode.position = ccp(0, 0);
	
	// add to current chunk
	[self.parent removeChild:self cleanup:NO];
	[[[ChunkManager sharedSingleton] getCurrentChunk] addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
	
	// set the legs to the first frame of the run animation
	CCAnimation *runAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"run"];
	[sprite setDisplayFrame:[runAnim.frames objectAtIndex:[runAnim.frames count]-1]];
	if(sprite.parent) {
		[sprite.parent removeChild:sprite cleanup:YES];
	}
	[spriteBatch addChild:sprite];
	
	// jump out of the chopper after a certain amount of time
	CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(jumpOutOfChopper)], nil];
	[self runAction:action];
}

- (void) jumpOutOfChopper {
	velocity = minVelocity;
	// re-enable gravity
	gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
	needsPlatformCollisions = YES;
	[self jump];
	// end the jump after a given amount of time
	CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:0.25], [CCCallFunc actionWithTarget:self selector:@selector(endJump)], nil];
	[self runAction:action];
	// switch to game mode after a second
	action = [CCSequence actions:[CCDelayTime actionWithDuration:1.25], [CCCallFunc actionWithTarget:self selector:@selector(gameOn)], nil];
	[self runAction:action];
}

- (void) gameOn {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerOutOfChopperNotification object:nil]];
	
	// enable weapons
	[[BBWeaponManager sharedSingleton] setEnabled:YES];
}

- (void) checkCollisions {
	// check to see if player is colliding with any coins
	NSArray *activeCoins = [[BBCoinManager sharedSingleton] getActiveCoins];
	for(BBCoin *c in activeCoins) {
		if(c.enabled && c.alive && [c getCollidesWith:self]) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
			[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentCoins"];
			[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalCoins"];
			[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"allTimeCoins"];
			[c setEnabled:NO];
		}
	}
	// check to see if player is colliding with any enemies
	NSArray *activeEnemies = [[EnemyManager sharedSingleton] getActiveEnemies];
	for(BBEnemy *e in activeEnemies) {
		if([e getCollidesWith:self]) {
			// flash player red so they know why they lost health
			CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
			[self.sprite runAction:action];
			[torso runAction:action];
			// update health
			[self setHealth:health-1];
			// kill the enemy
			[e die];
			if(health <= 0) {
				[self die:@"enemy"];
				break;
			}
		}
	}
}

- (void) reset {
	// set initial values
	offsetNode.position = ccp(0, 0);
	curNumChunks = 0;
	jumpTimer = 0.0f;
	// reset health to starting value from plist
	[self setHealth:[[dictionary objectForKey:@"health"] intValue]];
	// keep track of previous total distance
	previousTotalDistance = [[SettingsManager sharedSingleton] getInt:@"totalMeters"];
	[self playIntro];
}

- (void) die:(NSString*)reason {
	[self setState:kPlayerDead];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerDeadNotification object:nil]];
}

- (void) jump {
	
	// only jump if we're not jumping already
	if(touchingPlatform) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"jump.wav"];
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
		[self setWeaponAngle:-1];
	}
	// top half of screen. player is shooting diagonally up
	else {
		[self setWeaponAngle:1];
	}
}

- (void) endShoot {
	[self setWeaponAngle:0];
}

- (void) checkPlatformCollisions {
	[super checkPlatformCollisions];
	
	// set state based on whether or not player is touching a platform
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

@end
