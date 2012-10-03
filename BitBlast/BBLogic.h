//
//  BBLogic.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBDropshipManager.h"
#import "BBCoinManager.h"
#import "BBMinibossManager.h"
#import "BBBossManager.h"
#import "BBMovingCoinManager.h"

@interface BBLogic : NSObject {
    BOOL enabled;
	// make sure the first dice roll results in a coin group
	BOOL firstRun;
    // array of probability levels
    NSArray *levels;
    // current level within the probability levels, based on player's distance
    int currentLevel;
}

+ (BBLogic*) sharedSingleton;
// setters
- (void) setEnabled:(BOOL)newEnabled;
// notifications
- (void) rollDice;
- (void) triforceCollected;

@end
