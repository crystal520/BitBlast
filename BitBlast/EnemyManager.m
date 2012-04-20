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
			[self addChild:enemy];
			[enemies addObject:enemy];
			[enemy release];
		}
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kEventNewGame object:nil];
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
			// see if enemy has gone off screen
			if(e.dummyPosition.x < [Globals sharedSingleton].playerPosition.x - [Globals sharedSingleton].cameraOffset.x) {
				[e setEnabled:NO];
			}
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
		if(!e.recycle && e.enabled && e.alive) {
			[activeEnemies addObject:e];
		}
	}
	return activeEnemies;
}

#pragma mark -
#pragma mark notifications
- (void) levelWillLoad {
	for(BBEnemy *e in enemies) {
		[e setEnabled:NO];
	}
}

- (void) pause {
	for(BBEnemy *e in enemies) {
		[e pause];
	}
}

- (void) resume {
	for(BBEnemy *e in enemies) {
		[e resume];
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
