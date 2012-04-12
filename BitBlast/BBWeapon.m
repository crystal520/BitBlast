//
//  BBWeapon.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBWeapon.h"

@implementation BBWeapon

@synthesize identifier;

- (id) init {
	if((self = [super init])) {
		identifier = [NSMutableString new];
		scale = 1;
	}
	return self;
}

#pragma mark - 
#pragma mark setup
- (void) loadFromFile:(NSString*)filename {
	
	// get dictionary from plist file
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	
	// get values from dictionary
	torsoOffset = ccp([[[dict objectForKey:@"torsoOffset"] objectForKey:@"x"] floatValue], [[[dict objectForKey:@"torsoOffset"] objectForKey:@"y"] floatValue]);
	torsoOffsetUp = ccp([[[dict objectForKey:@"torsoUpOffset"] objectForKey:@"x"] floatValue], [[[dict objectForKey:@"torsoUpOffset"] objectForKey:@"y"] floatValue]);
	torsoOffsetDown = ccp([[[dict objectForKey:@"torsoDownOffset"] objectForKey:@"x"] floatValue], [[[dict objectForKey:@"torsoDownOffset"] objectForKey:@"y"] floatValue]);
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
	
	// load image from dictionary
	//sprite = [CCSprite spriteWithFile:[dict objectForKey:@"sprite"]];
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
	if(newAngle == 0) {
		currentOffset = torsoOffset;
	}
	else if(newAngle > 0) {
		currentOffset = torsoOffsetUp;
	}
	else {
		currentOffset = torsoOffsetDown;
	}
	// set new shot angle based on newAngle
	float newShotAngle = straightAngle;
	if(newAngle > 0) {
		newShotAngle = upAngle;
	}
	else if(newAngle < 0) {
		newShotAngle = downAngle;
	}
	// loop through shots and update angle
	for(BBShot *s in shots) {
		[s setAngle:newShotAngle];
	}
	// loop through lasers and update angle
	for(BBLaser *l in lasers) {
		[l setAngle:newShotAngle];
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

#pragma mark -
#pragma mark getters
- (CGPoint) getPosition {
	return position;
}

#pragma mark - 
#pragma mark update
- (void) update:(float)delta {
	// update each shot
	for(BBShot *s in shots) {
		[s update:delta];
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

@end
