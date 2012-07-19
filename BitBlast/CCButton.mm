//
//  CCButton.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/22/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "CCButton.h"


@implementation CCButton

+(id) buttonFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite {
	return [self buttonFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:nil selector:nil];
}
+(id) buttonFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector {
	return [self buttonFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:target selector:selector];
}

+(id) buttonFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector {
	return [[[self alloc] initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector] autorelease];
}

-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector {
	if( (self=[super init]) ) {
		
		normalImage = normalSprite;
		selectedImage = selectedSprite;
		disabledImage = disabledSprite;
        enabled = YES;
		
		if(normalImage) {
			[self addChild:normalImage];
		}
		if(selectedImage) {
			[self addChild:selectedImage];
		}
		if(disabledImage) {
			[self addChild:disabledImage];
		}
		
		NSMethodSignature *sig = nil;
		if(target && selector) {
			sig = [target methodSignatureForSelector:selector];
			
			invocation = nil;
			invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setTarget:target];
			[invocation setSelector:selector];
			[invocation retain];
		}
		
		[self setContentSize: [normalImage contentSize]];
		state = kStateUp;
		[self setState:state];
	}
	return self;	
}

- (void) dealloc {
	[invocation release];
	[super dealloc];
}

- (void)onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_BUTTON swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if(!enabled) {
		return NO;
	}
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	if(CGRectContainsPoint([self scaledBoundingBox], touchPoint)) {
		[self setState:kStateDown];
		return YES;
	}
	return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	if(!enabled) {
		return;
	}
	
	// reset state if button doesn't contain touch
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	if(!CGRectContainsPoint([self scaledBoundingBox], touchPoint)) {
		[self setState:kStateUp];
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	if(!enabled) {
		return;
	}
	
	// reset state and perform callback
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	[self setState:kStateUp];
	if(CGRectContainsPoint([self scaledBoundingBox], touchPoint)) {
		[invocation invoke];
	}
}

- (void) setState:(ButtonState)newState {
	switch (newState) {
		case kStateUp:
			[normalImage setVisible:YES];
			[selectedImage setVisible:NO];
			[disabledImage setVisible:NO];
			break;
		case kStateDown:
			[normalImage setVisible:NO];
			[selectedImage setVisible:YES];
			[disabledImage setVisible:NO];
			break;
		case kStateDisabled:
			[normalImage setVisible:NO];
			[selectedImage setVisible:NO];
			[disabledImage setVisible:YES];
			break;
		default:
			[normalImage setVisible:YES];
			[selectedImage setVisible:NO];
			[disabledImage setVisible:NO];
			break;
	}
	state = newState;
}

- (void) setSpriteBatchNode:(CCSpriteBatchNode *)batchNode {
	if(normalImage) {
		[normalImage.parent removeChild:normalImage cleanup:YES];
		[batchNode addChild:normalImage];
	}
	if(selectedImage) {
		[selectedImage.parent removeChild:selectedImage cleanup:YES];
		[batchNode addChild:selectedImage];
	}
	if(disabledImage) {
		[disabledImage.parent removeChild:disabledImage cleanup:YES];
		[batchNode addChild:disabledImage];
	}
}

- (void) setPosition:(CGPoint)newPosition {
	if(normalImage) {
		[normalImage setPosition:newPosition];
	}
	if(selectedImage) {
		[selectedImage setPosition:newPosition];
	}
	if(disabledImage) {
		[disabledImage setPosition:newPosition];
	}
	[super setPosition:newPosition];
}

- (void) setEnabled:(BOOL)newEnabled {
	enabled = newEnabled;
}

- (CGRect) scaledBoundingBox {
	CGRect b = [self boundingBox];
	b.origin = [self convertToWorldSpace:CGPointZero];
	return CGRectMake(b.origin.x, b.origin.y, b.size.width * [ResolutionManager sharedSingleton].imageScale, b.size.height * [ResolutionManager sharedSingleton].imageScale);
}

@end
