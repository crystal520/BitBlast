//
//  BBDropship.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"
#import "BBEnemyManager.h"
#import "BBBullet.h"
#import "SimpleAudioEngine.h"
#import "BBMovingCoinManager.h"
#import "BBExplosionManager.h"
#import "BBActionInterval.h"

typedef enum {
	DROPSHIP_STATE_INTRO_MOVING_RIGHT,
	DROPSHIP_STATE_INTRO_MOVING_LEFT,
	DROPSHIP_STATE_ACTIVE
} DropshipState;

typedef enum {
	DROPSHIP_ACTION_TAG_HIT,
    DROPSHIP_ACTION_TAG_HOVER
} DropshipActions;

@interface BBDropshipShape : BBGameObjectShape {}
@end

@interface BBDropship : BBMovingObject {
    // current health of the dropship
	float health;
    // starting health of the dropship
    float maxHealth;
	// rate at which enemies spawn from the dropship
	float spawnRate;
	// timer to spawn enemies based on spawnRate
	float spawnTimer;
	// array of possible enemy types this dropship produces
	NSMutableArray *enemyTypes;
	// whether or not the ship is enabled
	BOOL enabled;
	// whether or not the ship is alive
	BOOL alive;
	// level the dropship is on. used to make sure 2 dropships don't appear on the same level
	ChunkLevel terrainLevel;
	// current state of the dropship
	DropshipState state;
	// position the dropship will be enabled at
	CGPoint finalPos;
	// number of coins dropship gives off upon dying
	int coins;
	// particles for when dropship is hit by bullet
	NSString *particles;
    // reference to a BBExplosionManager
    BBExplosionManager *explosionManager;
    // reference to last bullet that hit this ship
    BBBullet *lastBulletHit;
    // dictionary of sounds to play
    NSDictionary *sounds;
    // reference to BBDropshipManager's backNode
    CCNode *switchNode;
    // chance to drop miniboss trigger
    float minibossChance;
    // sound when dropship is hit by bullet
    CDSoundSource *hitSound;
    // level of dropship
    int level;
    // base amount of health
    float baseHealth;
    // amount health increases per level
    float healthIncrease;
    // base spawn rate
    float baseSpawnRate;
    // amount spawn rate decreases per level
    float spawnRateIncrease;
    // base amount of coins
    int baseCoins;
    // amount coins increase per level
    int coinsIncrease;
}

@property (nonatomic, assign) BOOL enabled, alive;
@property (nonatomic, readonly) ChunkLevel terrainLevel;
@property (nonatomic, assign) BBExplosionManager *explosionManager;
@property (nonatomic, assign) CCNode *switchNode;
@property (nonatomic, assign) int level;

// update
- (void) update:(float)delta;
// getters
- (NSString*) getRandomEnemy;
- (BOOL) isAtFullHealth;
// setters
- (void) setEnabled:(BOOL)newEnabled;
- (void) setCollisionShape:(NSString*)newShape;
- (void) setLevel:(int)newLevel;
// actions
- (void) spawnEnemy;
- (void) hitByBullet:(BBBullet*)bullet withContact:(GB2Contact*)contact;
- (void) die;
- (void) hover;
- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel;

@end
