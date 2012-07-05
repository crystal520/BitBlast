//
//  BBGameObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    ACTION_TAG_ANIMATION = 1
} ActionTag;

@interface BBGameObject : CCSprite {
    // dummy position for handling multiple resolutions
    CGPoint dummyPosition;
	// previous dummy position for handling multiple resolutions
	CGPoint prevDummyPosition;
	NSDictionary *dictionary;
	// bounding box for collisions
	CGRect boundingBox;
}

@property (nonatomic, assign) CGPoint dummyPosition, prevDummyPosition;
@property (nonatomic, assign) CGRect boundingBox;

// initializers
- (id) initWithFile:(NSString*)filename;
- (void) loadFromFile:(NSString*)filename;
// animations
- (void) loadAnimations;
- (void) repeatAnimation:(NSString*)animName;
- (void) repeatAnimation:(NSString *)animName startFrame:(int)frame;
- (void) playAnimation:(NSString*)animName;
- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector;
// getters
- (BOOL) getCollidesWith:(BBGameObject*)object;
// actions
- (void) pause;
- (void) resume;

@end
