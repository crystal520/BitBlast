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

@interface BBWeapon : NSObject {
	// array of shots this weapon fires
	NSMutableArray *shots;
	// offsets for different torso states
	CGPoint currentOffset, torsoOffset, torsoOffsetUp, torsoOffsetDown;
	// angles for firing up, down, and straight
	float upAngle, downAngle, straightAngle;
}

// setup
- (void) loadFromFile:(NSString*)filename;
// setters
- (void) setAngle:(float)newAngle;
- (void) setEnabled:(BOOL)newEnabled;
- (void) setPlayerSpeed:(float)newPlayerSpeed;
- (void) setPosition:(CGPoint)newPosition;
// update
- (void) update:(float)delta;

@end
