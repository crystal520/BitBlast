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
		recycle = YES;
        [collisionShape setActive:NO];
		alive = NO;
	}
	enabled = e;
}

- (void) resetWithPosition:(CGPoint)newPosition {
	// reset the coin with new parameters
	[self setEnabled:YES];
	[self repeatAnimation:@"coinIdle"];
	dummyPosition = newPosition;
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

@end
