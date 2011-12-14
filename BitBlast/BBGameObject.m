//
//  BBGameObject.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameObject.h"


@implementation BBGameObject

- (id) initWithFile:(NSString *)filename {
	
	if((self = [super init])) {
		
		// save dictionary for future use
		dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
		
		[self setupPhysics];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	
	[dictionary release];
}

- (void) setupPhysics {
	
	// get physics info
	NSDictionary *physics = [dictionary objectForKey:@"physics"];
	
	// see if there's physics info
	if(physics) {
	
		// define the dynamic body
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.position.Set(100/PTM_RATIO, 32/PTM_RATIO);
		bodyDef.userData = self;
		body = [BBPhysicsWorld sharedSingleton].world->CreateBody(&bodyDef);
		
		// define the box shape for our dynamic body
		b2PolygonShape box;
		box.SetAsBox(0.5f, 0.5f);
		
		// set defaults first
		float density = 1.0f;
		float friction = 0.3f;
		
		// see if dictionary has values
		if([[physics objectForKey:@"density"] isKindOfClass:[NSNull class]] == NO) {
			density = [[physics objectForKey:@"density"] floatValue];
		}
		if([[physics objectForKey:@"friction"] isKindOfClass:[NSNull class]] == NO) {
			friction = [[physics objectForKey:@"friction"] floatValue];
		}
		
		// define the dynamic body fixture
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &box;
		fixtureDef.density = density;
		fixtureDef.friction = friction;
		body->CreateFixture(&fixtureDef);
	}
}

- (void) playAnimation:(NSString*)animName {
	
	// get animation dictionary
	NSDictionary *animDict = [[dictionary objectForKey:@"animations"] objectForKey:animName];
	
	// make sure it exists
	if(!animDict) {
		NSLog(@"ERROR: Failed to play animation \"%@\" because it doesn't exist", animName);
		return;
	}
	
	// load plist file with information about spritesheet
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[animDict objectForKey:@"plist"]];
	
	// load image file
	CCSpriteBatchNode *spritesheet = [CCSpriteBatchNode batchNodeWithFile:[animDict objectForKey:@"image"]];
	[self addChild:spritesheet];
	
	// get the frames
	NSMutableArray *frames = [NSMutableArray array];
	for(int i=0,j=[[animDict objectForKey:@"frames"] count];i<j;i++) {
		[frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[animDict objectForKey:@"frames"] objectAtIndex:i]]];
	}
	
	// create sprite with first frame
	sprite = [CCSprite spriteWithSpriteFrameName:[[animDict objectForKey:@"frames"] objectAtIndex:0]];
	
	// create the animation object
	CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:[[animDict objectForKey:@"speed"] floatValue]];
	
	// run it
	CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
	[sprite runAction:action];
	[spritesheet addChild:sprite];
}

@end
