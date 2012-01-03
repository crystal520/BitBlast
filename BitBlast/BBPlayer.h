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

@interface BBPlayer : BBGameObject {
	
	float jumpImpulse, minSpeed, maxSpeed, speedIncrement, jumpTimer, maxJumpTime;
	CGPoint velocity, prevPosition;
	CGSize prevSize;
	int chunksToIncrement, curNumChunks;
	BOOL canJump, jumping, touchingPlatform;
}

- (void) update:(float)delta;

- (void) die:(NSString*)reason;
- (void) jump;
- (void) endJump;
- (void) shoot;
- (void) checkCollisions;

- (CGPoint) positionInChunk:(Chunk*)chunk;
- (NSSet*) positionsInChunk:(Chunk*)chunk;

@end
