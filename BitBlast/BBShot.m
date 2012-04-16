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
		scale = 1;
		
		// get values from dictionary
		sprite = [[dict objectForKey:@"sprite"] retain];
		rateOfFire = [[dict objectForKey:@"rateOfFire"] floatValue];
		speedRestraints = ccp([[dict objectForKey:@"minSpeed"] floatValue], [[dict objectForKey:@"maxSpeed"] floatValue]);
		angleRestraints = ccp([[dict objectForKey:@"minAngleOffset"] floatValue], [[dict objectForKey:@"maxAngleOffset"] floatValue]);
		lifetimeRestraints = ccp([[dict objectForKey:@"minLifetime"] floatValue], [[dict objectForKey:@"maxLifetime"] floatValue]);
		numBulletsRestraints = ccp([[dict objectForKey:@"minNumBullets"] floatValue], [[dict objectForKey:@"maxNumBullets"] floatValue]);
		blend = [[dict objectForKey:@"blend"] boolValue];
		NSDictionary *bbDict = [dict objectForKey:@"boundingBox"];
		boundingBox = CGRectMake([[bbDict objectForKey:@"x"] floatValue], [[bbDict objectForKey:@"y"] floatValue], [[bbDict objectForKey:@"width"] floatValue], [[bbDict objectForKey:@"height"] floatValue]);
		damage = [[dict objectForKey:@"damage"] floatValue];
		sound = [[dict objectForKey:@"sound"] retain];
		
		// check for particle system
		if(particles) {
			[particles release];
		}
		if([dict objectForKey:@"particles"]) {
			particles = [[CCParticleSystemQuad particleWithFile:[dict objectForKey:@"particles"]] retain];
		}
		
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
	if(particles) {
		[particles.parent removeChild:particles cleanup:YES];
		[particles release];
	}
	[sprite release];
	[angles release];
	[behaviors release];
	[sound release];
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

- (void) setPlayerSpeed:(float)newPlayerSpeed {
	playerSpeed = newPlayerSpeed;
}

- (void) setPosition:(CGPoint)newPosition {
	position = newPosition;
	// play particles if there are any
	if(particles) {
		particles.position = ccpMult(position, [ResolutionManager sharedSingleton].positionScale);
	}
}

- (void) setScale:(float)newScale {
	scale = newScale;
	if(particles) {
		particles.scale = scale;
	}
}

- (void) setNode:(CCNode *)node {
	[particles.parent removeChild:particles cleanup:NO];
	[node addChild:particles];
	// unschedule and reschedule update in case it has been unscheduled by a parent
	[particles unscheduleUpdate];
	[particles scheduleUpdateWithPriority:1];
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
	// make sure there's a sprite
	if(sprite) {
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
				bullet.boundingBox = boundingBox;
				// loop through behaviors and apply to bullet
				for(BBBehavior *b in behaviors) {
					[b applyToNode:bullet withAngle:fireAngle];
				}
				// if fire was called more than once this frame, update the bullet based on rateOfFire
				[bullet update:updateBulletTime * rateOfFire];
				// set blend function if needed
				if(blend) {
					[bullet setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA, GL_ONE}];
				}
				// set rotation of bullet to current angle
				bullet.rotation = -fireAngle;
				// set damage of bullet to shot's damage
				bullet.damage = damage;
			}
		}
	}
	// play sound if there is any
	if(sound) {
		[[SimpleAudioEngine sharedEngine] playEffect:sound];
	}
	// reset particles if there are any
	if(particles) {
		[particles resetSystem];
	}
}

@end
