//
//  BBLaser.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBBehavior.h"
#import "BulletManager.h"

@interface BBLaser : NSObject {
	// graphic that laser uses
	NSString *sprite;
    // array of angles to shoot lasers from
	NSMutableArray *angles;
	// array of behaviors
	NSMutableArray *behaviors;
	// angle the laser is currently being fired at. based on the torso
	float angle;
	// flag for whether this laser is enabled and firing
	BOOL enabled;
	// position that laser starts from
	CGPoint position;
	// whether this laser is alpha blended
	BOOL blend;
	// each laser is a bullet that stays on screen and follows the player
	NSMutableArray *lasers;
}

// initializers
- (id) initWithFile:(NSString*)filename;
// setters
- (void) setAngle:(float)newAngle;
- (void) setEnabled:(BOOL)newEnabled;
- (void) setPosition:(CGPoint)newPosition;
// update
- (void) update:(float)delta;
// actions
- (void) clearBullets;

@end
