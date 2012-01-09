//
//  BBWeapon.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBWeapon.h"


@implementation BBWeapon

@synthesize angle;

- (void) loadFromFile:(NSString*)filename {
	
	// get dictionary from plist file
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	
	// grab values from dictionary
	rateOfFire = [[dict objectForKey:@"rateOfFire"] floatValue];
	numBulletsToFire = [[dict objectForKey:@"numBulletsToFire"] floatValue];
	minVelocity = ccp([[[dict objectForKey:@"minSpeed"] objectForKey:@"x"] floatValue], [[[dict objectForKey:@"minSpeed"] objectForKey:@"y"] floatValue]);
	maxVelocity = ccp([[[dict objectForKey:@"maxSpeed"] objectForKey:@"x"] floatValue], [[[dict objectForKey:@"maxSpeed"] objectForKey:@"y"] floatValue]);
	lifetime = ccp([[[dict objectForKey:@"lifetime"] objectForKey:@"min"] floatValue], [[[dict objectForKey:@"lifetime"] objectForKey:@"max"] floatValue]);
	
	// load image from dictionary
	sprite = [CCSprite spriteWithFile:[dict objectForKey:@"graphic"]];
	
	// unschedule and then schedule shoot function based on rateOfFire
	[self unscheduleAllSelectors];
	[self schedule:@selector(shoot) interval:rateOfFire];
}

- (void) shoot {
	for(int i=0;i<numBulletsToFire;i++) {
		// generate a random velocity for the new bullet
		CGPoint ranVelocity = ccp(CCRANDOM_MIN_MAX(minVelocity.x, maxVelocity.x), CCRANDOM_MIN_MAX(minVelocity.y, maxVelocity.y));
		// get random lifetime
		float ranLifetime = CCRANDOM_MIN_MAX(lifetime.x, lifetime.y);
		// get a bullet from the bullet manager
		BBBullet *bullet = [[BulletManager sharedSingleton] getRecycledBullet];
		[bullet resetWithPosition:self.parent.position velocity:ranVelocity lifetime:ranLifetime graphic:@"bullet.png"];
	}
}

@end
