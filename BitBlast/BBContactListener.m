//
//  BBContactListener.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/26/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBContactListener.h"
#import "BBPlayer.h"

BBContactListener::BBContactListener() {
	
}

BBContactListener::~BBContactListener() {
	
}

void BBContactListener::BeginContact(b2Contact* contact) {
	
	// get fixtures from contact
	b2Fixture *fixtureA = contact->GetFixtureA();
	b2Fixture *fixtureB = contact->GetFixtureB();
	
	// get bodies from fixtures
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	
	// get sprites from bodies
	CCSprite *spriteA = (CCSprite*)(bodyA->GetUserData());
	CCSprite *spriteB = (CCSprite*)(bodyB->GetUserData());
	
	// see if one of the bodies is the player
	if([spriteA isKindOfClass:[BBPlayer class]] && spriteB) {
		BBPlayer *player = (BBPlayer*)(spriteA);
		[player collideWithObject:spriteB physicsBody:bodyB withContact:contact];
	}
	else if([spriteB isKindOfClass:[BBPlayer class]] && spriteA) {
		BBPlayer *player = (BBPlayer*)(spriteB);
		[player collideWithObject:spriteA physicsBody:bodyA withContact:contact];
	}
}

void BBContactListener::EndContact(b2Contact* contact) {
	
}

void BBContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
	
}

void BBContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
	
}