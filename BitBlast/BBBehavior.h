//
//  BBBehavior.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/1/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBBehavior : NSObject {
	// type of easing curve
	NSString *curve;
	// speed of behavior
	float speed;
	// property of an object to modify
	NSString *property;
	// max range the property can go to
	NSArray *minMaxValue, *maxMaxValue;
	// min range the property can go to
	NSArray *minMinValue, *maxMinValue;
	// which value the behavior should change to first
	NSString *start;
	// whether the behavior should loop
	BOOL loop;
	// whether the behavior should repeat
	BOOL repeat;
}

// initializers
- (id) initWithDictionary:(NSDictionary*)dict;
// actions
- (void) applyToNode:(CCNode*)node withAngle:(float)angle;
// convenience
- (CCActionInterval*) generateAction:(CCNode*)node withAngle:(float)angle;
- (void) finishAction:(CCActionInterval*)action;

@end
