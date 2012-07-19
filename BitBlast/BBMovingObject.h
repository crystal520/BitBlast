//
//  BBMovingObject.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/4/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"
#import "ChunkManager.h"

@interface BBMovingObject : BBGameObject {
	// gravity to be applied to the object's velocity
	CGPoint gravity;
    // how fast the object is moving
	CGPoint velocity;
	// maximum velocity the object can move
	CGPoint maxVelocity;
	// minimum velocity the object can move
	CGPoint minVelocity;
	// offset from tiles
	CGPoint tileOffset;
	// whether or not the object is touching a platform
	BOOL touchingPlatform;
	// whether or not the object is jumping
	BOOL jumping;
	// whether or not the velocity should be clamped
	BOOL clampVelocity;
	// whether or not the object is checked against platforms
	BOOL needsPlatformCollisions;
}

@property (nonatomic, assign) BOOL touchingPlatform, jumping;
@property (nonatomic, assign) CGPoint gravity, velocity, maxVelocity, minVelocity;

- (id) initWithFile:(NSString *)filename;
- (void) setDefaults;
// update
- (void) update:(float)delta;
// actions
- (void) checkPlatformCollisions:(float)delta;
// convenience
- (CGPoint) positionInChunk:(Chunk*)chunk;

@end
