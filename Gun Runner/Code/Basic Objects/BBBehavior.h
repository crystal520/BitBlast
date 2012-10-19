//
//  BBBehavior.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/1/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBActionInterval.h"

@interface BBBehavior : NSObject {
	// type of easing curve
	NSString *curve;
	// speed of behavior
	float speed;
	// property of an object to modify
	NSString *property;
	// max range the property can go to
	NSArray *maxHighValue, *maxLowValue;
	// min range the property can go to
	NSArray *minHighValue, *minLowValue;
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
- (void) applyToNode:(BBGameObject*)node withAngle:(float)angle;
// convenience
- (CCActionInterval*) generateAction:(BBGameObject*)node withAngle:(float)angle;
- (void) finishAction:(CCActionInterval*)action;

@end
