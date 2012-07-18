//
//  BBBullet.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBBullet.h"

@implementation BBBulletShape

@end

@implementation BBBullet

@synthesize recycle, enabled, lifeTimer, damage, indestructible, type, resetScale;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
		damage = 1;
		enabled = NO;
		needsPlatformCollisions = NO;
        type = kBulletTypeUnknown;
        resetScale = 1;
	}
	
	return self;
}

- (void) resetWithPosition:(CGPoint)newPosition velocity:(CGPoint)newVelocity lifetime:(float)newLifetime graphic:(NSString*)newGraphic {
	// reset the bullet with new parameters
	dummyPosition = newPosition;
    self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	velocity = newVelocity;
	recycle = NO;
	[self setEnabled:YES];
	lifeTimer = 0;
	lifetime = newLifetime;
	self.visible = YES;
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:newGraphic]];
	[self setScale:resetScale];
	[self setColor:ccc3(255, 255, 255)];
	[self setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
	[self setOpacity:255];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// see if bullet is dead yet
	if(enabled) {
		lifeTimer += delta;
		if(lifeTimer >= lifetime) {
			[self setEnabled:NO];
		}
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
		[self stopAllActions];
		[collisionShape setActive:NO];
	}
	else if(!enabled && newEnabled) {
		[collisionShape setActive:YES];
        // update here so that physics has correct position (this prevents dropship hit particles from appearing at the barrel of the gun when using the vulcan cannon)
        [collisionShape updatePhysicsFromCC];
	}
	enabled = newEnabled;
}

- (void) setCollisionShape:(NSString *)shapeName {
    if(collisionShape) {
        if(![collisionShape.shapeName isEqualToString:shapeName]) {
            [collisionShape destroyBody];
            collisionShape = [[BBBulletShape alloc] initWithDynamicBody:shapeName node:self];
            [collisionShape setActive:NO];
        }
    }
    else {
        collisionShape = [[BBBulletShape alloc] initWithDynamicBody:shapeName node:self];
        [collisionShape setActive:NO];
    }
}

@end
