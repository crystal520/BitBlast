//
//  BBGameObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBGameObject : CCNode {
    // dummy position for handling multiple resolutions
    CGPoint dummyPosition;
	// previous dummy position for handling multiple resolutions
	CGPoint prevDummyPosition;
	CCSprite *sprite;
	CCSpriteBatchNode *spriteBatch;
	NSDictionary *dictionary;
	// bounding box for collisions
	CGRect boundingBox;
}

@property (nonatomic, readonly) CCSprite *sprite;
@property (nonatomic, assign) CGPoint dummyPosition, prevDummyPosition;
@property (nonatomic, assign) CGRect boundingBox;

// initializers
- (id) initWithFile:(NSString*)filename;
- (void) loadFromFile:(NSString*)filename;
// animations
- (void) loadAnimations;
- (void) repeatAnimation:(NSString*)animName;
- (void) playAnimation:(NSString*)animName;
- (void) playAnimation:(NSString *)animName target:(id)target selector:(SEL)selector;
// getters
- (BOOL) getCollidesWith:(BBGameObject*)object;
// actions
- (void) stopAllActions;

@end
