//
//  BBPlayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPlayer.h"

@implementation BBPlayer

@synthesize health, doubleJumpEnabled;

- (id) init {
	if((self = [super initWithFile:@"playerProperties"])) {
		
		// make sure to clamp velocity
		clampVelocity = YES;
		// this will be enabled in playIntro
		introEnabled = NO;
		self.anchorPoint = ccp(0.5, 0);
		
		// setup torso
		[self setupLegs];
		[self setupTorso];
		
		legs.anchorPoint = ccp(0.5, 0);
		[self setState:kPlayerUnknown];
		
		// load values from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale;
		minVelocity = ccp([[[dictionary objectForKey:@"speedRamp"] objectForKey:@"minSpeed"] floatValue], -[[dictionary objectForKey:@"maxDownwardSpeed"] floatValue]);
		maxVelocity = ccp([[[dictionary objectForKey:@"speedRamp"] objectForKey:@"maxSpeed"] floatValue], [[dictionary objectForKey:@"maxDownwardSpeed"] floatValue]);
		speedIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"incrementPercent"] floatValue];
		chunksToIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"numChunksToIncrement"] intValue];
		maxJumpTime = [[dictionary objectForKey:@"maxJumpTime"] floatValue];
		gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
        initialGravity = gravity;
		tileOffset = ccp(0, [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale);
		invincibleTime = [[dictionary objectForKey:@"invincibleTimeAfterLosingHealth"] floatValue];
        startingHealth = [[dictionary objectForKey:@"health"] intValue];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkCompleted) name:kChunkCompletedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		
		// add legs and torso to player
		[self addChild:legs];
		[self addChild:torso];
        [self loadComplete];
	}
	
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[torsoOffsets release];
	[torso release];
	[legs release];
    [torsoShape destroyBody];
    [torsoShape release];
    [legsShape destroyBody];
    [legsShape release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) setupTorso {
	// create and position torso
	torso = [CCSprite new];
	[self setWeaponAngle:0];
	torso.anchorPoint = ccp(0.5, 1);
	// create and load array of torsoOffsets
	torsoOffsets = [[NSMutableArray alloc] initWithArray:[dictionary objectForKey:@"torsoOffsets"]];
    // create collision shape for torso
    torsoShape = [[BBPlayerShape alloc] initWithDynamicBody:@"torso" node:torso];
}

- (void) setupLegs {
	// create and position legs
	legs = [[BBGameObject alloc] init];
    // create collision shape for legs
    legsShape = [[BBPlayerShape alloc] initWithDynamicBody:@"run1" node:legs];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	if(state != kPlayerDead && !introEnabled && state != kPlayerShop) {
        BOOL prevTouchingPlatform = touchingPlatform;
		// apply jump
		if(jumping) {
			jumpTimer += delta;
			if(jumpTimer >= maxJumpTime) {
				jumping = NO;
                doubleJumpEnabled = NO;
				[self setState:kPlayerMidJump];
				[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerEndJumpWithoutTouchNotification object:self]];
			}
			velocity = ccp(velocity.x, jumpImpulse);
		}
        else if(touchingPlatform) {
            fellOffPlatform = NO;
        }
		[super update:delta];
		
        // if player is no longer touching a platform and isn't jumping, then they fell!
        if(!touchingPlatform && prevTouchingPlatform && !jumping && !fellOffPlatform) {
            fellOffPlatform = YES;
        }
        
        // if player is invincible, count down the timer
        if(invincible) {
            invincibleTimer -= delta;
            if(invincibleTimer <= 0) {
                invincible = NO;
            }
        }
        
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
		if(dummyPosition.y + legs.contentSize.height + torso.contentSize.height < [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
			[self die:kDeathFall];
		}
		
		// post player update notification
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerUpdateNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delta] forKey:@"delta"]]];
	}
	else if(state == kPlayerShop) {
		// update torso position and graphic
		[self updateTorso];
		// update weapons
		[self updateWeapons:delta];
	}
	else if(introEnabled) {
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
		// update torso position
		[self updateTorso];
		if(touchingPlatform) {
			velocity = ccp(minVelocity.x * speedMultiplier, minVelocity.y);
			introEnabled = NO;
			[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerOutOfChopperNotification object:nil]];
			[[BBWeaponManager sharedSingleton] setEnabled:YES forType:WEAPON_INVENTORY_PLAYER];
		}
	}
}

