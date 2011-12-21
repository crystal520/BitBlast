//
//  BBBullet.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/19/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBBullet.h"


@implementation BBBullet

- (id) initWithPosition:(CGPoint)position {
	if((self = [super initWithFile:@"bulletProperties"])) {
		
		[self playAnimation:@"basic"];
		
		/*body = [[BBPhysicsWorld sharedSingleton] createBoxFromFile:@"physicsBullet" withPosition:position withData:self];
		body.body->SetSleepingAllowed(NO);
		body.body->SetBullet(YES);
		body.body->ApplyImpulse(b2Vec2(20.0f, 0.0f));*/
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

@end
