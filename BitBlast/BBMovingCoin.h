//
//  BBMovingCoin.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/15/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"

@interface BBMovingCoin : BBMovingObject {
    // bounciness of coins
	float restitution;
	// whether or not this coin can be reused
	BOOL recycle;
	// how long this coin remains active for
	float lifeTime;
	float lifeTimer;
	// range of X velocity of coin
	CGPoint xVelRange;
	// range of Y velocity of coin
	CGPoint yVelRange;
}

@property (nonatomic, assign) BOOL recycle;

// update
- (void) update:(float)delta;
// actions
- (void) resetWithPosition:(CGPoint)newPosition;

@end
