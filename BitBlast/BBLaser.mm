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
		scale = 1;
		
		// get values from dictionary
		sprite = [[dict objectForKey:@"sprite"] retain];
		blend = [[dict objectForKey:@"blend"] boolValue];
		sound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:[dict objectForKey:@"sound"]] retain];
		
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
		
		lasers = [NSMutableArray new];
		
		// loop through angles and get a bullet for each one
		for(int i=0,j=[angles count];i<j;i++) {
			BBBullet *laser = [[BulletManager sharedSingleton] getRecycledBullet];
            laser.type = kBulletTypeLaser;
            // create collision shape for laser
            [laser setCollisionShape:[dict objectForKey:@"collisionShape"]];
			[laser resetWithPosition:ccp(0,0) velocity:ccp(0,0) lifetime:100 graphic:sprite];
			[laser setTexture:[[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:sprite]] autorelease]];
			laser.visible = NO;
			laser.indestructible = YES;
            laser.damage = [[dict objectForKey:@"damage"] floatValue];
			// set tex params so it repeats horizontally
			ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
			[laser.texture setTexParameters:&params];
			// set size equal to the width of the screen
			CGRect texRect = laser.textureRect;
			laser.textureRect = CGRectMake(0, 0, [ResolutionManager sharedSingleton].size.width, texRect.size.height);
			// set anchor point so it starts at the end of the gun
			laser.anchorPoint = ccp(0, 0.5);
			// set blend function if needed
			if(blend) {
				[laser setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA, GL_ONE}];
			}
			// store in array for later use
			[lasers addObject:laser];
		}
	}
	return self;
}

- (void) dealloc {
	if(particles) {
		[particles.parent removeChild:particles cleanup:YES];
		[particles release];
	}
	[lasers release];
	[sprite release];
	[angles release];
	[behaviors release];
    [sound stop];
	[sound release];
	[super dealloc];
}

#pragma mark -
#pragma mark setters
- (void) setAngle:(float)newAngle {
	angle = newAngle;
    if(particles) {
        particles.rotation = -newAngle;
    }
}

- (void) setEnabled:(BOOL)newEnable {
	enabled = newEnable;
    // make sure all particles disappear
    if(!newEnable) {
        [particles resetSystem];
        [particles update:0];
    }
	for(BBBullet *b in lasers) {
		b.visible = newEnable;
	}
    [self checkSound];
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
    for(BBBullet *b in lasers) {
        [b setScale:scale];
    }
}

- (void) setNode:(CCNode*)node {
	if(particles) {
		[particles.parent removeChild:particles cleanup:YES];
		[node addChild:particles z:DEPTH_GAME_BULLETS];
		// unschedule and reschedule update in case it has been unscheduled by a parent
		[particles unscheduleUpdate];
		[particles scheduleUpdateWithPriority:1];
	}
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
			[laser setEnabled:YES];
			// set laser's position
			laser.dummyPosition = position;
			// set angle based on this laser's angle and the angles array
			laser.rotation = -angle + [[angles objectAtIndex:i] floatValue];
		}
		// reset particles if there are any
		if(particles) {
			[particles resetSystem];
		}
        [self checkSound];
	}
}

#pragma mark -
#pragma mark actions
- (void) clearBullets {
	for(BBBullet *b in lasers) {
		b.indestructible = NO;
		[b setEnabled:NO];
	}
}

- (void) checkSound {
    if(enabled && sound && ![sound isPlaying]) {
        [sound play];
    }
    else if(!enabled && sound && [sound isPlaying]) {
        [sound stop];
    }
}

- (void) pause {
    [particles pauseSchedulerAndActions];
}

- (void) resume {
    [particles resumeSchedulerAndActions];
}

- (void) gameOver {
    [particles pauseSchedulerAndActions];
}

@end
