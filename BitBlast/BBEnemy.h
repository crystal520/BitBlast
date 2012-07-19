//
//  BBEnemy.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"
#import "BBBullet.h"
#import "SettingsManager.h"
#import "SimpleAudioEngine.h"
#import "BBMovingCoinManager.h"

typedef enum {
	ENEMY_ACTION_TAG_HIT
} EnemyActions;

@interface BBEnemyShape : BBGameObjectShape {}
@end

@interface BBEnemy : BBMovingObject {
	// type of enemy
	NSString* type;
    // damage the enemy can take before it's considered dead
	float health;
	// whether or not the enemy can be recycled
	BOOL recycle;
	// whether or not the enemy is enabled
	BOOL enabled;
	// whether or not the enemy has died
	BOOL alive;
	// number of coins enemy gives off when it is killed
	int coins;
    // reference to last bullet that hit this enemy
    BBBullet *lastBulletHit;
}

@property (nonatomic, assign) BOOL recycle, enabled, alive;

// setters
- (void) setEnabled:(BOOL)newEnabled;
- (void) setCollisionShape:(NSString *)shapeName;
// update
- (void) update:(float)delta;
// actions
- (void) reset;
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString*)enemyType;
- (void) hitByBullet:(BBBullet*)bullet;
- (void) die;

@end
