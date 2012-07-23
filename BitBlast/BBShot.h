//
//  BBShot.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/1/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBBehavior.h"
#import "BulletManager.h"
#import "SimpleAudioEngine.h"

@interface BBShot : NSObject {
	// graphic that bullets use
	NSString *sprite;
    // array of angles to shoot bullets from
	NSMutableArray *angles;
	// rate that bullets are fired at and timer
	float rateOfFire, fireTimer;
	// min and max speed of bullets
	CGPoint speedRestraints;
	// min and max angle offset
	CGPoint angleRestraints;
	// min and max lifetime
	CGPoint lifetimeRestraints;
	// min and max number of bullets fired at once
	CGPoint numBulletsRestraints;
	// array of behaviors
	NSMutableArray *behaviors;
	// angle the shot is currently being fired at. based on the torso
	float angle;
	// flag for whether this shot is enabled and firing
	BOOL enabled;
	// player's x speed so bullets fired don't go slower than the player
	float playerSpeed;
	// damage a bullet from this shot will do
	float damage;
	// position that shot starts from
	CGPoint position;
	// whether this shot is alpha blended
	BOOL blend;
	// sound to play when bullet is fired
	NSString *sound;
    // volume of sound
    float soundVolume;
	// particle system
	CCParticleSystemQuad *particles;
	// scale of the bullets fired
	float scale;
    // collision shape to use for a bullet
    NSString *collisionShapeString;
}

// initializers
- (id) initWithFile:(NSString*)filename;
// setters
- (void) setAngle:(float)newAngle;
- (void) setEnabled:(BOOL)newEnabled;
- (void) setPlayerSpeed:(float)newPlayerSpeed;
- (void) setPosition:(CGPoint)newPosition;
- (void) setScale:(float)newScale;
- (void) setNode:(CCNode*)node;
// update
- (void) update:(float)delta;
// actions
- (void) fire:(int)updateBulletTime;
- (void) pause;
- (void) resume;
- (void) gameOver;

@end
