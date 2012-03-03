//
//  BBDropship.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDropship.h"


@implementation BBDropship

@synthesize enabled;

- (id) init {
	if((self = [super init])) {
		enemyTypes = [NSMutableArray new];
		dummyPosition = ccp([ResolutionManager sharedSingleton].size.width * [ResolutionManager sharedSingleton].inversePositionScale, 64);
		enabled = YES;
	}
	return self;
}

- (void) dealloc {
	[enemyTypes release];
	[super dealloc];
}

- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	
	// set values from dictionary
	spawnRate = [[dictionary objectForKey:@"spawnRate"] floatValue];
	health = [[dictionary objectForKey:@"health"] intValue];
	[enemyTypes setArray:[dictionary objectForKey:@"enemyTypes"]];
	sprite = [CCSprite spriteWithSpriteFrameName:[dictionary objectForKey:@"image"]];
	sprite.scaleX = -1;
	sprite.anchorPoint = ccp(0.5, 0);
	[self addChild:sprite];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// update position
	dummyPosition = ccpAdd(dummyPosition, ccpMult(velocity, delta));
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	
	// spawn enemies
	spawnTimer += delta;
	while(spawnTimer >= spawnRate) {
		[self spawnEnemy];
		spawnTimer -= spawnRate;
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
- (void) setVelocity:(float)newVelocity {
	velocity = ccp(newVelocity, velocity.y);
}

- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
		self.visible = NO;
	}
	enabled = newEnabled;
}

#pragma mark -
#pragma mark actions
- (void) spawnEnemy {
	// get recycled enemy
	BBEnemy *newEnemy = [[EnemyManager sharedSingleton] getRecycledEnemy];
	// reset with position of dropship and random enemy type
	[newEnemy resetWithPosition:dummyPosition withType:[self getRandomEnemy]];
}

- (void) hitByBullet:(BBBullet*)bullet {
	//health -= bullet.damage;
	
	// TODO: play hit animation or something cooler. possibly blood particles
	CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
	[self.sprite runAction:action];
	
	if(health <= 0) {
		[self setEnabled:NO];
	}
}

@end
