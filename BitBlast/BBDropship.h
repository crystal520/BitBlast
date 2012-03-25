//
//  BBDropship.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"
#import "EnemyManager.h"
#import "BBBullet.h"
#import "SimpleAudioEngine.h"

@interface BBDropship : BBMovingObject {
    // number of bullets it takes for the dropship to die
	int health;
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
	ChunkLevel level;
}

@property (nonatomic, assign) BOOL enabled, alive;
@property (nonatomic, readonly) ChunkLevel level;

// update
- (void) update:(float)delta;
// getters
- (NSString*) getRandomEnemy;
// setters
- (void) setEnabled:(BOOL)newEnabled;
// actions
- (void) spawnEnemy;
- (void) hitByBullet:(BBBullet*)bullet;
- (void) die;
- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel;

@end
