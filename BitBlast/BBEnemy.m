//
//  BBEnemy.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBEnemy.h"


@implementation BBEnemy

@synthesize recycle, tileOffset;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	// load extra variables
	tileOffset = [[dictionary objectForKey:@"tileOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// keep track of previous position
	//prevDummyPosition = dummyPosition;
	// apply velocity to position
	//dummyPosition = ccp(dummyPosition.x + (velocity.x * delta), dummyPosition.y + (velocity.y * delta));
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

#pragma mark -
#pragma mark actions
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString *)enemyType {
	// reset the enemy with new parameters
	dummyPosition = newPosition;
	recycle = NO;
	self.visible = YES;
	[self loadFromFile:enemyType];
	[self loadAnimations];
	[self addChild:spriteBatch];
	[self repeatAnimation:@"walk"];
	self.sprite.anchorPoint = ccp(0.5, 0);
}

@end
