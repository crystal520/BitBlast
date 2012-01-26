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

@interface BBPlayer : BBGameObject {
	
	float jumpImpulse, minSpeed, speedIncrement, jumpTimer, maxJumpTime, gravity, shootAngle, tileOffset;
	CGPoint velocity, maxVelocity, dummyPosition, prevDummyPosition;
	CGSize prevSize;
	int chunksToIncrement, curNumChunks, chunkOffset, bitCoins;
	BOOL jumping, touchingPlatform, dead;
	BBWeapon *weapon;
	NSString *currentWeapon;
	//CCSprite *torso, *
}

@property (nonatomic, assign) float gravity;
@property (nonatomic, assign) CGPoint velocity, maxVelocity;
@property (nonatomic, assign) BOOL touchingPlatform, jumping, dead;

- (void) update:(float)delta;

- (void) reset;
- (void) die:(NSString*)reason;
- (void) jump;
- (void) endJump;
- (void) shoot:(CGPoint)touchPos;
- (void) endShoot;
- (void) checkCollisions;

- (CGPoint) positionInChunk:(Chunk*)chunk;
- (NSSet*) positionsInChunk:(Chunk*)chunk;

@end
