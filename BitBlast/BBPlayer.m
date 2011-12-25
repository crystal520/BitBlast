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
		
		// load values from plist
		jumpImpulse = [[dictionary objectForKey:@"jump"] floatValue];
		minSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"minSpeed"] floatValue];
		maxSpeed = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"maxSpeed"] floatValue];
		speedIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"incrementPercent"] floatValue];
		chunksToIncrement = [[[dictionary objectForKey:@"speedRamp"] objectForKey:@"numChunksToIncrement"] intValue];
		
		// set initial values
		speed = minSpeed;
		curNumChunks = 0;
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkCompleted) name:kChunkCompletedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chunkWillBeRemoved) name:kChunkWillRemoveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(physicsUpdated) name:kPhysicsUpdatedNotification object:nil];
		
		[[[ChunkManager sharedSingleton] getCurrentChunk].map addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
		sprite.tag = -1000;
		
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
	
	// add player to current chunk
	[[[ChunkManager sharedSingleton] getCurrentChunk].map addChild:self z:[[ChunkManager sharedSingleton] getCurrentChunk].playerZ];
	[self release];
}

- (void) chunkWillBeRemoved {
	
	chunkSpriteOffset += [[ChunkManager sharedSingleton] getCurrentChunk].width;
	[self retain];
	[self.parent removeChild:self cleanup:NO];
}

- (void) physicsUpdated {
	
	// offset the sprite by the chunk offset
	[self setPosition:ccp(self.position.x - chunkSpriteOffset, self.position.y)];
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
