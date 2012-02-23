//
//  BBBullet.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBBullet.h"


@implementation BBBullet

@synthesize recycle, enabled, lifeTimer, damage;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
		damage = 10;
		enabled = NO;
	}
	
	return self;
}

- (void) resetWithPosition:(CGPoint)newPosition velocity:(CGPoint)newVelocity lifetime:(float)newLifetime graphic:(NSString*)newGraphic {
	// reset the bullet with new parameters
	dummyPosition = newPosition;
	velocity = newVelocity;
	recycle = NO;
	[self setEnabled:YES];
	lifeTimer = 0;
	lifetime = newLifetime;
	self.visible = YES;
	sprite = [CCSprite spriteWithFile:newGraphic];
	[self addChild:sprite];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// update bullet's position with velocity
	dummyPosition = ccp(dummyPosition.x + velocity.x * delta, dummyPosition.y + velocity.y * delta);
    self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	// see if bullet is dead yet
	lifeTimer += delta;
	if(lifeTimer >= lifetime) {
		[self setEnabled:NO];
	}
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
		recycle = YES;
		self.visible = NO;
		[sprite stopAllActions];
		[self removeChild:sprite cleanup:YES];
	}
	else if(!enabled && newEnabled) {
		
	}
	enabled = newEnabled;
}

@end
