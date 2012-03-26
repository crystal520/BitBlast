//
//  BBExplosion.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/25/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBExplosion.h"


@implementation BBExplosion

@synthesize explodingObject;

- (id) init {
	if((self = [super initWithFile:@"dropshipExplosion"])) {
		[self loadAnimations];
		[self addChild:spriteBatch];
		
		// use nearest so it will scale better
		ccTexParams params = {GL_NEAREST,GL_NEAREST,GL_REPEAT,GL_REPEAT};
		[sprite.texture setTexParameters:&params];
		
		self.scale = 2;
	}
	return self;
}

- (void) explode {
	// generate random position within object to explode in
	CGPoint bounds = ccpMult(ccp(explodingObject.boundingBox.size.width, explodingObject.boundingBox.size.height), [ResolutionManager sharedSingleton].positionScale);
	int ranX = CCRANDOM_MIN_MAX(0, bounds.x) - bounds.x * 0.5 + explodingObject.position.x + 50;
	int ranY = CCRANDOM_MIN_MAX(0, bounds.y) - bounds.y * 0.5 + explodingObject.position.y - 50;
	self.position = ccp(ranX, ranY);
	// delay, explode, repeat
	//CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_0_1()], [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"death"]], [CCCallFunc actionWithTarget:self selector:@selector(explode)], nil];
	//[self.sprite runAction:action];
	[self playAnimation:@"death" target:self selector:@selector(explode)];
}

@end
