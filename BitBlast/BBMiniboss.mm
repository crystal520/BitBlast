//
//  BBMiniboss.m
//  GunRunner
//
//  Created by Kristian Bauer on 7/18/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMiniboss.h"

@implementation BBMiniboss

@synthesize enabled, alive, explosionManager;

- (id) init {
	if((self = [super init])) {
		[self setEnabled:NO];
		alive = YES;
		needsPlatformCollisions = NO;
	}
	return self;
}

- (void) dealloc {
    [particles release];
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
		if(state == MINIBOSS_STATE_THINKING) {
            lastBulletHit = nil;
			[super update:delta];
			// get velocity from player
			if(alive) {
				velocity = ccp([Globals sharedSingleton].playerVelocity.x, 0);
			}
			
			// if dropship is dead and goes off screen, actually kill it
			if(!alive) {
				if(dummyPosition.y + self.contentSize.height * 0.5 < 0) {
					[self setEnabled:NO];
                    [explosionManager stopExploding:self];
					[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventDropshipDestroyed object:nil]];
				}
			}
		}
		else if(state == MINIBOSS_STATE_MOVE_RIGHT) {
			[super update:delta];
			
			CGPoint shipScreenPos = [self convertToWorldSpace:CGPointZero];
			if(shipScreenPos.x - self.contentSize.width * [ResolutionManager sharedSingleton].imageScale > [CCDirector sharedDirector].winSize.width) {
				velocity = ccp([Globals sharedSingleton].playerVelocity.x - 200, 0);
				self.scale = 1;
				self.scaleX = -1;
				state = MINIBOSS_STATE_MOVE_LEFT;
			}
		}
		else if(state == MINIBOSS_STATE_MOVE_LEFT) {
			[super update:delta];
			
			if(dummyPosition.x < [Globals sharedSingleton].playerPosition.x + finalPos.x) {
				state = MINIBOSS_STATE_THINKING;
				alive = YES;
                [collisionShape setActive:YES];
			}
		}
	}
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

#pragma mark -
#pragma mark actions
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
                //[self stopActionByTag:DROPSHIP_ACTION_TAG_HOVER];
                //[self stopActionByTag:DROPSHIP_ACTION_TAG_HIT];
                [self setColor:ccc3(255, 255, 255)];
                [self die];
                [explosionManager explodeInObject:self number:5];
            }
            else {
                // TODO: play hit animation or something cooler. possibly explosion particles
                CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
                action.tag = MINIBOSS_ACTION_TAG_HIT;
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
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalMinibosses"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentMinibosses"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"dailyMinibosses"];
	alive = NO;
	gravity = ccp(2, 5);
	// turn towards the ground and crash!
	[self runAction:[CCRotateTo actionWithDuration:1 angle:-15]];
}

- (void) hover {
    // make dropship hover
    float hoverTime = CCRANDOM_MIN_MAX(0.35, 0.45);
    CCActionInterval *hoverUp = [CCEaseInOut actionWithAction:[BBMoveBy actionWithDuration:hoverTime position:ccp(0, CCRANDOM_MIN_MAX(0.15, 0.25))]];
    CCActionInterval *hoverDown = [CCEaseInOut actionWithAction:[BBMoveBy actionWithDuration:hoverTime position:ccp(0, CCRANDOM_MIN_MAX(-0.25, -0.15))]];
    CCAction *finalHover = [CCRepeatForever actionWithAction:[CCSequence actions:hoverUp, hoverDown, nil]];
    //finalHover.tag = DROPSHIP_ACTION_TAG_HOVER;
    [self runAction:finalHover];
}

- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel {
	[self loadFromFile:type];
	state = MINIBOSS_STATE_MOVE_RIGHT;
	
	// determine offset based on level type
	CGPoint levelOffset = ccp(0, 0);
	/*level = newLevel;
	if(level == CHUNK_LEVEL_BOTTOM) {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetBottom"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetBottom"] objectForKey:@"y"] floatValue]);
	}
	else if(level == CHUNK_LEVEL_TOP) {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetTop"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetTop"] objectForKey:@"y"] floatValue]);
	}
	else {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetMiddle"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetMiddle"] objectForKey:@"y"] floatValue]);
	}*/
	
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

@implementation BBMinibossShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBMiniboss*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode)];
}

@end
