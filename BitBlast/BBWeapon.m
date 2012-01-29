//
//  BBWeapon.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBWeapon.h"
#import "BBPlayer.h"

@implementation BBWeapon

@synthesize angle;

- (void) loadFromFile:(NSString*)filename {
	
	// get dictionary from plist file
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	
	// grab values from dictionary
	rateOfFire = [[dict objectForKey:@"rateOfFire"] floatValue];
	numBulletsToFire = [[dict objectForKey:@"numBulletsToFire"] floatValue];
	minVelocity = [[dict objectForKey:@"minSpeed"] floatValue];
	maxVelocity = [[dict objectForKey:@"maxSpeed"] floatValue];
	lifetime = ccp([[[dict objectForKey:@"lifetime"] objectForKey:@"min"] floatValue], [[[dict objectForKey:@"lifetime"] objectForKey:@"max"] floatValue]);
	angleOffset = ccp([[[dict objectForKey:@"angle"] objectForKey:@"min"] floatValue], [[[dict objectForKey:@"angle"] objectForKey:@"max"] floatValue]);
	
	// load image from dictionary
	graphic = [[dict objectForKey:@"graphic"] retain];
	sprite = [CCSprite spriteWithFile:[dict objectForKey:@"graphic"]];
}

- (void) dealloc {
	[super dealloc];
	[graphic release];
}

- (void) start {
	// unschedule and then schedule shoot function based on rateOfFire
	[self unscheduleAllSelectors];
	[self schedule:@selector(shoot) interval:rateOfFire];
}

- (void) stop {
	[self unscheduleAllSelectors];
}

- (void) shoot {
	for(int i=0;i<numBulletsToFire;i++) {
		// get parent as player
		BBPlayer *player = (BBPlayer*)(self.parent);
		// generate a random velocity for the new bullet
		float ranVelocity = CCRANDOM_MIN_MAX(minVelocity, maxVelocity) + player.velocity.x;
		float ranAngle = CC_DEGREES_TO_RADIANS(CCRANDOM_MIN_MAX(angleOffset.x, angleOffset.y) + angle);
		float ranXVelocity = cos(ranAngle) * ranVelocity;
		float ranYVelocity = sin(ranAngle) * ranVelocity;
		// get random lifetime
		float ranLifetime = CCRANDOM_MIN_MAX(lifetime.x, lifetime.y);
		// get a bullet from the bullet manager
		BBBullet *bullet = [[BulletManager sharedSingleton] getRecycledBullet];
		[bullet resetWithPosition:self.parent.position velocity:ccp(ranXVelocity, ranYVelocity) lifetime:ranLifetime graphic:graphic];
	}
}

@end
