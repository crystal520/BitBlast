//
//  BBBullet.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"

typedef enum {
    kBulletTypeUnknown,
    kBulletTypeShot,
    kBulletTypeLaser
} BulletType;

@interface BBBulletShape : BBGameObjectShape {}
@end

@interface BBBullet : BBMovingObject {
	// how much damage the bullet does upon impact
	float damage;
	// how long the bullet is alive for
	float lifetime, lifeTimer;
	// if the bullet is alive or not
	BOOL recycle;
	// if the bullet is enabled or not
	BOOL enabled;
	// whether this bullet should always be alive
	BOOL indestructible;
    // type of bullet, set by subclasses
    BulletType type;
    // scale this bullet should be on resetting
    float resetScale;
}

@property (nonatomic, readonly) BOOL recycle, enabled;
@property (nonatomic, assign) BOOL indestructible;
@property (nonatomic, assign) float lifeTimer, damage, resetScale;
@property (nonatomic, assign) BulletType type;

// actions
- (void) resetWithPosition:(CGPoint)newPosition velocity:(CGPoint)newVelocity lifetime:(float)newLifetime graphic:(NSString*)newGraphic;
// update
- (void) update:(float)delta;
// setters
- (void) setEnabled:(BOOL)newEnabled;
- (void) setCollisionShape:(NSString*)shapeName;

@end
