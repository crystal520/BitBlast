//
//  BBCoin.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBCoin.h"


@implementation BBCoin

@synthesize recycle, enabled, alive;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
		alive = YES;
		[self loadFromFile:@"coin"];
		[self loadAnimations];
		[self addChild:spriteBatch];
	}
	
	return self;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(newEnabled && !enabled) {
		recycle = NO;
		self.visible = YES;
		alive = YES;
	}
	else if(!newEnabled && enabled) {
		recycle = YES;
		self.visible = NO;
		alive = NO;
	}
	enabled = newEnabled;
}

- (void) resetWithPosition:(CGPoint)newPosition {
	// reset the coin with new parameters
	[self setEnabled:YES];
	[self repeatAnimation:@"idle"];
	dummyPosition = newPosition;
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

@end
