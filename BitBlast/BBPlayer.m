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
	if((self = [super initWithFile:@"player"])) {
		
		//self.scale = 2;
		
		[self playAnimation:@"walk"];
	}
	
	return self;
}

- (void) draw {
	
}

- (void) jump {
	
	// only jump if we're not jumping already
	if(body->GetLinearVelocity().y <= 0.01f && body->GetLinearVelocity().y >= -0.01f) {
		body->ApplyLinearImpulse(b2Vec2(0, kJump/PTM_RATIO), body->GetWorldCenter());
	}
}

@end
