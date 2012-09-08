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
#import "BBEnemyManager.h"
#import "ChunkManager.h"
#import "BBWeapon.h"
#import "BBWeaponManager.h"

typedef enum {
    MINIBOSS_STATE_UNKNOWN,
    MINIBOSS_STATE_MOVE_RIGHT,
    MINIBOSS_STATE_MOVE_LEFT,
    MINIBOSS_STATE_ACTIVE,
    MINIBOSS_STATE_CHARGE_CHARGING,
    MINIBOSS_STATE_CHARGE_LEFT,
    MINIBOSS_STATE_CHARGE_RIGHT
} MinibossState;

typedef enum {
    MINIBOSS_ACTION_TAG_HIT = 100,
    MINIBOSS_ACTION_TAG_HOVER,
    MINIBOSS_ACTION_TAG_CHASE,
    MINIBOSS_ACTION_TAG_CALL_SPAWN_ENEMY,
    MINIBOSS_ACTION_TAG_CALL_CHANGE_WEAPON,
    MINIBOSS_ACTION_TAG_CALL_CHASE,
    MINIBOSS_ACTION_TAG_CALL_CHARGE,
    MINIBOSS_ACTION_TAG_CALL_SHOW_HEALTH
} MinibossActionTags;

@interface BBMinibossShape : BBGameObjectShape {}
@end

@interface BBMiniboss : BBMovingObject {
    // amount of damage the miniboss can take before it dies
	float health, initialHealth;
	// whether or not the miniboss is enabled
	BOOL enabled;
	// whether or not the miniboss is alive
	BOOL alive;
	// position the miniboss will be enabled at
	CGPoint finalPos;
	// number of coins miniboss gives off upon dying
	int coins;
	// current state of the miniboss
	MinibossState state;
	// particles for when miniboss is hit by bullet
	NSString *particles;
    // reference to a BBExplosionManager
    BBExplosionManager *explosionManager;
    // reference to last bullet that hit this miniboss
    BBBullet *lastBulletHit;
    // current ai stage, based on health
    int currentAIStage;
    // current ChunkLevel this miniboss is on
    ChunkLevel level;
    // reference to BBMinibossManager's backNode
    CCNode *switchNode;
    // greatest distance yet between player and miniboss (used in chasing)
    float greatestDistance;
    // keep track of current charge info
    NSMutableDictionary *chargeInfo;
}

@property (nonatomic, assign) BOOL enabled, alive;
@property (nonatomic, assign) BBExplosionManager *explosionManager;
@property (nonatomic, assign) ChunkLevel level;
@property (nonatomic, assign) CCNode *switchNode;
@property (nonatomic, assign) int currentAIStage;

// update
- (void) update:(float)delta;
- (void) updateWeapons:(float)delta;
- (void) checkDeath;
// setters
- (void) setEnabled:(BOOL)newEnabled;
- (void) setCollisionShape:(NSString*)newShape;
// getters
- (CGPoint) getLevelOffset:(ChunkLevel)chunkLevel;
- (NSDictionary*) getAIStage;
// actions
- (void) hitByBullet:(BBBullet*)bullet;
- (void) die;
- (void) hover;
- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel;
- (void) spawnEnemy:(NSDictionary*)enemyInfo;
- (void) chase:(NSDictionary*)chaseInfo;
- (void) changeWeapon:(NSDictionary*)weaponInfo;
- (void) charge;
- (void) showHealth;

@end
