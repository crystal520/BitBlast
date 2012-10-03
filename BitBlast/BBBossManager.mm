//
//  BBBossManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBossManager.h"

@implementation BBBossManager

@synthesize bossLevel, isSpawningBoss;

+ (BBBossManager*) sharedSingleton {
    
    static BBBossManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBBossManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
    if((self = [super init])) {
        // explosions!
		explosionManager = [BBExplosionManager new];
        // make array for bosses
        bosses = [NSMutableArray new];
        for(int i=0;i<MAX_BOSSES;i++) {
            BBBoss *boss = [[BBBoss alloc] initWithFile:@"boss"];
            [boss setExplosionManager:explosionManager];
            [bosses addObject:boss];
            [self addChild:boss];
            [boss release];
        }
		[explosionManager setNode:self];
        targetBosses = 1;
        enabled = YES;
        
        // register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kEventNewGame object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    for(BBBoss *b in bosses) {
        [b update:delta];
    }
}

#pragma mark -
#pragma mark getters
- (NSArray*) getActiveBosses {
    NSMutableArray *activeBosses = [NSMutableArray array];
    for(BBBoss *b in bosses) {
        if(b.enabled) {
            [activeBosses addObject:b];
        }
    }
    return activeBosses;
}

- (BBBoss*) getInactiveBoss {
    for(BBBoss *b in bosses) {
        if(!b.enabled) {
            return b;
        }
    }
    return nil;
}

- (BOOL) isActive {
    return ([[self getActiveBosses] count] > 0 || isSpawningBoss);
}

#pragma mark -
#pragma mark actions
- (void) spawnBoss {
    // spawn a new boss if enabled
    if(enabled) {
        BBBoss *b = [self getInactiveBoss];
        [b setEnabled:YES];
        
        // check to see if we're still spawning bosses
        if(isSpawningBoss && [[self getActiveBosses] count] == targetBosses) {
            isSpawningBoss = NO;
        }
    }
}

- (void) tryToSpawnBoss {
    // make sure there are enough active bosses
	int numActiveBosses = 0;
	for(BBBoss *b in bosses) {
		if(b.enabled) {
			numActiveBosses += 1;
		}
	}
    
    // get random number of bosses to spawn
    int numBossesToSpawn = CCRANDOM_MIN_MAX(1, targetBosses);
    
	// if there aren't enough active bosses, trigger a new one
	if(numActiveBosses != numBossesToSpawn) {
		for(int i=0;i<(numBossesToSpawn - numActiveBosses);i++) {
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1 + i], [CCCallFunc actionWithTarget:self selector:@selector(spawnBoss)], nil]];
            // trip flag for letting other classes know that a boss is going to be spawned
            isSpawningBoss = YES;
		}
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	enabled = NO;
	[self pause];
}

- (void) levelWillLoad {
	enabled = YES;
	// reset bosses
	for(BBBoss *b in bosses) {
		[b setEnabled:NO];
	}
}

- (void) pause {
	for(BBBoss *b in bosses) {
		[b pause];
	}
    [explosionManager pause];
}

- (void) resume {
	for(BBBoss *b in bosses) {
		[b resume];
	}
    [explosionManager resume];
}

@end
