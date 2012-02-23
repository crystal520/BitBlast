//
//  BBGameObject.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameObject.h"


@implementation BBGameObject

@synthesize sprite;

- (id) initWithFile:(NSString *)filename {
	
	if((self = [super init])) {
		
		// save dictionary for future use
		dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	}
	
	return self;
}

- (void) dealloc {
	[sprite release];
	[dictionary release];
	[super dealloc];
}

- (void) loadFromFile:(NSString*)filename {
	if(dictionary) {
		[dictionary release];
	}
	dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
}

#pragma mark -
#pragma mark animations
- (void) loadAnimations {
	// release sprite if it already exists
	if(sprite) {
		[sprite release];
	}
	// create sprite
	sprite = [CCSprite new];
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
	// load image file
	spriteBatch = [CCSpriteBatchNode batchNodeWithFile:[dictionary objectForKey:@"image"]];
}

- (void) repeatAnimation:(NSString*)animName {
	[sprite stopAllActions];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[sprite setDisplayFrame:[anim.frames objectAtIndex:0]];
	// run it
	CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
	[sprite runAction:action];
	// add it to the spritebatch if we need to
	if(!sprite.parent) {
		[spriteBatch addChild:sprite];
	}
}

- (void) playAnimation:(NSString *)animName {
	[sprite stopAllActions];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[sprite setDisplayFrame:[anim.frames objectAtIndex:0]];
	// run it
	CCAnimate *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO];
	[sprite runAction:action];
	// add it to the spritebatch if we need to
	if(!sprite.parent) {
		[spriteBatch addChild:sprite];
	}
}

- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector {
	[sprite stopAllActions];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[sprite setDisplayFrame:[anim.frames objectAtIndex:0]];
	// compose sequence with animate and selector
	CCAction *action = [CCSequence actions:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO], [CCCallFunc actionWithTarget:target selector:selector], nil];
	[sprite runAction:action];
	// add it to the spritebatch if we need to
	if(!sprite.parent) {
		[spriteBatch addChild:sprite];
	}
}

#pragma mark -
#pragma mark getters
- (BOOL) getCollidesWith:(BBGameObject*)object {
	// convert object's position into this game object's space
	CGPoint thisPos = [self.parent convertToNodeSpace:object.position];
	// check for collision
	return CGRectIntersectsRect(CGRectMake(self.position.x, self.position.y, sprite.contentSize.width, sprite.contentSize.height), CGRectMake(thisPos.x, thisPos.y, object.sprite.contentSize.width, object.sprite.contentSize.height));
}

#pragma mark -
#pragma mark actions
- (void) stopAllActions {
	[super stopAllActions];
	[sprite stopAllActions];
}

@end