- (void) updateTorso {
	// see which frame the legs are currently at and position the torso based on that
	for(NSDictionary *d in torsoOffsets) {
		if([legs isFrameDisplayed:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[d objectForKey:@"imageName"]]]) {
			torso.position = ccp([[[d objectForKey:@"offset"] objectForKey:@"x"] floatValue] * [ResolutionManager sharedSingleton].positionScale, [[[d objectForKey:@"offset"] objectForKey:@"y"] floatValue] * [ResolutionManager sharedSingleton].positionScale);
			break;
		}
	}
}

- (void) updateWeapons:(float)delta {
	// loop through weapons and update them
	for(BBWeapon *w in [[BBWeaponManager sharedSingleton] weaponsForType:WEAPON_INVENTORY_PLAYER]) {
		[w setPlayerSpeed:velocity.x];
		[w setPosition:ccpAdd(dummyPosition, ccpMult(torso.position, [ResolutionManager sharedSingleton].inversePositionScale * self.scale))];
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
		float speed = velocity.x + speedIncrement * velocity.x * speedMultiplier;
		// make sure we don't go over the maximum speed allowed
		speed = MIN(speed, maxVelocity.x);
		velocity = ccp(speed, velocity.y);
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerLevelIncreaseNotification object:nil]];
	}
}

- (void) pause {
	[self pauseSchedulerAndActions];
	[legs pauseSchedulerAndActions];
}

- (void) resume {
	[self resumeSchedulerAndActions];
	[legs resumeSchedulerAndActions];
}

#pragma mark -
#pragma mark setters
- (void) setState:(PlayerState)newState {
	if(state != newState) {
		//NSLog(@"Changing state from: %i --- to: %i", state, newState);
		switch(newState) {
			case kPlayerRunning:
				[legs repeatAnimation:@"playerRun"];
				break;
			case kPlayerBeginJump:
				[legs playAnimation:@"playerBeginJump"];
				break;
			case kPlayerMidJump:
				[legs playAnimation:@"playerMiddleJump"];
				break;
			case kPlayerEndJump:
				[legs playAnimation:@"playerEndJump" target:self selector:@selector(endJumpAnimation)];
				break;
			case kPlayerShop:
				[legs repeatAnimation:@"playerRun"];
				break;
			case kPlayerDead:
				[torso stopAllActions];
				[legs stopAllActions];
				break;
			default:
				break;
		}
	}
	prevState = state;
	state = newState;
}

- (void) setWeaponAngle:(int)newAngle {
	// update weapons with new angle
	for(BBWeapon *w in [[BBWeaponManager sharedSingleton] weaponsForType:WEAPON_INVENTORY_PLAYER]) {
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
- (void) addCoins:(int)coins {
	[[SettingsManager sharedSingleton] incrementInteger:coins * coinMultiplier keyString:@"currentCoins"];
	[[SettingsManager sharedSingleton] incrementInteger:coins * coinMultiplier keyString:@"totalCoins"];
	[[SettingsManager sharedSingleton] incrementInteger:coins * coinMultiplier keyString:@"allTimeCoins"];
	[[SettingsManager sharedSingleton] incrementInteger:coins * coinMultiplier keyString:@"dailyCoins"];
}

- (void) addKeys:(int)keys {
    [[SettingsManager sharedSingleton] incrementInteger:keys keyString:@"totalKeys"];
    [[SettingsManager sharedSingleton] incrementInteger:keys keyString:@"allTimeKeys"];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerKeyNotification object:nil]];
}

