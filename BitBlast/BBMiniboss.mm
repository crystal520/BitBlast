//
//  BBMiniboss.m
//  GunRunner
//
//  Created by Kristian Bauer on 7/18/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMiniboss.h"

@implementation BBMiniboss

@synthesize enabled, alive, explosionManager, level, switchNode, currentAIStage;

- (id) init {
	if((self = [super init])) {
        state = MINIBOSS_STATE_UNKNOWN;
		[self setEnabled:NO];
		alive = YES;
		needsPlatformCollisions = NO;
        chargeInfo = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc {
    [particles release];
    [chargeInfo release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	
	// check for particle system
	if(particles) {
		[particles release];
	}
	if([dictionary objectForKey:@"particles"]) {
		particles = [[dictionary objectForKey:@"particles"] retain];
	}
	
	// set values from dictionary
	health = [[dictionary objectForKey:@"health"] floatValue];
    initialHealth = health;
	coins = [[dictionary objectForKey:@"coins"] intValue];
	[self repeatAnimation:[dictionary objectForKey:@"animation"]];
    
    // check for collision shape
    [self setCollisionShape:[dictionary objectForKey:@"collisionShape"]];
	
	// reset variables
	self.rotation = 0;
	gravity = ccp(0, 0);
	velocity = ccp(0, 0);
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if enabled
	if(enabled) {
        [super update:delta];
		if(state == MINIBOSS_STATE_MOVE_RIGHT) {
			
			CGPoint shipScreenPos = [self convertToWorldSpace:CGPointZero];
			if(shipScreenPos.x - self.contentSize.width * [ResolutionManager sharedSingleton].imageScale > [CCDirector sharedDirector].winSize.width) {
				velocity = ccp([Globals sharedSingleton].playerVelocity.x - 200, 0);
				self.scale = 1;
				self.scaleX = -1;
				state = MINIBOSS_STATE_MOVE_LEFT;
			}
		}
		else if(state == MINIBOSS_STATE_MOVE_LEFT) {
			
			if(dummyPosition.x < [Globals sharedSingleton].playerPosition.x + finalPos.x) {
				state = MINIBOSS_STATE_ACTIVE;
				alive = YES;
                [collisionShape setActive:YES];
                [self removeFromParentAndCleanup:NO];
                [switchNode addChild:self];
                // trigger AI loops
                self.currentAIStage = 0;
			}
		}
        else {
            lastBulletHit = nil;
			// get velocity from player
			if(alive && state == MINIBOSS_STATE_ACTIVE) {
				velocity = ccp([Globals sharedSingleton].playerVelocity.x, 0);
			}
            // see if miniboss should advance to next stage of charge sequence
            if(alive && state == MINIBOSS_STATE_CHARGE_LEFT) {
                if(dummyPosition.x < [Globals sharedSingleton].playerPosition.x) {
                    [self charge];
                }
            }
            if(alive && state == MINIBOSS_STATE_CHARGE_RIGHT) {
                if(dummyPosition.x > [Globals sharedSingleton].playerPosition.x + finalPos.x) {
                    [self charge];
                }
            }
			[self checkDeath];
            if(alive) {
                [self updateWeapons:delta];
            }
        }
	}
}

- (void) updateWeapons:(float)delta {
	// loop through weapons and update them
	for(BBWeapon *w in [[BBWeaponManager sharedSingleton] weaponsForType:WEAPON_INVENTORY_MINIBOSS]) {
		[w setPlayerSpeed:velocity.x];
		[w setPosition:dummyPosition];
		[w update:delta];
	}
}

- (void) checkDeath {
    // if miniboss is dead and goes off screen, actually kill it
    if(!alive) {
        if(dummyPosition.y + self.contentSize.height * 0.5 < 0) {
            [self setEnabled:NO];
            [explosionManager stopExploding:self];
            [[BBWeaponManager sharedSingleton] unequipAllForType:WEAPON_INVENTORY_MINIBOSS];
        }
    }
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
        [[BBWeaponManager sharedSingleton] unequipAllForType:WEAPON_INVENTORY_MINIBOSS];
		self.visible = NO;
		alive = NO;
        [collisionShape setActive:NO];
        [self stopAllActions];
	}
	else if(!enabled && newEnabled) {
		self.visible = YES;
		alive = YES;
        [self hover];
	}
	enabled = newEnabled;
}

- (void) setCollisionShape:(NSString *)shapeName {
    if(collisionShape) {
        if(![collisionShape.shapeString isEqualToString:shapeName]) {
            [collisionShape destroyBody];
            [collisionShape release];
            collisionShape = [[BBMinibossShape alloc] initWithDynamicBody:shapeName node:self];
            [collisionShape setActive:NO];
        }
    }
    else {
        collisionShape = [[BBMinibossShape alloc] initWithDynamicBody:shapeName node:self];
        [collisionShape setActive:NO];
    }
}

- (void) setCurrentAIStage:(int)newCurrentAIStage {
    currentAIStage = newCurrentAIStage;
    
    // then start running actions for current stage
    NSArray *actions = [[self getAIStage] objectForKey:@"actions"];
    for(NSDictionary *d in actions) {
        // determine what to do based on type
        NSString *type = [d objectForKey:@"type"];
        if([type isEqualToString:@"dropEnemy"]) {
            [self stopActionByTag:MINIBOSS_ACTION_TAG_CALL_SPAWN_ENEMY];
            CCSequence *spawnEnemySequence = [CCSequence actions:[CCDelayTime actionWithDuration:0.1], [CCCallFuncO actionWithTarget:self selector:@selector(spawnEnemy:) object:d], nil];
            spawnEnemySequence.tag = MINIBOSS_ACTION_TAG_CALL_SPAWN_ENEMY;
            [self runAction:spawnEnemySequence];
        }
        else if([type isEqualToString:@"chase"]) {
            [self stopActionByTag:MINIBOSS_ACTION_TAG_CALL_CHASE];
            CCSequence *chaseSequence = [CCSequence actions:[CCDelayTime actionWithDuration:0.1], [CCCallFuncO actionWithTarget:self selector:@selector(chase:) object:d], nil];
            chaseSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHASE;
            [self runAction:chaseSequence];
        }
        else if([type isEqualToString:@"shoot"]) {
            [self stopActionByTag:MINIBOSS_ACTION_TAG_CALL_CHANGE_WEAPON];
            CCSequence *changeWeaponSequence = [CCSequence actions:[CCDelayTime actionWithDuration:0.1], [CCCallFuncO actionWithTarget:self selector:@selector(changeWeapon:) object:d], nil];
            changeWeaponSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHANGE_WEAPON;
            [self runAction:changeWeaponSequence];
        }
        else if([type isEqualToString:@"charge"]) {
            [chargeInfo setDictionary:d];
            [self stopActionByTag:MINIBOSS_ACTION_TAG_CALL_CHARGE];
            CCSequence *chargeSequence = [CCSequence actions:[CCDelayTime actionWithDuration:0.1], [CCCallFunc actionWithTarget:self selector:@selector(charge)], nil];
            chargeSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHARGE;
            [self runAction:chargeSequence];
        }
    }
}

#pragma mark -
#pragma mark getters
- (CGPoint) getLevelOffset:(ChunkLevel)chunkLevel {
    if(chunkLevel == CHUNK_LEVEL_BOTTOM) {
		return CGPointFromString([dictionary objectForKey:@"offsetBottom"]);
	}
	else if(chunkLevel == CHUNK_LEVEL_TOP) {
		return CGPointFromString([dictionary objectForKey:@"offsetTop"]);
	}
	else {
		return CGPointFromString([dictionary objectForKey:@"offsetMiddle"]);
	}
}

- (NSDictionary*) getAIStage {
    return [[dictionary objectForKey:@"aiStages"] objectAtIndex:currentAIStage];
}

#pragma mark -
#pragma mark actions
- (void) hitByBullet:(BBBullet*)bullet {
    if(bullet.enabled && bullet != lastBulletHit) {
        
        // play particles where miniboss was hit
        if(particles) {
            CCParticleSystemQuad *hitParticles = [CCParticleSystemQuad particleWithFile:particles];
            hitParticles.autoRemoveOnFinish = YES;
            
            if(bullet.type == kBulletTypeLaser) {
                [self addChild:hitParticles];
                hitParticles.position = ccp(CCRANDOM_MIN_MAX(0, self.contentSize.width), CCRANDOM_MIN_MAX(0, self.contentSize.height));
            }
            else {
                [self.parent addChild:hitParticles];
                hitParticles.position = bullet.position;
            }
        }
        
        if(health > 0) {
            health -= bullet.damage;
            // if the miniboss died, turn off all movement and play death animation
            if(health <= 0) {
                // clear miniboss keys
                [[SettingsManager sharedSingleton] setInteger:0 keyString:@"totalKeys"];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerKeyNotification object:nil]];
                [self stopActionByTag:ACTION_TAG_FLASH];
                [self setColor:ccc3(255, 255, 255)];
                [self die];
                [explosionManager explodeInObject:self number:5];
            }
            else {
                // check to see if miniboss should advance to next ai stage
                NSDictionary *aiStage = [self getAIStage];
                if(health < initialHealth - [[aiStage objectForKey:@"health"] floatValue] * initialHealth) {
                    self.currentAIStage++;
                }
                // play sound for miniboss getting hit by bullet
                if([[self getActionByTag:ACTION_TAG_FLASH] isDone] || ![self getActionByTag:ACTION_TAG_FLASH]) {
                    [[SimpleAudioEngine sharedEngine] playEffect:[[dictionary objectForKey:@"sounds"] objectForKey:@"hit"]];
                }
                [self showHealth];
            }
        }
        // only disable if the bullet is a shot (lasers go through everything!)
        if(bullet.type == kBulletTypeShot) {
            [bullet setEnabled:NO];
        }
        // keep track of the last bullet that hit this miniboss (for laser penetration)
        lastBulletHit = bullet;
    }
}

