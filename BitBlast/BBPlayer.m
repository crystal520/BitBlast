//
//  BBPlayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPlayer.h"

#define kJump 300

@implementation BBPlayer

- (id) init {
	if((self = [super initWithFile:@"playerProperties"])) {
		
		[self playAnimation:@"walk"];
		
		body = [[BBPhysicsWorld sharedSingleton] createBoxFromFile:@"physicsPlayer" withPosition:ccp(64, 256) withData:self];
		body.body->SetSleepingAllowed(NO);
		
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
	v.x = 7;
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
		body.body->ApplyLinearImpulse(b2Vec2(0, kJump/PTM_RATIO), body.body->GetWorldCenter());
	}
}

- (void) shoot {
	BBBullet *bullet = [[BBBullet alloc] initWithPosition:self.position];
}

@end
