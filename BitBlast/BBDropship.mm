//
//  BBDropship.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDropship.h"


@implementation BBDropship

@synthesize enabled, alive, level, explosionManager;

- (id) init {
	if((self = [super init])) {
		enemyTypes = [NSMutableArray new];
		[self setEnabled:NO];
		alive = YES;
		needsPlatformCollisions = NO;
		level = CHUNK_LEVEL_UNKNOWN;
	}
	return self;
}

- (void) dealloc {
	[enemyTypes release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	[self loadAnimations];
	
	// check for particle system
	if(particles) {
		[particles release];
	}
	if([dictionary objectForKey:@"particles"]) {
		particles = [[dictionary objectForKey:@"particles"] retain];
	}
	
	// set values from dictionary
	spawnRate = [[dictionary objectForKey:@"spawnRate"] floatValue];
	spawnTimer = 0;
	health = [[dictionary objectForKey:@"health"] floatValue];
	[enemyTypes setArray:[dictionary objectForKey:@"enemyTypes"]];
	coins = [[dictionary objectForKey:@"coins"] intValue];
	[self repeatAnimation:@"walk"];
    
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
		if(state == DROPSHIP_STATE_ACTIVE) {
            lastBulletHit = nil;
			[super update:delta];
			// get velocity from player
			if(alive) {
				velocity = ccp([Globals sharedSingleton].playerVelocity.x, 0);
				// spawn enemies
				spawnTimer += delta;
				while(spawnTimer >= spawnRate) {
					[self spawnEnemy];
					spawnTimer -= spawnRate;
				}
			}
			
			// if dropship is dead and goes off screen, actually kill it
			if(!alive) {
				if(dummyPosition.y + self.contentSize.height * 0.5 < 0) {
					[self setEnabled:NO];
					[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventDropshipDestroyed object:nil]];
				}
			}
		}
		else if(state == DROPSHIP_STATE_INTRO_MOVING_RIGHT) {
			[super update:delta];
			
			CGPoint shipScreenPos = [self convertToWorldSpace:CGPointZero];
			if(shipScreenPos.x - self.contentSize.width * [ResolutionManager sharedSingleton].imageScale > [CCDirector sharedDirector].winSize.width) {
				velocity = ccp([Globals sharedSingleton].playerVelocity.x - 200, 0);
				self.scale = 1;
				self.scaleX = -1;
				state = DROPSHIP_STATE_INTRO_MOVING_LEFT;
			}
		}
		else if(state == DROPSHIP_STATE_INTRO_MOVING_LEFT) {
			[super update:delta];
			
			if(dummyPosition.x < [Globals sharedSingleton].playerPosition.x + finalPos.x) {
				state = DROPSHIP_STATE_ACTIVE;
				alive = YES;
                [collisionShape setActive:YES];
			}
		}
	}
}

#pragma mark -
#pragma mark getters
- (NSString*) getRandomEnemy {
	int ran = CCRANDOM_MIN_MAX(0, [enemyTypes count]);
	return [enemyTypes objectAtIndex:ran];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
		self.visible = NO;
		alive = NO;
        [collisionShape setActive:NO];
	}
	else if(!enabled && newEnabled) {
		self.visible = YES;
		alive = YES;
	}
	if(!newEnabled) {
		level = CHUNK_LEVEL_UNKNOWN;
	}
	enabled = newEnabled;
}

- (void) setCollisionShape:(NSString *)shapeName {
    if(collisionShape) {
        if(![collisionShape.shapeName isEqualToString:shapeName]) {
            [collisionShape destroyBody];
            collisionShape = [[BBDropshipShape alloc] initWithDynamicBody:shapeName node:self];
            [collisionShape setActive:NO];
        }
    }
    else {
        collisionShape = [[BBDropshipShape alloc] initWithDynamicBody:shapeName node:self];
        [collisionShape setActive:NO];
    }
}

#pragma mark -
#pragma mark actions
- (void) spawnEnemy {
	if(alive && enabled) {
		// get recycled enemy
		BBEnemy *newEnemy = [[EnemyManager sharedSingleton] getRecycledEnemy];
		// reset with position of dropship and random enemy type
		[newEnemy resetWithPosition:dummyPosition withType:[self getRandomEnemy]];
	}
}

- (void) hitByBullet:(BBBullet*)bullet withContact:(GB2Contact*)contact {
    if(bullet.enabled && bullet != lastBulletHit) {
        
        // play particles where ship was hit
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
        
        // play sound for dropship getting hit by bullet
        [[SimpleAudioEngine sharedEngine] playEffect:[[dictionary objectForKey:@"sounds"] objectForKey:@"hit"]];
        
        if(health > 0) {
            health -= bullet.damage;
            // if the dropship died, turn off all movement and play death animation
            if(health <= 0) {
                [self stopActionByTag:DROPSHIP_ACTION_TAG_HIT];
                [self setColor:ccc3(255, 255, 255)];
                [self die];
                [explosionManager explodeInObject:self number:5];
            }
            else {
                // TODO: play hit animation or something cooler. possibly explosion particles
                CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
                action.tag = DROPSHIP_ACTION_TAG_HIT;
                [self runAction:action];
            }
        }
        // only disable if the bullet is a shot (lasers go through everything!)
        if(bullet.type == kBulletTypeShot) {
            [bullet setEnabled:NO];
        }
        // keep track of the last bullet that hit this dropship (for laser penetration)
        lastBulletHit = bullet;
    }
}

- (void) die {
	[[BBMovingCoinManager sharedSingleton] spawnCoins:coins atPosition:dummyPosition];
	[[SimpleAudioEngine sharedEngine] playEffect:[[dictionary objectForKey:@"sounds"] objectForKey:@"death"]];
	// increment dropships killed
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalDropships"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentDropships"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"dailyDropships"];
	alive = NO;
	gravity = ccp(2, 5);
	level = CHUNK_LEVEL_UNKNOWN;
	// turn towards the ground and crash!
	[self runAction:[CCRotateTo actionWithDuration:1 angle:-15]];
}

- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel {
	[self loadFromFile:type];
	state = DROPSHIP_STATE_INTRO_MOVING_RIGHT;
	
	// determine offset based on level type
	CGPoint levelOffset = ccp(0, 0);
	level = newLevel;
	if(level == CHUNK_LEVEL_BOTTOM) {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetBottom"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetBottom"] objectForKey:@"y"] floatValue]);
	}
	else if(level == CHUNK_LEVEL_TOP) {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetTop"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetTop"] objectForKey:@"y"] floatValue]);
	}
	else {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetMiddle"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetMiddle"] objectForKey:@"y"] floatValue]);
	}
	
	// make dropship huge
	self.scale = 2;
	// save final position for later
	finalPos = ccpAdd(newPosition, levelOffset);
	// set velocity to more than the player so it flies past him
	velocity = ccp([Globals sharedSingleton].playerVelocity.x + 2000, 0);
	// start dropship off screen, to the left of the player
	dummyPosition = ccpAdd(ccpAdd(newPosition, ccp(-800, 0)), levelOffset);
	dummyPosition.x = dummyPosition.x + [Globals sharedSingleton].playerPosition.x;
	[self setEnabled:YES];
	// make sure it can't get hit by bullets yet
	alive = NO;
}

@end

@implementation BBDropshipShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBDropship*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode) withContact:contact];
}

@end
