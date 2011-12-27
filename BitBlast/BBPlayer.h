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

@interface BBPlayer : BBGameObject {
	
	float jumpImpulse, speed, minSpeed, maxSpeed, speedIncrement, jumpTimer, maxJumpTime;
	int chunksToIncrement, curNumChunks;
	BOOL canJump, jumping;
}

- (void) update:(float)delta;

- (void) die:(NSString*)reason;
- (void) jump;
- (void) endJump;
- (void) shoot;

- (void) collideWithObject:(CCSprite*)collide physicsBody:(b2Body*)collideBody withContact:(b2Contact*)contact;
- (void) shouldCollideWithObject:(CCSprite*)collide physicsBody:(b2Body*)collideBody withContact:(b2Contact*)contact;

@end
