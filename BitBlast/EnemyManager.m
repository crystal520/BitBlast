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
		currentEnemies = [NSMutableArray new];
		for(int i=0;i<MAX_ENEMIES;i++) {
			BBEnemy *enemy = [[BBEnemy alloc] init];
			[currentEnemies addObject:enemy];
			[enemy release];
		}
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkAdded) name:kChunkAddedNotification object:nil];
	}
	return self;
}

- (void) dealloc {
	[currentEnemies release];
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	for(BBEnemy *e in currentEnemies) {
		if(!e.recycle) {
			[e update:delta];
		}
	}
}

#pragma mark -
#pragma mark getters
- (BBEnemy*) getRecycledEnemy {
	for(BBEnemy *e in currentEnemies) {
		if(e.recycle) {
			return e;
		}
	}
	return nil;
}

- (NSArray*) getActiveEnemies {
	NSMutableArray *activeEnemies = [NSMutableArray array];
	for(BBEnemy *e in currentEnemies) {
		if(!e.recycle) {
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
		else {
			[newEnemy resetWithPosition:[newChunk getGroundPositionWithLayer:@"CollisionTop"] withType:@"testEnemy2"];
		}
		[newChunk addChild:newEnemy z:newChunk.playerZ];
	}
}

@end
