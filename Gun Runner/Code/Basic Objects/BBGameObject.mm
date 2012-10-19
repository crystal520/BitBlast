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

@synthesize dummyPosition, prevDummyPosition, paused;

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
	[self setDisplayFrame:((CCAnimationFrame*)([anim.frames objectAtIndex:0])).spriteFrame];
	// check to see if it should start on a random frame
	if(frame == -1) {
		frame = CCRANDOM_MIN_MAX(0, [anim.frames count]);
	}
	// run it
	CCAction *action = [CCRepeatForever actionWithAction:[CCAnimateFrame actionWithAnimation:anim restoreOriginalFrame:NO startFrame:frame]];
    action.tag = ACTION_TAG_ANIMATION;
	[self runAction:action];
}

- (void) playAnimation:(NSString *)animName {
	[self stopActionByTag:ACTION_TAG_ANIMATION];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:((CCAnimationFrame*)([anim.frames objectAtIndex:0])).spriteFrame];
	// run it
	CCAnimate *action = [CCAnimateFrame actionWithAnimation:anim restoreOriginalFrame:NO];
    action.tag = ACTION_TAG_ANIMATION;
	[self runAction:action];
}

- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector {
	[self stopActionByTag:ACTION_TAG_ANIMATION];
	// get animation from dictionary
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:animName];
	// set sprite to first frame of the animation
	[self setDisplayFrame:((CCAnimationFrame*)([anim.frames objectAtIndex:0])).spriteFrame];
	// compose sequence with animate and selector
	CCAction *action = [CCSequence actions:[CCAnimateFrame actionWithAnimation:anim restoreOriginalFrame:NO], [CCCallFunc actionWithTarget:target selector:selector], nil];
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
    paused = YES;
	[self pauseSchedulerAndActions];
}

- (void) resume {
    paused = NO;
	[self resumeSchedulerAndActions];
}

#pragma mark -
#pragma mark convenience
+ (NSDictionary*) randomDictionaryFromArray:(NSArray*)array {
    // generate random number
    float ran = CCRANDOM_0_1();
    return [BBGameObject randomDictionaryFromArray:array overrideRandom:ran];
}

+ (NSDictionary*) randomDictionaryFromArray:(NSArray *)array overrideRandom:(float)override {
    float curProbability = 0;
    float prevProbability = 0;
    
    for(NSDictionary *d in array) {
        prevProbability = curProbability;
        curProbability += [[d objectForKey:@"probability"] floatValue];
        if(override >= prevProbability && override < curProbability) {
            return d;
        }
    }
    if([array count] >= 1) {
        return [array objectAtIndex:0];
    }
    return nil;
}

- (void) flashFrom:(ccColor3B)fromColor to:(ccColor3B)toColor withTime:(float)time numberOfTimes:(int)times onSprite:(CCSprite*)sprite {
    CCTintTo *flashAction = [CCTintTo actionWithDuration:(times > 0) ? time / (times * 2.0f) : time * 0.5f red:toColor.r green:toColor.g blue:toColor.b];
    CCTintTo *flashBackAction = [CCTintTo actionWithDuration:(times > 0) ? time / (times * 2.0f) : time * 0.5f red:fromColor.r green:fromColor.g blue:fromColor.b];
    CCAction *finalAction;
    if(times > 0) {
        finalAction = [CCRepeat actionWithAction:[CCSequence actions:flashAction, flashBackAction, nil] times:times];
    }
    else {
        finalAction = [CCRepeatForever actionWithAction:[CCSequence actions:flashAction, flashBackAction, nil]];
    }
    finalAction.tag = ACTION_TAG_FLASH;
    [sprite runAction:finalAction];
}

- (void) flashAlphaFrom:(float)fromAlpha to:(float)toAlpha withTime:(float)time numberOfTimes:(int)times onSprite:(CCSprite*)sprite {
    CCFadeTo *flashAlphaAction = [CCFadeTo actionWithDuration:(times > 0) ? time / (times * 2.0f) : time * 0.5f opacity:toAlpha];
    CCFadeTo *flashAlphaBackAction = [CCFadeTo actionWithDuration:(times > 0) ? time / (times * 2.0f) : time * 0.5f opacity:fromAlpha];
    CCAction *finalAction;
    if(times > 0) {
        finalAction = [CCRepeat actionWithAction:[CCSequence actions:flashAlphaAction, flashAlphaBackAction, nil] times:times];
    }
    else {
        finalAction = [CCRepeatForever actionWithAction:[CCSequence actions:flashAlphaAction, flashAlphaBackAction, nil]];
    }
    finalAction.tag = ACTION_TAG_FLASH_ALPHA;
    [sprite runAction:finalAction];
}

- (void) fadeFrom:(ccColor3B)fromColor to:(ccColor3B)toColor withTime:(float)time onSprite:(CCSprite*)sprite target:(id)target selector:(SEL)selector {
    sprite.color = fromColor;
    CCSequence *fadeAction = [CCSequence actions:[CCTintTo actionWithDuration:time red:toColor.r green:toColor.g blue:toColor.b], nil];
    if(target && selector && [target respondsToSelector:selector]) {
        fadeAction = [CCSequence actions:[CCTintTo actionWithDuration:time red:toColor.r green:toColor.g blue:toColor.b], [CCCallFunc actionWithTarget:target selector:selector], nil];
    }
    fadeAction.tag = ACTION_TAG_FADE;
    [sprite runAction:fadeAction];
}

- (void) fadeAlphaFrom:(float)fromAlpha to:(float)toAlpha withTime:(float)time onSprite:(CCSprite*)sprite target:(id)target selector:(SEL)selector {
    sprite.opacity = fromAlpha;
    CCSequence *fadeAlphaAction = [CCSequence actions:[CCFadeTo actionWithDuration:time opacity:toAlpha], nil];
    if(target && selector && [target respondsToSelector:selector]) {
        fadeAlphaAction = [CCSequence actions:[CCFadeTo actionWithDuration:time opacity:toAlpha], [CCCallFunc actionWithTarget:self selector:selector], nil];
    }
    fadeAlphaAction.tag = ACTION_TAG_FADE_ALPHA;
    [sprite runAction:fadeAlphaAction];
}

@end
