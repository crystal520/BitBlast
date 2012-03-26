//
//  BBBullet.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBBullet.h"


@implementation BBBullet

@synthesize recycle, enabled, lifeTimer, damage, indestructible;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
		damage = 1;
		enabled = NO;
		needsPlatformCollisions = NO;
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
	// see if bullet is dead yet
	lifeTimer += delta;
	if(lifeTimer >= lifetime) {
		[self setEnabled:NO];
	}
	// update if enabled
	if(enabled) {
		[super update:delta];
	}
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled && !indestructible) {
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
