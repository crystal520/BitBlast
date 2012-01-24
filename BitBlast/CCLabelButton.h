//
//  CCLabelButton.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/22/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCButton.h"

@interface CCLabelButton : CCButton {
    CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
}

@property (nonatomic, assign) CCNode<CCLabelProtocol, CCRGBAProtocol> *label;

/** creates a button with given label and a normal and selected image*/
+(id) buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite;
/** creates a button with given label and a normal and selected image with target/selector */
+(id) buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector;
/** creates a button with given label and a normal,selected  and disabled image with target/selector */
+(id) buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;
/** initializes a button with given label and a normal, selected  and disabled image with target/selector */
-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

- (void) setString:(NSString*)newString;
- (void) repositionLabel;

@end
