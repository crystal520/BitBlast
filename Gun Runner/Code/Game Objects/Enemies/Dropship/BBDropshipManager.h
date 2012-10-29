//
//  BBDropshipManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBDropship.h"
#import "BulletManager.h"
#import "ChunkManager.h"

#define MAX_DROPSHIPS 3

@interface BBDropshipManager : NSObject {
    // array of dropships
	NSMutableArray *dropships;
	// number of dropships that should be on screen
	int targetDropships;
	// whether or not dropships are being updated and spawned
	BOOL enabled;
	// current dropship level
	int dropshipLevel;
	// array of dropship levels
	NSArray *dropshipLevels;
	// explosions!
	BBExplosionManager *explosionManager;
    // parent nodes for dropships
    CCNode *frontNode, *backNode;
    // whether or not the dropship manager is paused
    BOOL paused;
    // the level that a dropship will be spawned at
    ChunkLevel overrideLevel;
}

@property (nonatomic, assign) int dropshipLevel;
@property (nonatomic, assign) CCNode *frontNode, *backNode;

+ (BBDropshipManager*) sharedSingleton;

// getters
- (NSArray*) getActiveDropships;
- (BBDropship*) getInactiveDropship;
- (NSString*) getRandomDropshipType;
// setters
- (void) setEnabled:(BOOL)newEnabled;
// update
- (void) update:(float)delta;
// actions
- (void) tryToSpawnDropship;
- (void) tryToSpawnDropshipWithOverrideLevel:(ChunkLevel)newOverrideLevel;
// notifications
- (void) pause;
- (void) resume;

@end
