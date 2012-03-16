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
#import "ScoreManager.h"
#import "BBWeapon.h"
#import "BBCoinManager.h"
#import "SettingsManager.h"
#import "BBWeaponManager.h"

typedef enum {
	kPlayerUnknown,
	kPlayerRunning,
	kPlayerBeginJump,
	kPlayerMidJump,
	kPlayerEndJump,
	kPlayerDead
} PlayerState;

@interface BBPlayer : BBMovingObject {
	
	float jumpImpulse, speedIncrement, jumpTimer, maxJumpTime;
	CGSize prevSize;
	int chunksToIncrement, curNumChunks, chunkOffset;
	// player's current and previous states
	PlayerState state, prevState;
	// offsets for torso for each frame of running and jumping animation
	NSMutableArray *torsoOffsets;
	// sprite for torso
	CCSprite *torso;
	// node that contains all pieces of player, to be offset in each chunk when switching between them
	CCNode *offsetNode;
}

// initializers
// setup
- (void) setupTorso;
// update
- (void) update:(float)delta;
- (void) updateTorso;
- (void) updateWeapons:(float)delta;
- (void) updateGlobals;
// setters
- (void) setState:(PlayerState)newState;
- (void) setWeaponAngle:(int)newAngle;
// actions
- (void) checkCollisions;
- (void) reset;
- (void) die:(NSString*)reason;
- (void) jump;
- (void) endJump;
- (void) shoot:(CGPoint)touchPos;
- (void) endShoot;

@end
