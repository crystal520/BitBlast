//
//  BBBullet.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBBullet.h"


@implementation BBBullet

@synthesize recycle, lifeTimer;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
	}
	
	return self;
}

- (void) resetWithPosition:(CGPoint)newPosition velocity:(CGPoint)newVelocity lifetime:(float)newLifetime graphic:(NSString*)newGraphic {
	// reset the bullet with new parameters
	self.position = newPosition;
	velocity = newVelocity;
	recycle = NO;
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
	self.position = ccp(self.position.x + velocity.x * delta, self.position.y + velocity.y * delta);
	// see if bullet is dead yet
	lifeTimer += delta;
	if(lifeTimer >= lifetime) {
		recycle = YES;
		self.visible = NO;
		[sprite stopAllActions];
		[self removeChild:sprite cleanup:YES];
	}
}

@end
