//
//  CCButton.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/22/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
	kStateUp,
	kStateDown,
	kStateDisabled
} ButtonState;

@interface CCButton : CCSprite <CCTargetedTouchDelegate> {
    ButtonState state;
	CCNode<CCRGBAProtocol> *normalImage, *selectedImage, *disabledImage;
	NSInvocation *invocation;
}

/** creates a button with a normal and selected image*/
+(id) buttonFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite;
/** creates a button with a normal and selected image with target/selector */
+(id) buttonFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector;
/** creates a button with a normal,selected  and disabled image with target/selector */
+(id) buttonFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;
/** initializes a button with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

- (void) setState:(ButtonState)newState;
- (void) setSpriteBatchNode:(CCSpriteBatchNode*)batchNode;
- (void) setPosition:(CGPoint)newPosition;
- (CGRect) scaledBoundingBox;

@end
