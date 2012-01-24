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

#import "CCMenuItemLabelAndImage.h"

@interface CCMenuItemLabelAndImage()

- (void) repositionLabel;

@end

@implementation CCMenuItemLabelAndImage

@synthesize disabledColor = disabledColor_;

+ (id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage:(NSString*)value selectedImage:(NSString*) value2
{
    return [self itemFromLabel:label normalImage:value selectedImage:value2 disabledImage:nil target:nil selector:nil];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s
{
    return [self itemFromLabel:label normalImage:value selectedImage:value2 disabledImage:nil target:r selector:s];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3
{
    return [[[self alloc] initFromLabel:label normalImage:value selectedImage:value2 disabledImage:value3 target:nil selector:nil] autorelease];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s
{
    return [[[self alloc] initFromLabel:label normalImage:value selectedImage:value2 disabledImage:value3 target:r selector:s] autorelease];
}

-(id) initFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s
{
    if ((self = [super initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:r selector:s])) {
        colorBackup = ccWHITE;
        disabledColor_ = ccWHITE;
        self.label = label;
    }
    return self;
}

+ (id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 {
	return [self itemFromLabel:label normalSprite:value selectedSprite:value2 disabledSprite:nil target:nil selector:nil];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 target:(id)r selector:(SEL)s {
	return [self itemFromLabel:label normalSprite:value selectedSprite:value2 disabledSprite:nil target:r selector:s];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*)value3 {
	return [[[self alloc] initFromLabel:label normalSprite:value selectedSprite:value2 disabledSprite:value3 target:nil selector:nil] autorelease];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*)value3 target:(id)r selector:(SEL)s {
	return [[[self alloc] initFromLabel:label normalSprite:value selectedSprite:value2 disabledSprite:value3 target:r selector:s] autorelease];
}

-(id) initFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCSprite*)value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*)value3 target:(id)r selector:(SEL)s {
	if ((self = [super initFromNormalSprite:value selectedSprite:value2 disabledSprite:value3 target:r selector:s])) {
        colorBackup = ccWHITE;
        disabledColor_ = ccWHITE;
        self.label = label;
    }
    return self;
}

#if NS_BLOCKS_AVAILABLE

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block
{
    return [self itemFromLabel:label normalImage:value selectedImage:value2 disabledImage:nil block:block];
}

+(id) itemFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block
{
    return [[[self alloc] initFromLabel:label normalImage:value selectedImage:value2 disabledImage:value3 block:block] autorelease];
}

-(id) initFromLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block
{
    block_ = [block copy];
    return [self initFromLabel:label normalImage:value selectedImage:value2 disabledImage:value3 target:block_ selector:@selector(ccCallbackBlockWithSender:)];
}
#endif // NS_BLOCKS_AVAILABLE

-(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	return label_;
}
-(void) setLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	if( label != label_ ) {
		[self removeChild:label_ cleanup:YES];
		[self addChild:label];
		
		label_ = label;
		
        [self repositionLabel];
	}
}

-(void) setString:(NSString *)string
{
	[label_ setString:string];
    [self repositionLabel];
}

-(void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self repositionLabel];
}

-(void) repositionLabel
{
    label_.position = ccp(normalImage_.position.x + normalImage_.contentSize.width/2, normalImage_.position.y + normalImage_.contentSize.height/2);
}

-(void) selected
{
	// subclass to change the default action
	if(isEnabled_) {
		[super selected];
        // Move the label down 1 point to look like the button's pressed.
        label_.position = ccp(label_.position.x, label_.position.y-1);
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(isEnabled_) {
		[super unselected];
        // Move the label back up
		label_.position = ccp(label_.position.x, label_.position.y+1);
	}
}

-(void) setIsEnabled: (BOOL)enabled
{
	if( isEnabled_ != enabled ) {
		if(enabled == NO) {
			colorBackup = [label_ color];
			[label_ setColor: disabledColor_];
		}
		else
			[label_ setColor:colorBackup];
	}
	
	[super setIsEnabled:enabled];
}

- (void) setOpacity: (GLubyte)opacity
{
    [label_ setOpacity:opacity];
}
-(GLubyte) opacity
{
	return [label_ opacity];
}
-(void) setColor:(ccColor3B)color
{
	[label_ setColor:color];
}
-(ccColor3B) color
{
	return [label_ color];
}

@end