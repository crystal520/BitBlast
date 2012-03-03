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

#define MAX_DROPSHIPS 1

@interface BBDropshipManager : CCNode {
    // array of dropships
	NSMutableArray *dropships;
}

+ (BBDropshipManager*) sharedSingleton;

// setters
- (void) setVelocity:(float)velocity;
// getters
- (NSArray*) getActiveDropships;
// update
- (void) update:(float)delta;
// actions
- (void) checkCollisions;

@end
