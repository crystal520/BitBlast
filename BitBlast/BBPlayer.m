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
		
		body = [[BBPhysicsWorld sharedSingleton] createPhysicsObjectFromFile:@"physicsPlayer" withPosition:ccp(64, 192) withData:self];
		body.body->SetSleepingAllowed(NO);
		
		// load values from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue];
		minSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"minSpeed"] floatValue];
		maxSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"maxSpeed"] floatValue];
		speedIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"incrementPercent"] floatValue];
		chunksToIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"numChunksToIncrement"] intValue];
		maxJumpTime = [[dictionary objectForKey:@"maxJumpTime"] floatValue];
		
		// set initial values
		speed = minSpeed;
		curNumChunks = 0;
		canJump = NO;
		jumpTimer = 0.0f;
		self.tag = TAG_PLAYER;
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkCompleted) name:kChunkCompletedNotification object:nil];
		
		[[ChunkManager sharedSingleton] addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
		
		//[[CCScheduler sharedScheduler] scheduleSelector:@selector(shoot) forTarget:self interval:3 paused:NO];
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	if(jumping) {
		jumpTimer += delta;
		if(jumpTimer >= maxJumpTime) {
			jumping = NO;
		}
	}
}

- (void) draw {
	
	// update player's velocity
	b2Vec2 v = body.body->GetLinearVelocity();
	v.x = speed;
	
	if(jumping) {
		v.y = jumpImpulse;
	}
	
	body.body->SetLinearVelocity(v);
	
	// see if player has died by falling in a pit
	if(body.body->GetPosition().y < [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
		[self die:@"fall"];
	}
}

#pragma mark -
#pragma mark notifications
- (void) chunkCompleted {
	
	// increment the number of chunks completed
	curNumChunks++;
	// see if we've reached the amount of chunks completed to increment the player's speed
	if(curNumChunks >= chunksToIncrement) {
		// reset the number of chunks
		curNumChunks = 0;
		// increment the player's speed
		speed += (speedIncrement * speed);
		// make sure we don't go over the maximum speed allowed
		speed = MIN(speed, maxSpeed);
		NSLog(@"Player speed is now %.2f after incrementing", speed);
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
	if(canJump) {
		jumping = YES;
		jumpTimer = 0;
	}
}

- (void) endJump {
	
	if(canJump && jumping) {
		canJump = NO;
		jumping = NO;
	}
}

- (void) shoot {
	//BBBullet *bullet = [[BBBullet alloc] initWithPosition:self.position];
}

#pragma mark -
#pragma mark collisions
- (void) collideWithObject:(CCSprite*)collide physicsBody:(b2Body*)collideBody withContact:(b2Contact*)contact {
	
	// see if player is colliding with collision tile
	if((collide.tag == TAG_COLLISION_TILE || collide.tag == TAG_COLLISION_TILE_BOTTOM || collide.tag == TAG_COLLISION_TILE_TOP) && body.body->GetLinearVelocity().y <= 0.0f) {
		// make sure player is colliding with top of platform
		b2WorldManifold worldManifold;
		contact->GetWorldManifold(&worldManifold);
		if(worldManifold.normal.y == 1.0f) {
			canJump = YES;
		}
	}
}

- (void) shouldCollideWithObject:(CCSprite *)collide physicsBody:(b2Body*)collideBody withContact:(b2Contact*)contact {
	
	// see if player is about to collide with one sided platform
	if(collide.tag == TAG_COLLISION_TILE_TOP) {
		
		// see if player is below tile. if they are, make sure they don't collide with this tile
		if(body.body->GetPosition().y - body.body->GetFixtureList()->GetShape()->m_radius <= collideBody->GetPosition().y - collideBody->GetFixtureList()->GetShape()->m_radius) {
			contact->SetEnabled(false);
		}
	}
	else if(collide.tag == TAG_COLLISION_TILE_BOTTOM) {
		
		// see if player is above tile. if they are, make sure they don't collide with this tile
		if(body.body->GetPosition().y + body.body->GetFixtureList()->GetShape()->m_radius >= collideBody->GetPosition().y + collideBody->GetFixtureList()->GetShape()->m_radius) {
			contact->SetEnabled(false);
		}
	}
}

@end
