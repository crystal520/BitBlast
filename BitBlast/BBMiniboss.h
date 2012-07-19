//
//  BBMiniboss.h
//  GunRunner
//
//  Created by Kristian Bauer on 7/18/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingObject.h"
#import "BBBullet.h"
#import "SimpleAudioEngine.h"
#import "BBMovingCoinManager.h"
#import "BBExplosionManager.h"
#import "BBActionInterval.h"
#import "SettingsManager.h"

typedef enum {
    MINIBOSS_STATE_MOVE_RIGHT,
    MINIBOSS_STATE_MOVE_LEFT,
    MINIBOSS_STATE_THINKING,
    MINIBOSS_STATE_SHOOTING,
    MINIBOSS_STATE_CHARGE_LEFT,
    MINIBOSS_STATE_CHARGE_RETURN,
    MINIBOSS_STATE_LASER
} MinibossState;

typedef enum {
    MINIBOSS_ACTION_TAG_HIT
} MinibossActionTags;

@interface BBMinibossShape : BBGameObjectShape {}
@end

@interface BBMiniboss : BBMovingObject {
    // number of bullets it takes for the dropship to die
	float health;
	// whether or not the ship is enabled
	BOOL enabled;
	// whether or not the ship is alive
	BOOL alive;
	// position the dropship will be enabled at
	CGPoint finalPos;
	// number of coins dropship gives off upon dying
	int coins;
	// current state of the miniboss
	MinibossState state;
	// particles for when dropship is hit by bullet
	NSString *particles;
    // reference to a BBExplosionManager
    BBExplosionManager *explosionManager;
    // reference to last bullet that hit this ship
    BBBullet *lastBulletHit;
    // array of weapons this miniboss has at its disposal
    NSMutableArray *weapons;
}

@property (nonatomic, assign) BOOL enabled, alive;
@property (nonatomic, assign) BBExplosionManager *explosionManager;

// update
- (void) update:(float)delta;
// setters
- (void) setEnabled:(BOOL)newEnabled;
- (void) setCollisionShape:(NSString*)newShape;
// actions
- (void) hitByBullet:(BBBullet*)bullet;
- (void) die;
- (void) hover;
- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel;

@end
