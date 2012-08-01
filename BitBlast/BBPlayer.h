//
//  BBPlayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"
#import "ChunkManager.h"
#import "BBWeapon.h"
#import "BBCoinManager.h"
#import "SettingsManager.h"
#import "BBWeaponManager.h"
#import "EnemyManager.h"
#import "SimpleAudioEngine.h"
#import "BBPowerupManager.h"
#import "BBMinibossManager.h"

typedef enum {
	kPlayerUnknown,
	kPlayerShop,
	kPlayerRunning,
	kPlayerBeginJump,
	kPlayerMidJump,
	kPlayerEndJump,
	kPlayerDead
} PlayerState;

@interface BBPlayerShape : BBGameObjectShape {}
@end

@interface BBPlayer : BBMovingObject {
	
	float jumpImpulse, speedIncrement, jumpTimer, maxJumpTime, invincibleTime;
    CGPoint initialGravity;
	CGSize prevSize;
	int chunksToIncrement, curNumChunks, startingHealth;
	// player's current and previous states
	PlayerState state, prevState;
	// offsets for torso for each frame of running and jumping animation
	NSMutableArray *torsoOffsets;
	// sprites for torso and legs
	CCSprite *torso;
	BBGameObject *legs;
    // collision shapes for torso and legs
    BBPlayerShape *torsoShape;
    BBPlayerShape *legsShape;
	// node that contains all pieces of player, to be offset in each chunk when switching between them
	CCNode *offsetNode;
	// number of times the player can get hit before dying
	int health;
	// total player distance prior to the current run. for calculating total distance
	int previousTotalDistance;
	// whether or not the player is in the intro
	BOOL introEnabled;
	// coin multiplier for the current run
	int coinMultiplier;
	// speed multiplier for the current run
	float speedMultiplier;
    // whether or not the player just fell off a platform
    BOOL fellOffPlatform;
    // whether or not double jump is enabled
    BOOL doubleJumpEnabled;
    // whether or not the player is invincible
    BOOL invincible;
    // timer to count down player being invincible
    float invincibleTimer;
}

@property (nonatomic, readonly) int health;
@property (nonatomic, assign) BOOL doubleJumpEnabled;

// initializers
// setup
- (void) setupTorso;
- (void) setupLegs;
// update
- (void) update:(float)delta;
- (void) updateTorso;
- (void) updateWeapons:(float)delta;
- (void) updateGlobals;
// setters
- (void) setState:(PlayerState)newState;
- (void) setWeaponAngle:(int)newAngle;
// actions
- (void) addCoins:(int)coins;
- (void) playIntro;
- (void) reset;
- (void) die:(ReasonForDeath)reason;
- (void) jump;
- (void) endJump;
- (void) jumpDown;
- (void) shoot:(CGPoint)touchPos;
- (void) endShoot;
- (void) attemptToLoseHealth;
// collisions
- (void) collideWithCoin:(BBCoin*)coin;
- (void) collideWithMovingCoin:(BBMovingCoin*)coin;
- (void) hitByBullet:(BBBullet*)bullet;
- (void) collideWithMiniboss:(BBMiniboss*)miniboss;

@end
