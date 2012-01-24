/*
 * CCMenuItemLabelAndImage
 *
 * Copyright (c) 2011 Jamorn Horathai
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCMenuItemLabelAndImage : CCMenuItemImage {
    CCNode<CCLabelProtocol, CCRGBAProtocol> *label_;
	ccColor3B        colorBackup;
	ccColor3B        disabledColor_;
}

/** the color that will be used to disable the item */
@property (nonatomic,readwrite) ccColor3B disabledColor;

/** Label that is rendered. It can be any CCNode that implements the CCLabelProtocol */
@property (nonatomic,readwrite,assign) CCNode<CCLabelProtocol, CCRGBAProtocol>* label;

/** creates a menu item with a label and a normal and selected image*/
+ (id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage:(NSString*)value selectedImage:(NSString*) value2;
/** creates a menu item with a label and a normal and selected image with target/selector */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;
/** creates a menu item with a label and a normal,selected  and disabled image */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3;
/** creates a menu item with a label and a normal,selected  and disabled image with target/selector */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
/** initializes a menu item with a label and a normal, selected  and disabled image with target/selector */
-(id) initFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;

/** creates a menu item with a label and a normal and selected sprite*/
+ (id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2;
/** creates a menu item with a label and a normal and selected sprite with target/selector */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 target:(id)r selector:(SEL)s;
/** creates a menu item with a label and a normal, selected and disabled sprite */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*)value3;
/** creates a menu item with a label and a normal, selected and disabled sprite with target/selector */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*)value3 target:(id)r selector:(SEL)s;
/** initializes a menu item with a label and a normal, selected and disabled sprite with target/selector */
-(id) initFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*)value3 target:(id)r selector:(SEL)s;

#if NS_BLOCKS_AVAILABLE
/** creates a menu item with a label and a normal and selected image with a block.
 The block will be "copied".
 */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block;
/** creates a menu item with a label and a normal,selected  and disabled image with a block.
 The block will be "copied".
 */
+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block;
/** initializes a menu item with a label and a normal, selected  and disabled image with a block.
 The block will be "copied".
 */
-(id) initFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block;
#endif

/** sets a new string to the inner label */
-(void) setString:(NSString*)label;

/** Enable or disabled the CCMenuItemFont
 @warning setIsEnabled changes the RGB color of the font
 */
-(void) setIsEnabled: (BOOL)enabled;

@end