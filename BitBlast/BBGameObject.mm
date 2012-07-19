//
//  BBGameObject.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameObject.h"

@implementation BBGameObjectShape
@end

@implementation BBGameObject

@synthesize dummyPosition, prevDummyPosition;

- (id) initWithFile:(NSString *)filename {
	
	if((self = [super init])) {
		
		// save dictionary for future use
		[self loadFromFile:filename];
	}
	
	return self;
}

- (void) dealloc {
    [collisionShape destroyBody];
	[super dealloc];
}

- (void) loadFromFile:(NSString*)filename {
	dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
}

- (void) loadComplete {
    [dictionary release];
}

#pragma mark -
#pragma mark animations
- (void) repeatAnimation:(NSString*)animName {
	[self repeatAnimation:animName startFrame:0];
}

- (void) repeatAnimation:(NSString *)animName startFrame:(int)frame {
	[self stopActionByTag:ACTION_TAG_ANIMATION];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:[anim.frames objectAtIndex:0]];
	// check to see if it should start on a random frame
	if(frame == -1) {
		frame = CCRANDOM_MIN_MAX(0, [anim.frames count]);
	}
	// run it
	CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO startFrame:frame]];
    action.tag = ACTION_TAG_ANIMATION;
	[self runAction:action];
}

- (void) playAnimation:(NSString *)animName {
	[self stopActionByTag:ACTION_TAG_ANIMATION];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:[anim.frames objectAtIndex:0]];
	// run it
	CCAnimate *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO];
    action.tag = ACTION_TAG_ANIMATION;
	[self runAction:action];
}

- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector {
	[self stopActionByTag:ACTION_TAG_ANIMATION];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:[anim.frames objectAtIndex:0]];
	// compose sequence with animate and selector
	CCAction *action = [CCSequence actions:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO], [CCCallFunc actionWithTarget:target selector:selector], nil];
    action.tag = ACTION_TAG_ANIMATION;
	[self runAction:action];
}

#pragma mark -
#pragma mark setters
- (void) setDisplayFrame:(CCSpriteFrame *)newFrame {
	[super setDisplayFrame:newFrame];
	// use nearest so it will scale better
	ccTexParams params = {GL_NEAREST,GL_NEAREST,GL_REPEAT,GL_REPEAT};
	[self.texture setTexParameters:&params];
}

#pragma mark -
#pragma mark actions
- (void) pause {
	[self pauseSchedulerAndActions];
}

- (void) resume {
	[self resumeSchedulerAndActions];
}

@end