- (void) die {
	[[BBMovingCoinManager sharedSingleton] spawnTriforceAtPosition:dummyPosition];
	[[SimpleAudioEngine sharedEngine] playEffect:[[dictionary objectForKey:@"sounds"] objectForKey:@"death"]];
	// increment minibosses killed
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalMinibosses"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentMinibosses"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"dailyMinibosses"];
	alive = NO;
	gravity = ccp(2, 5);
	// turn towards the ground and crash!
	[self runAction:[CCRotateTo actionWithDuration:1 angle:-15]];
}

- (void) hover {
    // make miniboss hover
    float hoverTime = CCRANDOM_MIN_MAX(0.35, 0.45);
    CCActionInterval *hoverUp = [CCEaseInOut actionWithAction:[BBMoveBy actionWithDuration:hoverTime position:ccp(0, CCRANDOM_MIN_MAX(0.15, 0.25))]];
    CCActionInterval *hoverDown = [CCEaseInOut actionWithAction:[BBMoveBy actionWithDuration:hoverTime position:ccp(0, CCRANDOM_MIN_MAX(-0.25, -0.15))]];
    CCAction *finalHover = [CCRepeatForever actionWithAction:[CCSequence actions:hoverUp, hoverDown, nil]];
    finalHover.tag = MINIBOSS_ACTION_TAG_HOVER;
    [self runAction:finalHover];
}

- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel {
	[self loadFromFile:type];
	state = MINIBOSS_STATE_MOVE_RIGHT;
	
	// determine offset based on level type
	CGPoint levelOffset = [self getLevelOffset:newLevel];
	
	// make miniboss huge
	self.scale = 2;
	// save final position for later
	finalPos = ccpAdd(newPosition, levelOffset);
	// set velocity to more than the player so it flies past him
	velocity = ccp([Globals sharedSingleton].playerVelocity.x + 2000, 0);
	// start miniboss off screen, to the left of the player
	dummyPosition = ccpAdd(ccpAdd(newPosition, ccp(-800, 0)), levelOffset);
	dummyPosition.x = dummyPosition.x + [Globals sharedSingleton].playerPosition.x;
	[self setEnabled:YES];
	// make sure it can't get hit by bullets yet
	alive = NO;
}

- (void) spawnEnemy:(NSDictionary*)enemyInfo {
	if(alive && enabled) {
        // get array of possible enemies
        NSArray *enemies = [enemyInfo objectForKey:@"enemyTypes"];
        NSDictionary *ranEnemy = [BBGameObject randomDictionaryFromArray:enemies];
		// get recycled enemy
		BBEnemy *newEnemy = [[BBEnemyManager sharedSingleton] getRecycledEnemy];
		// reset with position of miniboss and random enemy type
		[newEnemy resetWithPosition:dummyPosition withType:[ranEnemy objectForKey:@"type"]];
        
        // spawn enemy after random amount of time
        CGPoint spawnEnemyFrequency = CGPointFromString([enemyInfo objectForKey:@"frequency"]);
        CCSequence *spawnSequence = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_MIN_MAX(spawnEnemyFrequency.x, spawnEnemyFrequency.y)], [CCCallFuncO actionWithTarget:self selector:@selector(spawnEnemy:) object:enemyInfo], nil];
        spawnSequence.tag = MINIBOSS_ACTION_TAG_CALL_SPAWN_ENEMY;
        [self runAction:spawnSequence];
	}
}

