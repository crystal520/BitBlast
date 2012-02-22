//
//  BBEnemy.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"
#import "ChunkManager.h"

@interface BBEnemy : BBGameObject {
	// type of enemy
	NSString* type;
    // damage the enemy can take before it's considered dead
	float health;
	// whether or not the enemy can be recycled
	BOOL recycle;
	// whether or not the enemy is enabled
	BOOL enabled;
	// velocity of the enemy
	CGPoint velocity;
	// y offset from tile enemy is currently on
	float tileOffset;
	// dummy position for handling multiple resolutions
	CGPoint dummyPosition;
	// previous dummy position, usually for collision detecting
	CGPoint prevDummyPosition;
}

@property (nonatomic, assign) BOOL recycle, enabled;
@property (nonatomic, assign) float tileOffset;

// setters
- (void) setEnabled:(BOOL)newEnabled;
// update
- (void) update:(float)delta;
// actions
- (void) reset;
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString*)enemyType;

@end
