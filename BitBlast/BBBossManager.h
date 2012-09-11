//
//  BBBossManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
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
}

@property (nonatomic, assign) int bossLevel;

+ (BBBossManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (BBBoss*) getInactiveBoss;
- (NSArray*) getActiveBosses;
// actions
- (void) tryToSpawnBoss;
- (void) spawnBoss;
// notifications
- (void) pause;

@end
