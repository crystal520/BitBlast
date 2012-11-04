//
//  BBCoin.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBCoin.h"

@implementation BBCoinShape
@end

@implementation BBCoin

@synthesize recycle, enabled, alive;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
		alive = YES;
        collisionShape = [[BBCoinShape alloc] initWithDynamicBody:@"oldCoin1" node:self];
        [collisionShape setActive:NO];
	}
	
	return self;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)e {
    self.visible = e;
	if(e && !enabled) {
		recycle = NO;
        [collisionShape setActive:YES];
		alive = YES;
	}
	else if(!e && enabled) {
        [self stopActionByTag:COIN_ACTION_DELAY_ANIMATION];
		recycle = YES;
        [collisionShape setActive:NO];
		alive = NO;
	}
	enabled = e;
}

- (void) resetWithPosition:(CGPoint)newPosition delayAnimation:(float)delay {
    // delay first coin animation
    CCSequence *coinAnimAction = [CCSequence actions:[CCDelayTime actionWithDuration:delay], [CCCallFunc actionWithTarget:self selector:@selector(playCoinAnimation)], nil];
    coinAnimAction.tag = COIN_ACTION_DELAY_ANIMATION;
    [self runAction:coinAnimAction];
	// reset the coin with new parameters
	[self setEnabled:YES];
    // set initial frame of animation
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"oldCoin1.png"]];
	dummyPosition = newPosition;
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

- (void) playCoinAnimation {
    // make action to space out coin animations
    CCSequence *coinAnimAction = [CCSequence actions:[CCDelayTime actionWithDuration:1.5], [CCCallFunc actionWithTarget:self selector:@selector(playCoinAnimation)], nil];
    coinAnimAction.tag = COIN_ACTION_DELAY_ANIMATION;
    [self runAction:coinAnimAction];
    // play the coin animation
    [self playAnimation:@"coinSpin"];
}

@end
