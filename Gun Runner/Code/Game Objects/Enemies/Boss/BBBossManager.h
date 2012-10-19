//
//  BBBossManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "CCNode.h"
#import "BBExplosionManager.h"
#import "BBBoss.h"

#define MAX_BOSSES 1

@interface BBBossManager : CCNode {
    // array of bosses
    NSMutableArray *bosses;
	// explosions!
	BBExplosionManager *explosionManager;
    // whether or not bosses are able to spawn
    BOOL enabled;
    // maximum number of bosses that can spawn at a time
    int targetBosses;
    // whether a boss has been triggered to spawn or not
    BOOL isSpawningBoss;
}

@property (nonatomic, assign) int bossLevel;
@property (nonatomic, assign) BOOL isSpawningBoss;

+ (BBBossManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (BBBoss*) getInactiveBoss;
- (NSArray*) getActiveBosses;
- (BOOL) isActive;
// actions
- (void) tryToSpawnBoss;
- (void) spawnBoss;
- (void) triggerBoss;
// notifications
- (void) gameOver;
- (void) pause;

@end
