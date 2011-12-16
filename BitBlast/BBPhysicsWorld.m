//
//  BBPhysicsWorld.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPhysicsWorld.h"

@implementation BBPhysicsWorld

@synthesize world;

+ (BBPhysicsWorld*) sharedSingleton {
	
	static BBPhysicsWorld *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBPhysicsWorld alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	
	if((self = [super init])) {
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create physics world
		b2Vec2 gravity = b2Vec2(0.0f, -30.0f);
		world = new b2World(gravity, true);
		
		// create edges around the entire screen
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0);
		b2Body *groundBody = world->CreateBody(&groundBodyDef);
		b2PolygonShape groundBox;
		b2FixtureDef boxShapeDef;
		boxShapeDef.shape = &groundBox;
		groundBox.SetAsEdge(b2Vec2(0, 0), b2Vec2(winSize.width/PTM_RATIO, 0));
		groundBody->CreateFixture(&boxShapeDef);
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
		groundBody->CreateFixture(&boxShapeDef);
		groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
		groundBody->CreateFixture(&boxShapeDef);
		groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
		groundBody->CreateFixture(&boxShapeDef);
		
		[self schedule:@selector(tick:)];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	
	if(debugDraw) {
		delete debugDraw;
	}
}

- (void)tick:(ccTime) dt {
	
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO * myActor.scale, b->GetPosition().y * PTM_RATIO * myActor.scale);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

- (BBPhysicsObject*) createBoxFromFile:(NSString*)fileName withPosition:(CGPoint)pos withData:(id)data {
	
	// get dictionary from plist file
	NSDictionary *boxPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
	
	// make sure it exists
	if(boxPlist) {
	
		// grab variables from plist
		float density = [[boxPlist objectForKey:@"density"] floatValue];
		float friction = [[boxPlist objectForKey:@"friction"] floatValue];
		float restitution = [[boxPlist objectForKey:@"restitution"] floatValue];
		BOOL fixedRotation = [[boxPlist objectForKey:@"fixedRotation"] boolValue];
		CGPoint anchor = ccp([[[boxPlist objectForKey:@"anchor"] objectForKey:@"x"] floatValue], [[[boxPlist objectForKey:@"anchor"] objectForKey:@"y"] floatValue]);
		float linearDamping = [[boxPlist objectForKey:@"linearDamping"] floatValue];
		float angularDamping = [[boxPlist objectForKey:@"angularDamping"] floatValue];
		NSString *type = [boxPlist objectForKey:@"type"];
		
		// set defaults if they're null
		if([boxPlist objectForKey:@"density"] == nil) {
			density = 0.0f;
		}
		if([boxPlist objectForKey:@"friction"] == nil) {
			friction = 0.0f;
		}
		if([boxPlist objectForKey:@"restitution"] == nil) {
			restitution = 0.0f;
		}
		if([boxPlist objectForKey:@"fixedRotation"] == nil) {
			fixedRotation = NO;
		}
		if([boxPlist objectForKey:@"anchor"] == nil) {
			anchor = ccp(0.5f, 0.5f);
		}
		if([boxPlist objectForKey:@"linearDamping"] == nil) {
			linearDamping = 0.0f;
		}
		if([boxPlist objectForKey:@"angularDamping"] == nil) {
			angularDamping = 0.0f;
		}
		if([boxPlist objectForKey:@"type"] == nil) {
			type = @"static";
		}
		
		// define the dynamic body
		b2BodyDef bodyDef;
		
		if([type isEqualToString:@"static"]) {
			bodyDef.type = b2_staticBody;
		}
		else if([type isEqualToString:@"dynamic"]) {
			bodyDef.type = b2_dynamicBody;
		}
		else if([type isEqualToString:@"kinematic"]) {
			bodyDef.type = b2_kinematicBody;
		}
		
		bodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
		bodyDef.userData = data;
		bodyDef.fixedRotation = fixedRotation;
		bodyDef.linearDamping = linearDamping;
		bodyDef.angularDamping = angularDamping;
		b2Body *body = world->CreateBody(&bodyDef);
		
		// define the box shape for our dynamic body
		b2PolygonShape box;
		///box.SetAsBox(ssize.width/2/PTM_RATIO, ssize.height/2/PTM_RATIO);
		box.SetAsBox(0.5f, 0.5f, b2Vec2(anchor.x, anchor.y), 0.0f);
		
		// define the dynamic body fixture
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &box;
		fixtureDef.density = density;
		fixtureDef.friction = friction;
		fixtureDef.restitution = restitution;
		body->CreateFixture(&fixtureDef);
		return [[BBPhysicsObject alloc] initWithBody:body];
	}
	else {
		return nil;
	}

}

- (void) draw {
	
	if(debugDraw) {
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		
		[BBPhysicsWorld sharedSingleton].world->DrawDebugData();
		
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}

#pragma mark -
#pragma mark debug physics
- (void) debugPhysics {
	
	debugDraw = new GLESDebugDraw(PTM_RATIO);
	uint32 flags = 0;
	flags += 1	* b2DebugDraw::e_shapeBit;
	flags += 1	* b2DebugDraw::e_jointBit;
	flags += 1	* b2DebugDraw::e_aabbBit;
	flags += 1	* b2DebugDraw::e_pairBit;
	flags += 1	* b2DebugDraw::e_centerOfMassBit;
	debugDraw->SetFlags(flags);
	[BBPhysicsWorld sharedSingleton].world->SetDebugDraw(debugDraw);
}

@end
