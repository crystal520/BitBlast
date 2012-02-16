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
	tileOffset = [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(newEnabled && !enabled) {
		velocity = ccp(-200, 0);
	}
	else if(!newEnabled && enabled) {
		
	}
	enabled = newEnabled;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// apply velocity to position
	dummyPosition = ccp(dummyPosition.x + (velocity.x * delta), dummyPosition.y + (velocity.y * delta));
	
	// see if enemy is on screen
	CGPoint enemyScreenPosition = [self convertToWorldSpace:CGPointZero];
	if(enemyScreenPosition.x - self.sprite.contentSize.width * 0.5 < [CCDirector sharedDirector].winSize.width && !enabled) {
		[self setEnabled:YES];
	}
	
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

#pragma mark -
#pragma mark actions
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString *)enemyType {
	// reset the enemy with new parameters
	[self loadFromFile:enemyType];
	[self loadAnimations];
	dummyPosition = ccpAdd(newPosition, ccp(0, tileOffset));
	recycle = NO;
	self.visible = YES;
	[self addChild:spriteBatch];
	[self repeatAnimation:@"walk"];
	self.sprite.anchorPoint = ccp(0.5, 0);
}

@end
