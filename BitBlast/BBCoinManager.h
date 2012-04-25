//
//  BBCoinManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBCoin.h"
#import "ChunkManager.h"

#define MAX_COINS 50

@interface BBCoinManager : CCNode {
    NSMutableArray *coins;
	NSArray *patterns;
	BOOL checkForCoinGroup;
}

+ (BBCoinManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (BBCoin*) getRecycledCoin;
- (NSArray*) getActiveCoins;
- (NSArray*) getRandomCoinGroup;
// notifications
- (void) levelWillLoad;
// actions
- (void) spawnCoinGroup;

@end
