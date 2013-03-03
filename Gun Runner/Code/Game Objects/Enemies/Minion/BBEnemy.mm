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

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	// perform reset first to release any variables
	[self reset];
	[super loadFromFile:filename];
	// load extra variables
	tileOffset = ccp(0, [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale);
	baseSpeed = [[dictionary objectForKey:@"baseSpeed"] floatValue];
	speedIncrease = [[dictionary objectForKey:@"speedIncrease"] floatValue];
	baseHealth = [[dictionary objectForKey:@"baseHealth"] floatValue];
	healthIncrease = [[dictionary objectForKey:@"healthIncrease"] floatValue];
	gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
	baseCoins = [[dictionary objectForKey:@"baseCoins"] intValue];
	coinsIncrease = [[dictionary objectForKey:@"coinsIncrease"] intValue];
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
        if(![collisionShape.shapeString isEqualToString:shapeName]) {
            [collisionShape destroyBody];
            [collisionShape release];
            collisionShape = [[BBEnemyShape alloc] initWithDynamicBody:shapeName node:self];
            [collisionShape setActive:NO];
        }
    }
    else {
        collisionShape = [[BBEnemyShape alloc] initWithDynamicBody:shapeName node:self];
        [collisionShape setActive:NO];
    }
}

- (void)setLevel:(int)level {
    NSLog(@"setting enemy level: %i", level);
    // using level and attribute increments, set attributes for enemy
    health = baseHealth + (level * healthIncrease);
    velocity = ccp(baseSpeed - (level * speedIncrease), 0);
    coins = baseCoins + (level * coinsIncrease);
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
}
   
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString *)enemyType {
	// reset the enemy with new parameters
	[self loadFromFile:enemyType];
	[self setEnabled:YES];
	[self repeatAnimation:[dictionary objectForKey:@"animation"]];
	self.anchorPoint = ccp(0.5, 0);
	dummyPosition = ccpAdd(ccpAdd(newPosition, ccp(0, -self.contentSize.height * 0.5)), CGPointFromString([dictionary objectForKey:@"startOffset"]));
	// update once just to set correct position
	[self update:0];
    [self loadComplete];
}

- (void) hitByBullet:(BBBullet*)bullet {
    if(bullet.enabled && health > 0 && bullet != lastBulletHit) {
        health -= bullet.damage;
        
        // if the enemy died, turn off all movement and play a death animation
        if(health <= 0) {
            [self stopActionByTag:ACTION_TAG_FLASH];
            [self setColor:ccc3(255, 255, 255)];
            // increment enemies killed
            [[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalEnemies"];
            [[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentEnemies"];
            [[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"dailyEnemies"];
            [self die];
            [[BBMovingCoinManager sharedSingleton] spawnCoins:coins atPosition:ccpAdd(self.dummyPosition, ccp(0, self.contentSize.height))];
        }
        else if([[self getActionByTag:ACTION_TAG_FLASH] isDone] || ![self getActionByTag:ACTION_TAG_FLASH]) {
            [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:0.1 numberOfTimes:1 onSprite:self];
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
	[self playAnimation:@"explosion" target:self selector:@selector(deathAnimationOver)];
}

- (void) deathAnimationOver {
	[self setEnabled:NO];
}

@end

@implementation BBEnemyShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    BBBullet *bullet = (BBBullet*)(contact.otherObject.ccNode);
    // only collide with the bullet if it's coming from the player
    if(bullet.type == kBulletTypeShot || bullet.type == kBulletTypeLaser) {
        contact.box2dContact->SetEnabled(NO);
        [(BBEnemy*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode)];
    }
}

@end
