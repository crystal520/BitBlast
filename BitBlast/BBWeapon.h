//
//  BBWeapon.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBShot.h"
#import "BBLaser.h"

@interface BBWeapon : NSObject {
	// unique identifier
	NSMutableString *identifier;
	// array of shots this weapon fires
	NSMutableArray *shots;
	// array of lasers this weapon has
	NSMutableArray *lasers;
	// offsets for different torso states
	CGPoint currentOffset, torsoOffset, torsoOffsetUp, torsoOffsetDown, position;
	// angles for firing up, down, and straight
	float upAngle, downAngle, straightAngle, scale;
	// current gun speed multiplier
	float gunSpeedMultiplier;
    // whether this weapon is friendly or enemy
    WeaponType type;
}

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, assign) WeaponType type;

// setup
- (void) loadFromFile:(NSString*)filename;
// setters
- (void) setAngle:(float)newAngle;
- (void) setEnabled:(BOOL)newEnabled;
- (void) setPlayerSpeed:(float)newPlayerSpeed;
- (void) setPosition:(CGPoint)newPosition;
- (void) setScale:(float)newScale;
- (void) setNode:(CCNode*)node;
- (void) setGunSpeedMultiplier:(float)multiplier;
// getters
- (CGPoint) getPosition;
// update
- (void) update:(float)delta;
// actions
- (void) clearLasers;
- (void) pause;
- (void) resume;
- (void) gameOver;

@end
