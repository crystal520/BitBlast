//
//  BBMovingCoin.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/15/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"

typedef enum {
    MOVING_COIN_TYPE_COIN,
    MOVING_COIN_TYPE_KEY,
    MOVING_COIN_TYPE_TRIFORCE,
    MOVING_COIN_TYPE_HEART,
    MOVING_COIN_TYPE_COIN_MULTIPLIER,
    MOVING_COIN_TYPE_GUN,
    MOVING_COIN_TYPE_COUNT
} MovingCoinType;

@interface BBMovingCoinShape : BBGameObjectShape {}
@end

@interface BBMovingCoin : BBMovingObject {
    // bounciness of coins
	float restitution;
	// whether or not this coin can be reused
	BOOL recycle;
	// whether or not this coin is enabled
	BOOL enabled;
	// how long this coin remains active for
	float lifeTime;
	float lifeTimer;
	// range of X velocity of coin
	CGPoint xVelRange;
	// range of Y velocity of coin
	CGPoint yVelRange;
    // type of coin
    MovingCoinType type;
}

@property (nonatomic, assign) BOOL recycle, enabled;
@property (nonatomic, assign) MovingCoinType type;

// update
- (void) update:(float)delta;
// actions
- (void) resetWithPosition:(CGPoint)newPosition;

@end