- (void) addTriforce:(int)triforce {
    [[SettingsManager sharedSingleton] incrementInteger:triforce keyString:@"totalTriforce"];
    [[SettingsManager sharedSingleton] incrementInteger:triforce keyString:@"allTimeTriforce"];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerTriforceNotification object:nil]];
}

- (void) playIntro {
	[[BBWeaponManager sharedSingleton] setEnabled:NO forType:WEAPON_INVENTORY_PLAYER];
	introEnabled = YES;
	
	// player is unaffected by gravity during the intro
	gravity = ccp(0, 0);
	velocity = ccp(600, 0);
	
	// set this so we can jump out of the chopper
	needsPlatformCollisions = NO;
	touchingPlatform = NO;
	
	dummyPosition = ccp(-150, 500);
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	
	// set the legs to the first frame of the run animation
	CCAnimation *runAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"playerRun"];
	[legs setDisplayFrame:[runAnim.frames objectAtIndex:[runAnim.frames count]-1]];
	
	// jump out of the chopper after a certain amount of time
	CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(jumpOutOfChopper)], nil];
	[self runAction:action];
}

- (void) jumpOutOfChopper {
	velocity = minVelocity;
	// re-enable gravity
	gravity = initialGravity;
	needsPlatformCollisions = YES;
	[self jump];
	// end the jump after a given amount of time
	CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:0.25], [CCCallFunc actionWithTarget:self selector:@selector(endJump)], nil];
	[self runAction:action];
}

- (void) reset {
	// set initial values
	curNumChunks = 0;
	jumpTimer = 0.0f;
    jumping = NO;
    [self setWeaponAngle:0];
    [legs setColor:ccc3(255, 255, 255)];
    [torso setColor:ccc3(255, 255, 255)];
	
	// get current coin multiplier powerup
	coinMultiplier = [[BBPowerupManager sharedSingleton] getCoinMultPowerup];
	// get current speed multiplier powerup
	speedMultiplier = [[BBPowerupManager sharedSingleton] getSpeedPowerup];
	// set the current gun multiplier powerup
	[[BBWeaponManager sharedSingleton] setGunSpeedMultiplier:[[BBPowerupManager sharedSingleton] getGunPowerup] forType:WEAPON_INVENTORY_PLAYER];
	
	// reset health to starting value from plist
	[self setHealth:startingHealth + [[BBPowerupManager sharedSingleton] getHealthPowerup]];
	[Globals sharedSingleton].playerStartingHealth = health;
	// keep track of previous total distance
	previousTotalDistance = [[SettingsManager sharedSingleton] getInt:@"totalMeters"];
	[self playIntro];
}

- (void) die:(ReasonForDeath)reason {
    [Globals sharedSingleton].playerReasonForDeath = reason;
	[self setState:kPlayerDead];
	[[SettingsManager sharedSingleton] incrementInteger:[[SettingsManager sharedSingleton] getInt:@"currentDistance"] keyString:@"dailyDistance"];
	
	// reset the gun speed multiplier
	[[BBWeaponManager sharedSingleton] setGunSpeedMultiplier:1 forType:WEAPON_INVENTORY_PLAYER];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerDeadNotification object:nil]];
}

- (void) jump {
	
	// only jump if we're not jumping already
	if(touchingPlatform || introEnabled || fellOffPlatform || doubleJumpEnabled) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"jump.wav"];
		touchingPlatform = NO;
        doubleJumpEnabled = NO;
        fellOffPlatform = NO;
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

- (void) jumpDown {
    // make sure the player is touching a platform before adjusting their position
    if(touchingPlatform && [[[ChunkManager sharedSingleton] getCurrentChunk] isPlatformBelowPosition:ccpSub(self.position, [[ChunkManager sharedSingleton] getCurrentChunk].position)]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"jumpDown.wav"];
        dummyPosition.y -= 10;
    }
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

