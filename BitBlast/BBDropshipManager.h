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
}

@property (nonatomic, assign) int dropshipLevel;
@property (nonatomic, assign) CCNode *frontNode, *backNode;

+ (BBDropshipManager*) sharedSingleton;

// getters
- (NSArray*) getActiveDropships;
- (BBDropship*) getInactiveDropship;
- (NSString*) getRandomDropshipType;
// update
- (void) update:(float)delta;
// actions
- (void) tryToSpawnDropship;
// notifications
- (void) pause;

@end
