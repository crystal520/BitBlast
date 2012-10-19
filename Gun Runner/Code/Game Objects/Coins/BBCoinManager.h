//
//  BBCoinManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBCoin.h"
#import "ChunkManager.h"

#define MAX_COINS 100

@interface BBCoinManager : CCNode {
    NSMutableArray *coins;
	NSArray *patterns;
    // whether or not the coin manager is paused
    BOOL paused;
}

+ (BBCoinManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (BBCoin*) getRecycledCoin;
- (NSArray*) getActiveCoins;
- (NSArray*) getRandomCoinGroup;
// setters
- (void) setEnabled:(BOOL)newEnabled;
// notifications
- (void) levelWillLoad;
- (void) pause;
- (void) resume;
// actions
- (void) spawnCoinGroup;

@end