- (void) chase:(NSDictionary*)chaseInfo {
    if(alive && enabled) {
        // get distance between player's position and miniboss position
        CGPoint playerMinibossDif = ccpSub([Globals sharedSingleton].playerPosition, ccpSub(dummyPosition, ccp(0, [self getLevelOffset:level].y)));
        // keep track of the greatest distance
        if(abs(playerMinibossDif.y) > greatestDistance) {
            greatestDistance = abs(playerMinibossDif.y);
        }
        
        // get range of speed for miniboss chase
        CGPoint speedRange = ccpMult(CGPointFromString([chaseInfo objectForKey:@"speed"]), abs(playerMinibossDif.y) / greatestDistance);
        // move the miniboss towards the player's y position, but keep it's current x position
        [self stopActionByTag:MINIBOSS_ACTION_TAG_HOVER];
        [self stopActionByTag:MINIBOSS_ACTION_TAG_CHASE];
        CCActionInterval *chasePlayer = [BBMoveBy actionWithDuration:CCRANDOM_MIN_MAX(speedRange.x, speedRange.y) position:ccp(0, playerMinibossDif.y)];
        chasePlayer.tag = MINIBOSS_ACTION_TAG_CHASE;
        // make sure we're not charging
        if(state == MINIBOSS_STATE_ACTIVE) {
            [self runAction:chasePlayer];
        }
        
        // chase after a random amount of time
        CGPoint chaseFrequency = CGPointFromString([chaseInfo objectForKey:@"checkPlayerPositionFrequency"]);
        CCSequence *chaseSequence = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_MIN_MAX(chaseFrequency.x, chaseFrequency.y)], [CCCallFuncO actionWithTarget:self selector:@selector(chase:) object:chaseInfo], nil];
        chaseSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHASE;
        [self runAction:chaseSequence];
    }
}

- (void) changeWeapon:(NSDictionary*)weaponInfo {
    if(alive && enabled) {
        // unequip all weapons for this miniboss
        [[BBWeaponManager sharedSingleton] unequipAllForType:WEAPON_INVENTORY_MINIBOSS];
        
        // get array of possible weapons
        NSArray *weapons = [weaponInfo objectForKey:@"weapons"];
        
        // get a random weapon to equip from this miniboss's arsenal
        NSDictionary *ranWeapon = [BBGameObject randomDictionaryFromArray:weapons];
        [[BBWeaponManager sharedSingleton] equip:[ranWeapon objectForKey:@"type"] forType:WEAPON_INVENTORY_MINIBOSS];
        [[BBWeaponManager sharedSingleton] setEnabled:YES forType:WEAPON_INVENTORY_MINIBOSS];
        [[BBWeaponManager sharedSingleton] setNode:switchNode.parent forType:WEAPON_INVENTORY_MINIBOSS];
        
        // change weapon after random period of time
        CGPoint weaponChangeFrequency = CGPointFromString([weaponInfo objectForKey:@"changeWeaponFrequency"]);
        CCSequence *changeWeaponSequence = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_MIN_MAX(weaponChangeFrequency.x, weaponChangeFrequency.y)], [CCCallFuncO actionWithTarget:self selector:@selector(changeWeapon:) object:weaponInfo], nil];
        changeWeaponSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHANGE_WEAPON;
        [self runAction:changeWeaponSequence];
    }
}

