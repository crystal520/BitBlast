//
//  BBPhysicsObject.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBPhysicsObject.h"


@implementation BBPhysicsObject

@synthesize body;

- (id) initWithBody:(b2Body*)bbody {
	
	if((self = [super init])) {
		
		body = bbody;
	}
	
	return self;
}

@end
