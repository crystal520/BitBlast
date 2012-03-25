//
//  BBChopper.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBChopper.h"


@implementation BBChopper

- (id) init {
	if((self = [super initWithFile:@"chopper"])) {
		[self loadAnimations];
		[self addChild:spriteBatch];
		
		// make hull image
		CCSprite *hull = [CCSprite spriteWithSpriteFrameName:@"chopper.png"];
		hull.position = ccpMult(ccp(-120, -130), [ResolutionManager sharedSingleton].positionScale);
		[spriteBatch addChild:hull];
		
		[self repeatAnimation:@"chopperBlades"];
		
		// start copter off screen
		dummyPosition = ccp(-self.sprite.contentSize.width * 0.5, ([ResolutionManager sharedSingleton].size.height + self.sprite.contentSize.height) * [ResolutionManager sharedSingleton].inversePositionScale);
		needsPlatformCollisions = NO;
		
		// intro sequence!
		CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(hover)], nil];
		[self runAction:action];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	// load extra variables
	velocity = ccp([[[dictionary objectForKey:@"speed"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"speed"] objectForKey:@"y"] floatValue]);
	gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
}

- (void) hover {
	// change velocity so that chopper is "stopped"
	velocity = ccp(300, 0);
	// fly off the screen in a second
	CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(flyAway)], nil];
	[self runAction:action];
}
						
- (void) flyAway {
	// fly off the screen!
	velocity = ccp(150, 150);
}

@end