- (void) charge {
    if(alive && enabled) {
        // check current state
        switch (state) {
            case MINIBOSS_STATE_ACTIVE: {
                state = MINIBOSS_STATE_CHARGE_CHARGING;
                // set new final position based on miniboss's current position
                finalPos.x = dummyPosition.x - [Globals sharedSingleton].playerPosition.x;
                // get ranges of warning speed and time
                CGPoint warningSpeed = CGPointFromString([chargeInfo objectForKey:@"warnSpeed"]);
                CGPoint warningTime = CGPointFromString([chargeInfo objectForKey:@"warnTime"]);
                // set velocity based on player's velocity and warning speed
                self.velocity = ccp([Globals sharedSingleton].playerVelocity.x + CCRANDOM_MIN_MAX(warningSpeed.x, warningSpeed.y), 0);
                // run action to call this function again
                CCSequence *chargeSequence = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_MIN_MAX(warningTime.x, warningTime.y)], [CCCallFunc actionWithTarget:self selector:@selector(charge)], nil];
                chargeSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHARGE;
                [self runAction:chargeSequence];
                break;
            }
            case MINIBOSS_STATE_CHARGE_CHARGING: {
                state = MINIBOSS_STATE_CHARGE_LEFT;
                // get range of charge left speed
                CGPoint chargeSpeed = CGPointFromString([chargeInfo objectForKey:@"speed"]);
                // set velocity based on player's velocity and charge speed
                self.velocity = ccp([Globals sharedSingleton].playerVelocity.x - CCRANDOM_MIN_MAX(chargeSpeed.x, chargeSpeed.y), 0);
                break;
            }
            case MINIBOSS_STATE_CHARGE_LEFT: {
                state = MINIBOSS_STATE_CHARGE_RIGHT;
                // get range of charge right speed
                CGPoint chargeSpeed = CGPointFromString([chargeInfo objectForKey:@"returnSpeed"]);
                // set velocity based on player's velocity and return speed
                self.velocity = ccp([Globals sharedSingleton].playerVelocity.x + CCRANDOM_MIN_MAX(chargeSpeed.x, chargeSpeed.y), 0);
                break;
            }
            case MINIBOSS_STATE_CHARGE_RIGHT: {
                state = MINIBOSS_STATE_ACTIVE;
                // get range of time before next charge
                CGPoint chargeFrequency = CGPointFromString([chargeInfo objectForKey:@"frequency"]);
                // run action to call this function again after a random delay
                CCSequence *chargeSequence = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_MIN_MAX(chargeFrequency.x, chargeFrequency.y)], [CCCallFunc actionWithTarget:self selector:@selector(charge)], nil];
                chargeSequence.tag = MINIBOSS_ACTION_TAG_CALL_CHARGE;
                [self runAction:chargeSequence];
                break;
            }
            default:
                break;
        }
    }
}

- (void) showHealth {
    // only flash if alive and enabled
    if(alive && enabled) {
        [self stopActionByTag:MINIBOSS_ACTION_TAG_CALL_SHOW_HEALTH];
        [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:0.1 numberOfTimes:1 onSprite:self];
        // make sequence to call this function again. gets faster as health depletes
        CCSequence *showHealthSequence = [CCSequence actions:[CCDelayTime actionWithDuration:0.25 + 5 * health / initialHealth], [CCCallFunc actionWithTarget:self selector:@selector(showHealth)], nil];
        showHealthSequence.tag = MINIBOSS_ACTION_TAG_CALL_SHOW_HEALTH;
        [self runAction:showHealthSequence];
    }
}

@end

@implementation BBMinibossShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    BBBullet *bullet = (BBBullet*)(contact.otherObject.ccNode);
    // only collide with the bullet if it's coming from the player
    if(bullet.type == kBulletTypeShot || bullet.type == kBulletTypeLaser) {
        contact.box2dContact->SetEnabled(NO);
        [(BBMiniboss*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode)];
    }
}

@end