- (void) attemptToLoseHealth {
    // check to see if player is invincible
    if(!invincible) {
        // flash player so they know they lost health
        [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:invincibleTime numberOfTimes:8 onSprite:torso];
        [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:invincibleTime numberOfTimes:8 onSprite:legs];
        // update health
        [self setHealth:health-1];
        // player is invincible
        invincible = YES;
        invincibleTimer = invincibleTime;
    }
}

#pragma mark -
#pragma mark collisions
- (void) checkPlatformCollisions:(float)delta {
    BOOL prevTouchingPlatform = touchingPlatform;
	[super checkPlatformCollisions:delta];
	
    // play a sound when player collides with the ground
    if(!prevTouchingPlatform && touchingPlatform) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"land.wav" pitch:1.0 pan:0.0 gain:2.0];
    }
    
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

- (void) collideWithCoin:(BBCoin*)coin {
    // sanity check to make sure the coin is enabled
    if(coin.enabled) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
        [self addCoins:1];
        [coin setEnabled:NO];
    }
}

- (void) collideWithMovingCoin:(BBMovingCoin*)coin {
    // sanity check to make sure the coin is enabled
    if(coin.enabled) {
        if(coin.type == MOVING_COIN_TYPE_COIN) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav"];
            [self addCoins:1];
            [coin setEnabled:NO];
        }
        else if(coin.type == MOVING_COIN_TYPE_KEY) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"key.wav"];
            [self addKeys:1];
            [coin setEnabled:NO];
        }
        else {
            [[SimpleAudioEngine sharedEngine] playEffect:@"triforce.wav"];
            [self addTriforce:1];
            [coin setEnabled:NO];
        }
    }
}

- (void) collideWithEnemy:(BBEnemy*)enemy {
    // sanity check to make sure the enemy is enabled
    if(enemy.enabled && enemy.alive) {
        [self attemptToLoseHealth];
        // kill the enemy
        [enemy die];
        if(health <= 0) {
            [self die:kDeathEnemy];
        }
    }
}

- (void) collideWithMiniboss:(BBMiniboss*)miniboss {
    // make sure miniboss is enabled and alive
    if(miniboss.alive && miniboss.enabled) {
        [self attemptToLoseHealth];
        if(health <= 0) {
            [self die:kDeathMiniboss];
        }
    }
}

- (void) hitByBullet:(BBBullet*)bullet {
    if(bullet.enabled && health > 0) {
        [self attemptToLoseHealth];
        
        // disable the bullet
        [bullet setEnabled:NO];
        
        if(health <= 0) {
            [self die:kDeathEnemy];
        }
    }
}

@end

@implementation BBPlayerShape

- (void) postsolveContactWithBBCoinShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBPlayer*)(self.ccNode.parent) collideWithCoin:(BBCoin*)(contact.otherObject.ccNode)];
}

- (void) postsolveContactWithBBMovingCoinShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBPlayer*)(self.ccNode.parent) collideWithMovingCoin:(BBMovingCoin*)(contact.otherObject.ccNode)];
}

- (void) postsolveContactWithBBEnemyShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBPlayer*)(self.ccNode.parent) collideWithEnemy:(BBEnemy*)(contact.otherObject.ccNode)];
}

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    BBBullet *bullet = (BBBullet*)(contact.otherObject.ccNode);
    // only collide with the bullet if it's coming from an enemy
    if(bullet.type == kBulletTypeEnemyShot || bullet.type == kBulletTypeEnemyLaser) {
        contact.box2dContact->SetEnabled(NO);
        [(BBPlayer*)(self.ccNode.parent) hitByBullet:(BBBullet*)(contact.otherObject.ccNode)];
    }
}

- (void) postsolveContactWithBBMinibossShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBPlayer*)(self.ccNode.parent) collideWithMiniboss:(BBMiniboss*)(contact.otherObject.ccNode)];
}
     
@end
