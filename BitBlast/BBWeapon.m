//
//  BBWeapon.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBWeapon.h"

@implementation BBWeapon

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
	// set default offset
	currentOffset = torsoOffset;
	
	// create shots from dictionary
	shots = [NSMutableArray new];
	NSArray *dictShots = [NSArray arrayWithArray:[dict objectForKey:@"shots"]];
	for(NSString *plist in dictShots) {
		BBShot *shot = [[BBShot alloc] initWithFile:plist];
		[shots addObject:shot];
		[shot release];
	}
	
	// load image from dictionary
	//sprite = [CCSprite spriteWithFile:[dict objectForKey:@"sprite"]];
}

- (void) dealloc {
	[super dealloc];
	[shots release];
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
}

- (void) setEnabled:(BOOL)newEnabled {
	// loop through shots and update their enabled flags
	for(BBShot *s in shots) {
		[s setEnabled:newEnabled];
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
		[s setPosition:ccpAdd(newPosition, currentOffset)];
	}
}

#pragma mark - 
#pragma mark update
- (void) update:(float)delta {
	// update each shot
	for(BBShot *shot in shots) {
		[shot update:delta];
	}
}

@end
