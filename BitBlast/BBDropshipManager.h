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

#define MAX_DROPSHIPS 1

@interface BBDropshipManager : CCNode {
    // array of dropships
	NSMutableArray *dropships;
	// number of dropships that should be on screen
	int targetDropships;
	// whether or not a dropship is being spawned
	BOOL spawningDropship;
	// whether or not dropships are being updated and spawned
	BOOL enabled;
}

+ (BBDropshipManager*) sharedSingleton;

// getters
- (NSArray*) getActiveDropships;
- (BBDropship*) getInactiveDropship;
// update
- (void) update:(float)delta;
// actions
- (void) checkCollisions;
- (void) tryToSpawnDropship;

@end
