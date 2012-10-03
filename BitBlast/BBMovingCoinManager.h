//
//  BBMovingCoinManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingCoin.h"

#define MAX_MOVING_COINS 100

@interface BBMovingCoinManager : CCNode {
    NSMutableArray *coins;
}

+ (BBMovingCoinManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
-(BOOL) isTriforceActive;
- (BBMovingCoin*) getRecycledCoin;
- (NSArray*) getActiveCoins;
// actions
- (void) spawnCoins:(int)numCoins atPosition:(CGPoint)position;
- (void) spawnKeyAtPosition:(CGPoint)position;
- (void) spawnTriforceAtPosition:(CGPoint)position;

@end
