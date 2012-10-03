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
    // whether or not this game object is paused
    BOOL paused;
}

@property (nonatomic, assign) CGPoint dummyPosition, prevDummyPosition;
@property (nonatomic, assign) BOOL paused;

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
+ (NSDictionary*) randomDictionaryFromArray:(NSArray*)array;
+ (NSDictionary*) randomDictionaryFromArray:(NSArray *)array overrideRandom:(float)override;
- (void) flashFrom:(ccColor3B)fromColor to:(ccColor3B)toColor withTime:(float)time numberOfTimes:(int)times onSprite:(CCSprite*)sprite;
- (void) flashAlphaFrom:(float)fromAlpha to:(float)toAlpha withTime:(float)time numberOfTimes:(int)times onSprite:(CCSprite*)sprite;
- (void) fadeFrom:(ccColor3B)fromColor to:(ccColor3B)toColor withTime:(float)time onSprite:(CCSprite*)sprite target:(id)target selector:(SEL)selector;
- (void) fadeAlphaFrom:(float)fromAlpha to:(float)toAlpha withTime:(float)time onSprite:(CCSprite*)sprite target:(id)target selector:(SEL)selector;

@end
