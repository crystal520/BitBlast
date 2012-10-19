//
//  BBChopper.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBChopper.h"


@implementation BBChopper

- (id) init {
	if((self = [super initWithFile:@"chopper"])) {
		
		// make hull image
		CCSprite *hull = [CCSprite spriteWithSpriteFrameName:@"chopper.png"];
		hull.position = ccpMult(ccp(230, -70), [ResolutionManager sharedSingleton].positionScale);
		[self addChild:hull];
		
		[self repeatAnimation:@"chopperBlades"];
		
		// start copter off screen
		dummyPosition = ccp(-170, 750);
		needsPlatformCollisions = NO;
        
        // create offset node for following the chopper
        offsetNode = [CCNode node];
        offsetNode.position = ccp(300,0);
        CCAction *moveAction = [CCMoveTo actionWithDuration:2 position:ccp(0, 0)];
        [offsetNode runAction:moveAction];
        [self addChild:offsetNode];
		
		// intro sequence!
		CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(hover)], nil];
		[self runAction:action];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
	}
	return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (CGPoint) getOffset {
    return offsetNode.position;
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	// load extra variables
	velocity = ccp([[[dictionary objectForKey:@"speed"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"speed"] objectForKey:@"y"] floatValue]);
	gravity = ccp(0, [[dictionary objectForKey:@"gravity"] floatValue]);
    [self loadComplete];
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
