//
//  BBGameObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GB2Engine.h"
#import "GB2Contact.h"
#import "GB2Sprite.h"

typedef enum {
    ACTION_TAG_ANIMATION = 1
} ActionTag;

@interface BBGameObjectShape : GB2Node {}
@end

@interface BBGameObject : CCSprite {
    // dummy position for handling multiple resolutions
    CGPoint dummyPosition;
	// previous dummy position for handling multiple resolutions
	CGPoint prevDummyPosition;
	NSDictionary *dictionary;
    // Box2D shape for collision detection
    BBGameObjectShape *collisionShape;
}

@property (nonatomic, assign) CGPoint dummyPosition, prevDummyPosition;

// initializers
- (id) initWithFile:(NSString*)filename;
- (void) loadFromFile:(NSString*)filename;
- (void) loadComplete;
// animations
- (void) repeatAnimation:(NSString*)animName;
- (void) repeatAnimation:(NSString *)animName startFrame:(int)frame;
- (void) playAnimation:(NSString*)animName;
- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector;
// actions
- (void) pause;
- (void) resume;
// convenience
- (NSDictionary*) randomDictionaryFromArray:(NSArray*)array;

@end
