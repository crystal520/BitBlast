//
//  BBShot.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/1/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBShot.h"


@implementation BBShot

#pragma mark -
#pragma mark initializers
- (id) initWithFile:(NSString *)filename {
	if((self = [super init])) {
		
		// get dictionary from plist file
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
		
		// get values from dictionary
		sprite = [[dict objectForKey:@"sprite"] retain];
		rateOfFire = [[dict objectForKey:@"rateOfFire"] floatValue];
		speedRestraints = ccp([[dict objectForKey:@"minSpeed"] floatValue], [[dict objectForKey:@"maxSpeed"] floatValue]);
		angleRestraints = ccp([[dict objectForKey:@"minAngleOffset"] floatValue], [[dict objectForKey:@"maxAngleOffset"] floatValue]);
		lifetimeRestraints = ccp([[dict objectForKey:@"minLifetime"] floatValue], [[dict objectForKey:@"maxLifetime"] floatValue]);
		numBulletsRestraints = ccp([[dict objectForKey:@"minNumBullets"] floatValue], [[dict objectForKey:@"maxNumBullets"] floatValue]);
		blend = [[dict objectForKey:@"blend"] boolValue];
		
		// add angles to fire bullets at
		angles = [NSMutableArray new];
		NSArray *dictAngles = [NSArray arrayWithArray:[dict objectForKey:@"angles"]];
		for(int i=0;i<[dictAngles count];i++) {
			[angles addObject:[NSNumber numberWithFloat:[[dictAngles objectAtIndex:i] floatValue]]];
		}
		
		// add behaviors
		behaviors = [NSMutableArray new];
		NSArray *dictBehaviors = [NSArray arrayWithArray:[dict objectForKey:@"behaviors"]];
		for(NSDictionary *d in dictBehaviors) {
			// create behavior
			BBBehavior *behavior = [[BBBehavior alloc] initWithDictionary:d];
			[behaviors addObject:behavior];
			[behavior release];
		}
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
	[sprite release];
	[angles release];
	[behaviors release];
}

#pragma mark -
#pragma mark setters
- (void) setAngle:(float)newAngle {
	angle = newAngle;
}

- (void) setEnabled:(BOOL)newEnable {
	enabled = newEnable;
}

- (void) setPlayerSpeed:(float)newPlayerSpeed {
	playerSpeed = newPlayerSpeed;
}

- (void) setPosition:(CGPoint)newPosition {
	position = newPosition;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	if(enabled) {
		fireTimer += delta;
		// keep count of fire calls this update
		int fireCounter = 0;
		// fire bullets if the timer is greater than the rate of fire
		while(fireTimer > rateOfFire) {
			[self fire:fireCounter];
			fireTimer -= rateOfFire;
			fireCounter++;
		}
	}
}

#pragma mark -
#pragma mark actions
- (void) fire:(int)updateBulletTime {
	// generate random number of bullets
	int ranNumBullets = CCRANDOM_MIN_MAX(numBulletsRestraints.x, numBulletsRestraints.y);
	// loop through possible angles
	for(NSNumber *n in angles) {
		// loop through number of bullets
		for(int i=0;i<ranNumBullets;i++) {
			// get angle
			float fireAngle = [n floatValue];
			// generate random speed
			float ranSpeed = CCRANDOM_MIN_MAX(speedRestraints.x, speedRestraints.y);
			// generate random angle
			float ranAngle = CCRANDOM_MIN_MAX(angleRestraints.x, angleRestraints.y);
			// generate random lifetime
			float ranLifetime = CCRANDOM_MIN_MAX(lifetimeRestraints.x, lifetimeRestraints.y);
			// create actual fire angle by adding random angle and current angle to fireAngle
			fireAngle = fireAngle + ranAngle + angle;
			// create x speed and y speed based on fireAngle and random speed
			float xSpeed = playerSpeed + cos(CC_DEGREES_TO_RADIANS(fireAngle)) * ranSpeed;
			float ySpeed = sin(CC_DEGREES_TO_RADIANS(fireAngle)) * ranSpeed;
			// get bullet and reset it with new variables
			BBBullet *bullet = [[BulletManager sharedSingleton] getRecycledBullet];
			[bullet resetWithPosition:position velocity:ccp(xSpeed, ySpeed) lifetime:ranLifetime graphic:sprite];
			// loop through behaviors and apply to bullet
			for(BBBehavior *b in behaviors) {
				[b applyToNode:bullet.sprite withAngle:fireAngle];
			}
			// if fire was called more than once this frame, update the bullet based on rateOfFire
			[bullet update:updateBulletTime * rateOfFire];
			// set blend function if needed
			if(blend) {
				[bullet.sprite setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA, GL_ONE}];
			}
		}
	}
}

@end
