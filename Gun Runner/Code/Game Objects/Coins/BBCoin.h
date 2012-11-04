//
//  BBCoin.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"

@interface BBCoinShape : BBGameObjectShape {}
@end

@interface BBCoin : BBGameObject {
    // whether or not the coin can be recycled
	BOOL recycle;
	// whether or not the coin is enabled
	BOOL enabled;
	// whether or not the coin has been collected
	BOOL alive;
}

@property (nonatomic, assign) BOOL recycle, enabled, alive;

// setters
- (void) setEnabled:(BOOL)newEnabled;
// actions
- (void) resetWithPosition:(CGPoint)newPosition delayAnimation:(float)delay;

@end
