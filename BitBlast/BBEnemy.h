//
//  BBEnemy.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"
#import "BBBullet.h"
#import "SettingsManager.h"
#import "SimpleAudioEngine.h"
#import "BBMovingCoinManager.h"

@interface BBEnemy : BBMovingObject {
	// type of enemy
	NSString* type;
    // damage the enemy can take before it's considered dead
	float health;
	// whether or not the enemy can be recycled
	BOOL recycle;
	// whether or not the enemy is enabled
	BOOL enabled;
	// whether or not the enemy has died
	BOOL alive;
}

@property (nonatomic, assign) BOOL recycle, enabled, alive;

// setters
- (void) setEnabled:(BOOL)newEnabled;
// update
- (void) update:(float)delta;
// actions
- (void) reset;
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString*)enemyType;
- (void) hitByBullet:(BBBullet*)bullet;
- (void) die;

@end
