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
	if((self = [super init])) {
		
		// create body image
		body = [BBSpriteFactory spriteWithFile:@"body.png"];
		[self addChild:body];
		
		// set initial position
		[self setPosition:CGPointMake(32, 32)];
	}
	
	return self;
}

@end
