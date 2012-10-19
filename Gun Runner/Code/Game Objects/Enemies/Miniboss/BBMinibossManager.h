//
//  BBMinibossManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 7/18/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "CCNode.h"
#import "BBMiniboss.h"
#import "BBExplosionManager.h"

#define MAX_MINIBOSSES 1

@interface BBMinibossManager : NSObject {
    // array of minibosses
    NSMutableArray *minibosses;
    // different nodes for intro sequence and normal state
    CCNode *frontNode, *backNode;
	// explosions!
	BBExplosionManager *explosionManager;
    // whether or not minibosses are able to spawn
    BOOL enabled;
    // maximum number of minibosses that can spawn at a time
    int targetMinibosses;
    // current level of choosing minibosses based on player's distance
    int minibossLevel;
    // miniboss levels obtained from plist to spawn different minibosses based on player's distance
    NSArray *minibossLevels;
    // whether or not the miniboss manager is paused
    BOOL paused;
}

@property (nonatomic, readonly) CCNode *frontNode, *backNode;
@property (nonatomic, assign) int minibossLevel;

+ (BBMinibossManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (NSString*) getRandomMinibossType;
- (BBMiniboss*) getInactiveMiniboss;
- (NSArray*) getActiveMinibosses;
// setters
- (void) setEnabled:(BOOL)newEnabled;
// actions
- (void) tryToSpawnMiniboss;
- (void) spawnMiniboss;
// notifications
- (void) pause;
- (void) resume;

@end
