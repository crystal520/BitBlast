//
//  BBBehavior.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/1/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBBehavior.h"


@implementation BBBehavior

- (id) initWithDictionary:(NSDictionary *)dict {
	if((self = [super init])) {
		
		// get values from dictionary
		curve = [[[dict objectForKey:@"curve"] lowercaseString] retain];
		speed = [[dict objectForKey:@"speed"] floatValue];
		property = [[dict objectForKey:@"property"] retain];
		minHighValue = [[NSArray alloc] initWithArray:[[[dict objectForKey:@"minRange"] objectForKey:@"high"] componentsSeparatedByString:@", "]];
		minLowValue = [[NSArray alloc] initWithArray:[[[dict objectForKey:@"minRange"] objectForKey:@"low"] componentsSeparatedByString:@", "]];
		maxHighValue = [[NSArray alloc] initWithArray:[[[dict objectForKey:@"maxRange"] objectForKey:@"high"] componentsSeparatedByString:@", "]];
		maxLowValue = [[NSArray alloc] initWithArray:[[[dict objectForKey:@"maxRange"] objectForKey:@"low"] componentsSeparatedByString:@", "]];
		start = [[[dict objectForKey:@"start"] lowercaseString] retain];
		loop = [[dict objectForKey:@"loop"] boolValue];
		repeat = [[dict objectForKey:@"repeat"] boolValue];
	}
	
	return self;
}

- (void) dealloc {
	[minHighValue release];
	[minLowValue release];
	[maxHighValue release];
	[maxLowValue release];
	[curve release];
	[property release];
	[start release];
	[super dealloc];
}

