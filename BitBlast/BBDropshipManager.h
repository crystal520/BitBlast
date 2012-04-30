//
//  BBDropshipManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBDropship.h"
#import "BulletManager.h"
#import "ChunkManager.h"
#import "BBExplosionManager.h"

#define MAX_DROPSHIPS 3

@interface BBDropshipManager : CCNode {
    // array of dropships
	NSMutableArray *dropships;
	// number of dropships that should be on screen
	int targetDropships;
	// whether or not a dropship is being spawned
	BOOL spawningDropship;
	// whether or not dropships are being updated and spawned
	BOOL enabled;
	// current dropship level
	int dropshipLevel;
	// number of dropships left after spawning them
	int numDropshipsLeft;
	// array of dropship levels
	NSArray *dropshipLevels;
	// explosions!
	BBExplosionManager *explosionManager;
}

@property (nonatomic, assign) int dropshipLevel;

+ (BBDropshipManager*) sharedSingleton;

// getters
- (NSArray*) getActiveDropships;
- (BBDropship*) getInactiveDropship;
- (NSString*) getRandomDropshipType;
// update
- (void) update:(float)delta;
// actions
- (void) checkCollisions;
- (void) tryToSpawnDropship;
// notifications
- (void) pause;

@end
