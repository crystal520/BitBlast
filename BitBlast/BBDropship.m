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
		[self setEnabled:NO];
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
	
	// set values from dictionary
	spawnRate = [[dictionary objectForKey:@"spawnRate"] floatValue];
	health = [[dictionary objectForKey:@"health"] intValue];
	[enemyTypes setArray:[dictionary objectForKey:@"enemyTypes"]];
	// see if there's a sprite and remove it from its parent first
	if(sprite && sprite.parent) {
		[sprite.parent removeChild:sprite cleanup:YES];
	}
	// make sprite
	sprite = [CCSprite spriteWithSpriteFrameName:[dictionary objectForKey:@"image"]];
	// TODO: turn this scale off once we get a different image for these
	sprite.scaleX = -1;
	boundingBox.origin.x *= -1;
	[self addChild:sprite];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if enabled
	if(enabled) {
		// get velocity from player
		velocity = ccp([Globals sharedSingleton].playerVelocity.x, 0);
		[super update:delta];
		// spawn enemies
		spawnTimer += delta;
		while(spawnTimer >= spawnRate) {
			[self spawnEnemy];
			spawnTimer -= spawnRate;
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
	}
	else if(!enabled && newEnabled) {
		self.visible = YES;
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
	health -= bullet.damage;
	
	// TODO: play hit animation or something cooler. possibly explosion particles
	CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
	[self.sprite runAction:action];
	
	if(health <= 0) {
		[self setEnabled:NO];
	}
}

- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type {
	[self loadFromFile:type];
	dummyPosition = ccpAdd(newPosition, ccp(-sprite.contentSize.width * 0.5, sprite.contentSize.height));
	[self setEnabled:YES];
}

@end
