//
//  BBPlayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"
#import "ChunkManager.h"
#import "ScoreManager.h"
#import "BBWeapon.h"

typedef enum {
	kPlayerUnknown,
	kPlayerRunning,
	kPlayerBeginJump,
	kPlayerMidJump,
	kPlayerEndJump,
	kPlayerDead
} PlayerState;

@interface BBPlayer : BBGameObject {
	
	float jumpImpulse, minSpeed, speedIncrement, jumpTimer, maxJumpTime, gravity, tileOffset;
	CGPoint velocity, maxVelocity, dummyPosition, prevDummyPosition;
	CGSize prevSize;
	int chunksToIncrement, curNumChunks, chunkOffset, bitCoins;
	BOOL jumping, touchingPlatform, dead;
	// array of currently equipped weapons
	NSMutableArray *weapons;
	// player's current and previous states
	PlayerState state, prevState;
	// offsets for torso for each frame of running and jumping animation
	NSMutableArray *torsoOffsets;
	// sprite for torso
	CCSprite *torso;
	// node that contains all pieces of player, to be offset in each chunk when switching between them
	CCNode *offsetNode;
}

@property (nonatomic, assign) float gravity;
@property (nonatomic, assign) CGPoint velocity, maxVelocity;
@property (nonatomic, assign) BOOL touchingPlatform, jumping, dead;

// initializers
// setup
- (void) setupTorso;
- (void) setupWeapons;
// update
- (void) update:(float)delta;
- (void) updateTorso;
- (void) updateWeapons:(float)delta;
// setters
- (void) setState:(PlayerState)newState;
- (void) setWeaponAngle:(int)newAngle;
// actions
- (void) reset;
- (void) die:(NSString*)reason;
- (void) jump;
- (void) endJump;
- (void) shoot:(CGPoint)touchPos;
- (void) endShoot;
- (void) checkCollisions;
// convenience
- (CGPoint) positionInChunk:(Chunk*)chunk;
- (NSSet*) positionsInChunk:(Chunk*)chunk;

@end
