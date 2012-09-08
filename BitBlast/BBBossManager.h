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

@interface BBBossManager : NSObject {
    // array of bosses
    NSMutableArray *bosses;
    // different nodes for intro sequence and normal state
    CCNode *frontNode, *backNode;
	// explosions!
	BBExplosionManager *explosionManager;
    // whether or not bosses are able to spawn
    BOOL enabled;
    // maximum number of bosses that can spawn at a time
    int targetBosses;
    // current level of choosing bosses based on player's distance
    int bossLevel;
    // boss levels obtained from plist to spawn different bosses based on player's distance
    NSArray *bossLevels;
}

@property (nonatomic, readonly) CCNode *frontNode, *backNode;
@property (nonatomic, assign) int bossLevel;

+ (BBBossManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (NSString*) getRandomBossType;
- (BBBoss*) getInactiveBoss;
- (NSArray*) getActiveBosses;
// actions
- (void) tryToSpawnBoss;
- (void) spawnBoss;

@end