#pragma mark -
#pragma mark actions
- (void) applyToNode:(CCNode*)node withAngle:(float)angle {
	
	// action to perform
	CCActionInterval *action;
	// perform action on node based on all variables
	if([curve isEqualToString:@"easeinbounce"]) {
		action = [CCEaseBounceIn actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeoutbounce"]) {
		action = [CCEaseBounceOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinoutbounce"]) {
		action = [CCEaseBounceInOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinsine"]) {
		action = [CCEaseSineIn actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeoutsine"]) {
		action = [CCEaseSineOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinoutsine"]) {
		action = [CCEaseSineInOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinback"]) {
		action = [CCEaseBackIn actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeoutback"]) {
		action = [CCEaseBackOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinoutback"]) {
		action = [CCEaseBackInOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinelastic"]) {
		action = [CCEaseElasticIn actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeoutelastic"]) {
		action = [CCEaseElasticOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinoutelastic"]) {
		action = [CCEaseElasticInOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinexpo"]) {
		action = [CCEaseExponentialIn actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeoutexpo"]) {
		action = [CCEaseExponentialOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinoutexpo"]) {
		action = [CCEaseExponentialInOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeincubic"]) {
		action = [CCEaseIn actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeoutcubic"]) {
		action = [CCEaseOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"easeinoutcubic"]) {
		action = [CCEaseInOut actionWithAction:[self generateAction:node withAngle:angle]];
	}
	else if([curve isEqualToString:@"ease"]) {
		action = [CCActionEase actionWithAction:[self generateAction:node withAngle:angle]];
	}
	
	if(repeat) {
		if(loop) {
			action = [CCRepeatForever actionWithAction:[CCSequence actions:action, [action reverse], nil]];
		}
		else {
			action = [CCRepeatForever actionWithAction:action];
		}
	}
	else if(loop) {
		action = [CCSequence actions:action, [action reverse], nil];
	}
	[node runAction:action];
	
	[self finishAction:action];
}

#pragma mark -
#pragma mark convenience
- (CCActionInterval*) generateAction:(CCNode*)node withAngle:(float)angle {
	// divide by 2 if the behavior is looping
	float timeMult = 1;
	if(loop) {
		timeMult = 0.5;
	}
	
	if([property isEqualToString:@"y"]) {
		// get actual min and max
		float min = CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:0] floatValue], [[minHighValue objectAtIndex:0] floatValue]);
		float max = CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:0] floatValue], [[maxHighValue objectAtIndex:0] floatValue]);
		if([start isEqualToString:@"max"]) {
			// modify angle since it's the y axis
			angle = 90+angle;
			// offset position of node by minValue
			node.position = ccp(node.position.x + cos(CC_DEGREES_TO_RADIANS(angle)) * min, node.position.y + sin(CC_DEGREES_TO_RADIANS(angle)) * min);
			// calculate amount to move by
			float moveBy = (max + (-min)) * [ResolutionManager sharedSingleton].positionScale;
			// create up action
			CCMoveBy *upAction = [CCMoveBy actionWithDuration:speed * timeMult position:ccp(cos(CC_DEGREES_TO_RADIANS(angle)) * moveBy, sin(CC_DEGREES_TO_RADIANS(angle)) * moveBy)];
			// return upAction
			return upAction;
		}
		else {
			// modify angle since it's the y axis
			angle = 90+angle;
			// offset position of node by maxValue
			node.position = ccp(node.position.x + cos(CC_DEGREES_TO_RADIANS(angle)) * max, node.position.y + sin(CC_DEGREES_TO_RADIANS(angle)) * max);
			// calculate amount to move by
			float moveBy = (min + (-max)) * [ResolutionManager sharedSingleton].positionScale;
			// create down action
			CCMoveBy *downAction = [CCMoveBy actionWithDuration:speed * timeMult position:ccp(cos(CC_DEGREES_TO_RADIANS(angle)) * moveBy, sin(CC_DEGREES_TO_RADIANS(angle)) * moveBy)];
			// return downAction
			return downAction;
		}
	}
	else if([property isEqualToString:@"x"]) {
		// get actual min and max
		float min = CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:0] floatValue], [[minHighValue objectAtIndex:0] floatValue]);
		float max = CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:0] floatValue], [[maxHighValue objectAtIndex:0] floatValue]);
		if([start isEqualToString:@"max"]) {
			// offset position of node by minValue
			node.position = ccp(node.position.x + cos(CC_DEGREES_TO_RADIANS(angle)) * min, node.position.y + sin(CC_DEGREES_TO_RADIANS(angle)) * min);
			// calculate amount to move by
			float moveBy = (max + (-min)) * [ResolutionManager sharedSingleton].positionScale;
			// create right action
			CCMoveBy *rightAction = [CCMoveBy actionWithDuration:speed * timeMult position:ccp(cos(CC_DEGREES_TO_RADIANS(angle)) * moveBy, sin(CC_DEGREES_TO_RADIANS(angle)) * moveBy)];
			// return rightAction
			return rightAction;
		}
		else {
			// offset position of node by maxValue
			node.position = ccp(node.position.x + cos(CC_DEGREES_TO_RADIANS(angle)) * max, node.position.y + sin(CC_DEGREES_TO_RADIANS(angle)) * max);
			// calculate amount to move by
			float moveBy = (min + (-max)) * [ResolutionManager sharedSingleton].positionScale;
			// create left action
			CCMoveBy *leftAction = [CCMoveBy actionWithDuration:speed * timeMult position:ccp(cos(CC_DEGREES_TO_RADIANS(angle)) * moveBy, sin(CC_DEGREES_TO_RADIANS(angle)) * moveBy)];
			// return leftAction
			return leftAction;
		}
	}
	else if([property isEqualToString:@"scale"] || [property isEqualToString:@"rotation"] || [property isEqualToString:@"skewX"] || [property isEqualToString:@"skewY"] || [property isEqualToString:@"scaleX"] || [property isEqualToString:@"scaleY"]) {
		// get actual min and max
		float min = CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:0] floatValue], [[minHighValue objectAtIndex:0] floatValue]);
		float max = CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:0] floatValue], [[maxHighValue objectAtIndex:0] floatValue]);
		if([start isEqualToString:@"max"]) {
			return [CCActionTween actionWithDuration:speed * timeMult key:property from:min to:max];
		}
		else {
			return [CCActionTween actionWithDuration:speed * timeMult key:property from:max to:min];
		}
	}
	else if([property isEqualToString:@"alpha"]) {
		// get actual min and max
		float min = CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:0] floatValue], [[minHighValue objectAtIndex:0] floatValue]) * 255.0f;
		float max = CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:0] floatValue], [[maxHighValue objectAtIndex:0] floatValue]) * 255.0f;
		if([start isEqualToString:@"max"]) {
			// set opacity to minValue
			[(CCSprite*)(node) setOpacity:min];
			// return fade action
			return [CCFadeBy actionWithDuration:speed * timeMult opacity:(max - min)];
		}
		else {
			// set opacity to maxValue
			[(CCSprite*)(node) setOpacity:max];
			// return fade action
			return [CCFadeBy actionWithDuration:speed * timeMult opacity:(min - max)];
		}
	}
	else if([property isEqualToString:@"color"]) {
		// get actual min and max
		ccColor3B min = ccc3(CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:0] floatValue], [[minHighValue objectAtIndex:0] floatValue]) * 255.0f, CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:1] floatValue], [[minHighValue objectAtIndex:1] floatValue]) * 255.0f, CCRANDOM_MIN_MAX([[minLowValue objectAtIndex:2] floatValue], [[minHighValue objectAtIndex:2] floatValue]) * 255.0f);
		ccColor3B max = ccc3(CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:0] floatValue], [[maxHighValue objectAtIndex:0] floatValue]) * 255.0f, CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:1] floatValue], [[maxHighValue objectAtIndex:1] floatValue]) * 255.0f, CCRANDOM_MIN_MAX([[maxLowValue objectAtIndex:2] floatValue], [[maxHighValue objectAtIndex:2] floatValue]) * 255.0f);
		if([start isEqualToString:@"max"]) {
			// set color to minValue
			[(CCSprite*)(node) setColor:min];
			// return tint action
			return [CCTintBy actionWithDuration:speed * timeMult red:(max.r - min.r) green:(max.g - min.g) blue:(max.b - min.b)];
		}
		else {
			// set color to minValue
			[(CCSprite*)(node) setColor:max];
			// return tint action
			return [CCTintBy actionWithDuration:speed * timeMult red:(min.r - max.r) green:(min.g - max.g) blue:(min.b - max.b)];
		}
	}
}

- (void) finishAction:(CCActionInterval*)action {
	if([property isEqualToString:@"y"] || [property isEqualToString:@"x"]) {
		// step twice. once to turn off a flag that prevents elapsed time from being calculate
		// and another time to start the action 1/4 way through
		[action step:0];
		[action step:speed * 0.25f];
	}
}

@end
