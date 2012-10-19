//
//  CCLabelButton.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/22/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "CCLabelButton.h"


@implementation CCLabelButton

@synthesize label;

+(id) buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite {
	return [self buttonWithLabel:label normalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:nil selector:nil];
}

+(id) buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector {
	return [self buttonWithLabel:label normalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:target selector:selector];
}

+(id) buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithLabel:label normalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector] autorelease];
}

-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)newlabel normalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector {
	if( (self=[super initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector]) ) {
		self.label = newlabel;
	}
	return self;
}

-(void) setLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol>*)newLabel
{
	if(label != newLabel) {
		[self removeChild:label cleanup:YES];
		[self addChild:newLabel];
		
		label = newLabel;
		
        [self repositionLabel];
	}
}

-(void) setString:(NSString *)string
{
	[label setString:string];
    [self repositionLabel];
}

-(void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self repositionLabel];
}

- (void) setVisible:(BOOL)visible {
	[super setVisible:visible];
	[normalImage setVisible:visible];
	[selectedImage setVisible:visible];
	[disabledImage setVisible:visible];
}

- (void) setEnabled:(BOOL)newEnabled {
	[super setEnabled:newEnabled];
	if(newEnabled) {
		[self setState:kStateUp];
	}
	else {
		[self setState:kStateDisabled];
	}
}

- (void) repositionLabel {
	label.position = ccp(normalImage.contentSize.width/2, normalImage.contentSize.height/2);
}

- (void) setState:(ButtonState)newState {
	if(newState == kStateDown && state != kStateDown) {
		label.position = ccp(label.position.x, label.position.y-1);
	}
	else if(newState == kStateUp && state != kStateUp) {
		label.position = ccp(label.position.x, label.position.y+1);
	}
	
	[super setState:newState];
}

@end
