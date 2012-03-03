//
//  BBDropship.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"
#import "EnemyManager.h"
#import "BBBullet.h"

@interface BBDropship : BBGameObject {
    // number of bullets it takes for the dropship to die
	int health;
	// rate at which enemies spawn from the dropship
	float spawnRate;
	// timer to spawn enemies based on spawnRate
	float spawnTimer;
	// array of possible enemy types this dropship produces
	NSMutableArray *enemyTypes;
	// how fast the ship is moving
	CGPoint velocity;
	// whether or not the ship is enabled
	BOOL enabled;
}

@property (nonatomic, assign) BOOL enabled;

// update
- (void) update:(float)delta;
// getters
- (NSString*) getRandomEnemy;
// setters
- (void) setVelocity:(float)newVelocity;
- (void) setEnabled:(BOOL)newEnabled;
// actions
- (void) spawnEnemy;
- (void) hitByBullet:(BBBullet*)bullet;

@end
