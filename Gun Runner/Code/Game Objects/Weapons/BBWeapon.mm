//
//  BBWeapon.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBWeapon.h"

@implementation BBWeapon

@synthesize identifier, type;

- (id) init {
	if((self = [super init])) {
		identifier = [NSMutableString new];
		scale = 1;
		gunSpeedMultiplier = 1;
        type = WEAPON_TYPE_UNKNOWN;
	}
	return self;
}

#pragma mark - 
#pragma mark setup
- (void) loadFromFile:(NSString*)filename {
	
	// get dictionary from plist file
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	
	// get values from dictionary
	torsoOffset = CGPointFromString([dict objectForKey:@"torsoOffset"]);
	torsoOffsetUp = CGPointFromString([dict objectForKey:@"torsoUpOffset"]);
	torsoOffsetDown = CGPointFromString([dict objectForKey:@"torsoDownOffset"]);
	straightAngle = [[dict objectForKey:@"straightAngle"] floatValue];
	upAngle = [[dict objectForKey:@"upAngle"] floatValue];
	downAngle = [[dict objectForKey:@"downAngle"] floatValue];
	// set default angle
	[self setAngle:0];
	[identifier setString:filename];
	
	// create shots from dictionary
	if(shots) {
		[shots release];
	}
	shots = [NSMutableArray new];
	NSArray *dictShots = [NSArray arrayWithArray:[dict objectForKey:@"shots"]];
	for(NSString *plist in dictShots) {
		BBShot *shot = [[BBShot alloc] initWithFile:plist];
        shot.type = type;
		[shots addObject:shot];
		[shot release];
	}
	// create lasers from dictionary
	if(lasers) {
		[lasers release];
	}
	lasers = [NSMutableArray new];
	NSArray *dictLasers = [NSArray arrayWithArray:[dict objectForKey:@"lasers"]];
	for(NSString *plist in dictLasers) {
		BBLaser *laser = [[BBLaser alloc] initWithFile:plist];
		[lasers addObject:laser];
		[laser release];
	}
}

- (void) dealloc {
	[identifier release];
	[shots release];
	[lasers release];
	[super dealloc];
}

#pragma mark - 
#pragma mark setters
- (void) setAngle:(float)newAngle {
	// set current offset based on newAngle
	if(newAngle < -15) {
		currentOffset = torsoOffsetDown;
	}
	else if(newAngle > 15) {
		currentOffset = torsoOffsetUp;
	}
	else {
		currentOffset = torsoOffset;
	}
	// loop through shots and update angle
	for(BBShot *s in shots) {
		[s setAngle:newAngle];
	}
	// loop through lasers and update angle
	for(BBLaser *l in lasers) {
		[l setAngle:newAngle];
	}
}

- (void) setEnabled:(BOOL)newEnabled {
	// loop through shots and update their enabled flags
	for(BBShot *s in shots) {
		[s setEnabled:newEnabled];
	}
	// loop through lasers and update their enabled flags
	for(BBLaser *l in lasers) {
		[l setEnabled:newEnabled];
	}
}

- (void) setPlayerSpeed:(float)newPlayerSpeed {
	// loop through shots and update their player speeds
	for(BBShot *s in shots) {
		[s setPlayerSpeed:newPlayerSpeed];
	}
}

- (void) setPosition:(CGPoint)newPosition {
	// loop through shots and update their positions
	for(BBShot *s in shots) {
		[s setPosition:ccpAdd(newPosition, ccpMult(currentOffset, scale))];
	}
	// loop through lasers and update their postions
	for(BBLaser *l in lasers) {
		[l setPosition:ccpAdd(newPosition, ccpMult(currentOffset, scale))];
	}
	position = newPosition;
}

- (void) setScale:(float)newScale {
	// loop through shots and update their scales
	for(BBShot *s in shots) {
		[s setScale:newScale];
	}
	// loop through lasers and update their postions
	for(BBLaser *l in lasers) {
		[l setScale:newScale];
	}
	scale = newScale;
}

- (void) setNode:(CCNode *)node {
	for(BBShot *s in shots) {
		[s setNode:node];
	}
	for(BBLaser *l in lasers) {
		[l setNode:node];
	}
}

- (void) setGunSpeedMultiplier:(float)multiplier {
	gunSpeedMultiplier = multiplier;
}

#pragma mark -
#pragma mark getters
- (CGPoint) getPosition {
	return position;
}

- (BOOL) getIsFiring {
    for(BBShot *s in shots) {
        if([s getIsFiring]) {
            return YES;
        }
    }
    return NO;
}

- (float) getMinTimeToFire {
    float minTime = 10000;
    for(BBShot *s in shots) {
        minTime = MIN(minTime, s.intervalTimer);
    }
    return minTime;
}

- (BOOL) getDidFireBullet {
    for(BBShot *s in shots) {
        if(s.shotFired) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 
#pragma mark update
- (void) update:(float)delta {
	// update each shot
	for(BBShot *s in shots) {
		[s update:delta * gunSpeedMultiplier];
	}
	// update each laser
	for(BBLaser *l in lasers) {
		[l update:delta];
	}
}

#pragma mark -
#pragma mark actions
- (void) clearLasers {
	for(BBLaser *l in lasers) {
		[l clearBullets];
	}
}

- (void) pause {
    for(BBShot *s in shots) {
        [s pause];
    }
    for(BBLaser *l in lasers) {
        [l pause];
    }
}

- (void) resume {
    for(BBShot *s in shots) {
        [s resume];
    }
    for(BBLaser *l in lasers) {
        [l resume];
    }
}

- (void) gameOver {
    for(BBShot *s in shots) {
        [s gameOver];
    }
    for(BBLaser *l in lasers) {
        [l gameOver];
    }
}

@end
