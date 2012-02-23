//
//  BBBullet.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"

@interface BBBullet : BBGameObject {
	// how fast the bullet moves in both x and y directions
    CGPoint velocity;
	// how much damage the bullet does upon impact
	float damage;
	// how long the bullet is alive for
	float lifetime, lifeTimer;
	// if the bullet is alive or not
	BOOL recycle;
	// if the bullet is enabled or not
	BOOL enabled;
}

@property (nonatomic, readonly) BOOL recycle, enabled;
@property (nonatomic, assign) float lifeTimer;
@property (nonatomic, assign) float damage;

// actions
- (void) resetWithPosition:(CGPoint)newPosition velocity:(CGPoint)newVelocity lifetime:(float)newLifetime graphic:(NSString*)newGraphic;
// update
- (void) update:(float)delta;
// setters
- (void) setEnabled:(BOOL)newEnabled;

@end
