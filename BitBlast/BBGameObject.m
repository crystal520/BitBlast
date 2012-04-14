//
//  BBGameObject.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameObject.h"


@implementation BBGameObject

@synthesize dummyPosition, prevDummyPosition, boundingBox;

- (id) initWithFile:(NSString *)filename {
	
	if((self = [super init])) {
		
		// save dictionary for future use
		[self loadFromFile:filename];
	}
	
	return self;
}

- (void) dealloc {
	[dictionary release];
	[super dealloc];
}

- (void) loadFromFile:(NSString*)filename {
	if(dictionary) {
		[dictionary release];
	}
	dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	// see if there's a bounding box
	if([dictionary objectForKey:@"boundingBox"]) {
		NSDictionary *bbDict = [dictionary objectForKey:@"boundingBox"];
		boundingBox = CGRectMake([[bbDict objectForKey:@"x"] floatValue], [[bbDict objectForKey:@"y"] floatValue], [[bbDict objectForKey:@"width"] floatValue], [[bbDict objectForKey:@"height"] floatValue]);
	}
}

#pragma mark -
#pragma mark animations
- (void) loadAnimations {
	// get animations from dictionary
	NSArray *dictAnimations = [NSArray arrayWithArray:[dictionary objectForKey:@"animations"]];
	// loop through and create animations
	for(NSDictionary *d in dictAnimations) {
		// get the frames
		NSMutableArray *frames = [NSMutableArray array];
		for(int i=0,j=[[d objectForKey:@"frames"] count];i<j;i++) {
			[frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[d objectForKey:@"frames"] objectAtIndex:i]]];
		}
		// create the animation object
		CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:[[d objectForKey:@"speed"] floatValue]];
		// save animation in cache
		[[CCAnimationCache sharedAnimationCache] addAnimation:anim name:[d objectForKey:@"name"]];
	}
	// load plist file with information about spritesheet
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[dictionary objectForKey:@"plist"]];
}

- (void) repeatAnimation:(NSString*)animName {
	[self stopAllActions];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:[anim.frames objectAtIndex:0]];
	// run it
	CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
	[self runAction:action];
}

- (void) playAnimation:(NSString *)animName {
	[self stopAllActions];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:[anim.frames objectAtIndex:0]];
	// run it
	CCAnimate *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO];
	[self runAction:action];
}

- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector {
	[self stopAllActions];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:[anim.frames objectAtIndex:0]];
	// compose sequence with animate and selector
	CCAction *action = [CCSequence actions:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO], [CCCallFunc actionWithTarget:target selector:selector], nil];
	[self runAction:action];
}

#pragma mark -
#pragma mark getters
- (BOOL) getCollidesWith:(BBGameObject*)object {
	// convert object's position into this game object's space
	CGPoint thisPos = self.dummyPosition;
	CGPoint thatPos = object.dummyPosition;
	// calculate collision boxes
	CGRect thisBox = CGRectMake((thisPos.x + boundingBox.origin.x) - boundingBox.size.width * self.anchorPoint.x, (thisPos.y + boundingBox.origin.y) - boundingBox.size.height * self.anchorPoint.y, boundingBox.size.width, boundingBox.size.height);
	CGRect thatBox = CGRectMake((thatPos.x + object.boundingBox.origin.x) - object.boundingBox.size.width * object.anchorPoint.x, (thatPos.y + object.boundingBox.origin.y) - object.boundingBox.size.height * object.anchorPoint.y, object.boundingBox.size.width, object.boundingBox.size.height);
	// check for collision
	return CGRectIntersectsRect(thisBox, thatBox);
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
