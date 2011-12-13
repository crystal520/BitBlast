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
	if((self = [super init])) {
		
		//self.scale = 2;
		
		// create body image
		body = [BBSpriteFactory spriteWithFile:@"body.png"];
		[self addChild:body];
		
		// define the dynamic body
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.position.Set(32/PTM_RATIO, 32/PTM_RATIO);
		bodyDef.userData = self;
		physicsBody = [BBPhysicsWorld sharedSingleton].world->CreateBody(&bodyDef);
		
		// define the box shape for our dynamic body
		b2PolygonShape box;
		box.SetAsBox(0.5f, 0.5f);
		
		// define the dynamic body fixture
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &box;
		fixtureDef.density = 1.0f;
		fixtureDef.friction = 0.3f;
		physicsBody->CreateFixture(&fixtureDef);
	}
	
	return self;
}

- (void) draw {
	
}

- (void) jump {
	
	// only jump if we're not jumping already
	if(physicsBody->GetLinearVelocity().y <= 0.01f && physicsBody->GetLinearVelocity().y >= -0.01f) {
		physicsBody->ApplyLinearImpulse(b2Vec2(0, kJump/PTM_RATIO), physicsBody->GetWorldCenter());
	}
}

@end
