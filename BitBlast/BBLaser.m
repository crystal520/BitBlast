//
//  BBLaser.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBLaser.h"


@implementation BBLaser

#pragma mark -
#pragma mark initializers
- (id) initWithFile:(NSString *)filename {
	if((self = [super init])) {
		
		// get dictionary from plist file
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
		
		// get values from dictionary
		sprite = [[dict objectForKey:@"sprite"] retain];
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
		
		lasers = [NSMutableArray new];
		
		// loop through angles and get a bullet for each one
		for(int i=0,j=[angles count];i<j;i++) {
			BBBullet *laser = [[BulletManager sharedSingleton] getRecycledBullet];
			[laser resetWithPosition:ccp(0,0) velocity:ccp(0,0) lifetime:100 graphic:sprite];
			// set tex params so it repeats horizontally
			ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
			[laser.sprite.texture setTexParameters:&params];
			// set size equal to the width of the screen
			CGRect texRect = laser.sprite.textureRect;
			laser.sprite.textureRect = CGRectMake(texRect.origin.x, texRect.origin.y, [ResolutionManager sharedSingleton].size.width, texRect.size.height);
			// set anchor point so it starts at the end of the gun
			laser.sprite.anchorPoint = ccp(0, 0.5);
			// set blend function if needed
			if(blend) {
				[laser.sprite setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA, GL_ONE}];
			}
			// store in array for later use
			[lasers addObject:laser];
		}
	}
	return self;
}

- (void) dealloc {
	[lasers release];
	[sprite release];
	[angles release];
	[behaviors release];
	[super dealloc];
}

#pragma mark -
#pragma mark setters
- (void) setAngle:(float)newAngle {
	angle = newAngle;
}

- (void) setEnabled:(BOOL)newEnable {
	enabled = newEnable;
}

- (void) setPosition:(CGPoint)newPosition {
	position = newPosition;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	if(enabled) {
		// loop through and update lasers
		for(int i=0,j=[angles count];i<j;i++) {
			BBBullet *laser = [lasers objectAtIndex:i];
			// make sure laser never "dies"
			laser.lifeTimer = 0;
			// set laser's position
			laser.position = position;
			// set angle based on this laser's angle and the angles array
			laser.rotation = -angle + [[angles objectAtIndex:i] floatValue];
		}
	}
}

@end
