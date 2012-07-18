//
//  BBEnemy.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBEnemy.h"


@implementation BBEnemy

@synthesize recycle, enabled, alive;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
		alive = YES;
	}
	
	return self;
}

- (void) dealloc {
	[type release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	// perform reset first to release any variables
	[self reset];
	[super loadFromFile:filename];
	// load extra variables
	tileOffset = ccp(0, [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale);
	type = [[dictionary objectForKey:@"type"] retain];
	velocity = ccp([[[dictionary objectForKey:@"speed"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"speed"] objectForKey:@"y"] floatValue]);
	health = [[dictionary objectForKey:@"health"] floatValue];
	gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
	coins = [[dictionary objectForKey:@"coins"] intValue];
    minVelocity = CGPointFromString([dictionary objectForKey:@"minVelocity"]);
    maxVelocity = CGPointFromString([dictionary objectForKey:@"maxVelocity"]);
    [self setCollisionShape:[dictionary objectForKey:@"collisionShape"]];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(newEnabled && !enabled) {
		recycle = NO;
		self.visible = YES;
		alive = YES;
		self.scale = 1;
        [collisionShape setActive:YES];
	}
	else if(!newEnabled && enabled) {
		recycle = YES;
		self.visible = NO;
		alive = NO;
        [collisionShape setActive:NO];
	}
	enabled = newEnabled;
}

- (void) setCollisionShape:(NSString *)shapeName {
    if(collisionShape) {
        if(![collisionShape.shapeName isEqualToString:shapeName]) {
            [collisionShape destroyBody];
            collisionShape = [[BBEnemyShape alloc] initWithDynamicBody:shapeName node:self];
            [collisionShape setActive:NO];
        }
    }
    else {
        collisionShape = [[BBEnemyShape alloc] initWithDynamicBody:shapeName node:self];
        [collisionShape setActive:NO];
    }
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if this enemy is enabled
	if(enabled) {
        lastBulletHit = nil;
		[super update:delta];
	}
}

#pragma mark -
#pragma mark actions
- (void) reset {
	if(type) {
		[type release];
	}
}
   
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString *)enemyType {
	// reset the enemy with new parameters
	[self loadFromFile:enemyType];
	[self loadAnimations];
	[self setEnabled:YES];
	[self repeatAnimation:@"walk"];
	self.anchorPoint = ccp(0.5, 0);
	dummyPosition = ccpAdd(newPosition, ccp(0, -self.contentSize.height * 0.5));
	// update once just to set correct position
	[self update:0];
}

- (void) hitByBullet:(BBBullet*)bullet {
    if(bullet.enabled && health > 0 && bullet != lastBulletHit) {
        health -= bullet.damage;
        
        // if the enemy died, turn off all movement and play a death animation
        if(health <= 0) {
            [self stopActionByTag:ENEMY_ACTION_TAG_HIT];
            [self setColor:ccc3(255, 255, 255)];
            // increment enemies killed
            [[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalEnemies"];
            [[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentEnemies"];
            [[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"dailyEnemies"];
            [self die];
            [[BBMovingCoinManager sharedSingleton] spawnCoins:coins atPosition:self.dummyPosition];
        }
        else {
            // TODO: play hit animation or something cooler. possibly blood particles
            CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
            action.tag = ENEMY_ACTION_TAG_HIT;
            [self runAction:action];
        }
        // only disable if the bullet is a shot (lasers go through everything!)
        if(bullet.type == kBulletTypeShot) {
            [bullet setEnabled:NO];
        }
        // keep track of last bullet that hit this enemy (for laser penetration)
        lastBulletHit = bullet;
    }
}

- (void) die {
	[[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
	alive = NO;
	velocity = ccp(0, 0);
	gravity = ccp(0, 0);
	self.scale = 3;
	[self playAnimation:@"death" target:self selector:@selector(deathAnimationOver)];
}

- (void) deathAnimationOver {
	[self setEnabled:NO];
}

@end

@implementation BBEnemyShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBEnemy*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode)];
}

@end
