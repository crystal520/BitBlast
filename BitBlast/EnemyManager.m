//
//  EnemyManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "EnemyManager.h"


@implementation EnemyManager

+ (EnemyManager*) sharedSingleton {
	
	static EnemyManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[EnemyManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

#pragma mark -
#pragma mark initializers
- (id) init {
	if((self = [super init])) {
		// create array of enemies
		enemies = [NSMutableArray new];
		for(int i=0;i<MAX_ENEMIES;i++) {
			BBEnemy *enemy = [[BBEnemy alloc] init];
			[enemies addObject:enemy];
			[enemy release];
		}
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkAdded) name:kChunkAddedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
	}
	return self;
}

- (void) dealloc {
	[enemies release];
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// update active enemies
	for(BBEnemy *e in enemies) {
		if(!e.recycle) {
			[e update:delta];
		}
	}
	// check collisions with bullets
	[self checkCollisions];
}

#pragma mark -
#pragma mark getters
- (BBEnemy*) getRecycledEnemy {
	for(BBEnemy *e in enemies) {
		if(e.recycle && !e.enabled) {
			return e;
		}
	}
	return nil;
}

- (NSArray*) getActiveEnemies {
	NSMutableArray *activeEnemies = [NSMutableArray array];
	for(BBEnemy *e in enemies) {
		if(!e.recycle && e.enabled) {
			[activeEnemies addObject:e];
		}
	}
	return activeEnemies;
}

#pragma mark -
#pragma mark notifications
- (void) chunkAdded {
	// get latest chunk
	Chunk *newChunk = [[ChunkManager sharedSingleton] getLastChunk];
	// check current state of player and update parameters for placing enemies based on it
	// things to check: equipment, weapon, speed, distance
	// using parameters, generate enemies
	// for now, for testing, just place the enemy at the first block encountered
	for(int i=0;i<2;i++) {
		BBEnemy *newEnemy = [self getRecycledEnemy];
		if(i == 0) {
			[newEnemy resetWithPosition:[newChunk getGroundPositionWithLayer:@"CollisionTop"] withType:@"testEnemy"];
		}
		else if(i == 1) {
			[newEnemy resetWithPosition:[newChunk getGroundPositionWithLayer:@"CollisionTop"] withType:@"testEnemy2"];
		}
		else {
			[newEnemy resetWithPosition:[newChunk getGroundPositionWithLayer:@"CollisionTop"] withType:@"testEnemy3"];
		}
		if(newEnemy) {
			[newChunk addChild:newEnemy z:newChunk.playerZ];
		}
	}
}

- (void) gameOver {
	for(BBEnemy *e in enemies) {
		[e stopAllActions];
	}
}

- (void) levelWillLoad {
	for(BBEnemy *e in enemies) {
		[e setEnabled:NO];
	}
}

#pragma mark -
#pragma mark actions
- (void) checkCollisions {
	NSArray *activeEnemies = [self getActiveEnemies];
	NSArray *activeBullets = [[BulletManager sharedSingleton] getActiveBullets];
	// then loop through the active enemies
	for(BBEnemy *e in activeEnemies) {
		// loop through active bullets
		for(BBBullet *b in activeBullets) {
			// check for collision
			if(b.enabled && e.enabled && [e getCollidesWith:b]) {
				[e hitByBullet:b];
				[b setEnabled:NO];
			}
		}
	}
}

@end
