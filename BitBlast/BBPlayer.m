//
//  BBPlayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPlayer.h"

@implementation BBPlayer

- (id) init {
	if((self = [super initWithFile:@"playerProperties"])) {
		
		[self playAnimation:@"walk"];
		
		body = [[BBPhysicsWorld sharedSingleton] createPhysicsObjectFromFile:@"physicsPlayer" withPosition:ccp(64, 256) withData:self];
		body.body->SetSleepingAllowed(NO);
		
		// load jump value from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue];
		
		// load speed value from plist
		speed = [[dictionary objectForKey:@"speed"] floatValue];
		
		//[[CCScheduler sharedScheduler] scheduleSelector:@selector(shoot) forTarget:self interval:3 paused:NO];
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) draw {
	
	b2Vec2 v = body.body->GetLinearVelocity();
	v.x = speed;
	body.body->SetLinearVelocity(v);
	
	// see if player has died by falling in a pit
	if(body.body->GetPosition().y < [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
		[self die:@"fall"];
	}
}

#pragma mark -
#pragma mark actions
- (void) die:(NSString*)reason {
	
	NSLog(@"Player has died from %@", reason);
	
	if([reason isEqualToString:@"fall"]) {
		
	}
}

- (void) jump {
	
	// only jump if we're not jumping already
	if(body.body->GetLinearVelocity().y <= 0.01f && body.body->GetLinearVelocity().y >= -0.01f) {
		body.body->ApplyLinearImpulse(b2Vec2(0, jumpImpulse/PTM_RATIO), body.body->GetWorldCenter());
	}
	else {
		NSLog(@"Can't jump because player's Y velocity is out of range: %f", body.body->GetLinearVelocity().y);
	}
}

- (void) shoot {
	BBBullet *bullet = [[BBBullet alloc] initWithPosition:self.position];
}

@end
