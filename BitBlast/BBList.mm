//
//  BBList.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBList.h"


@implementation BBList

@synthesize dummyPosition;

- (id) init {
	if((self = [super init])) {
		velocity = lastTouch = 0;
	}
	return self;
}

#pragma mark -
#pragma mark getters
- (CCNode*) getItemAtIndex:(int)index {
	if(index < children_.count) {
		return (CCNode*)[children_ objectAtIndex:index];
	}
	else {
		return nil;
	}
}

- (BOOL) getDragging {
	return dragging || velocity != 0;
}

- (CCNode*) getChildWithTouchPosition:(CGPoint)pos {
	pos.x -= (dummyPosition.x);
	pos.y -= (dummyPosition.y);
	for(int i=0,j=[children_ count];i<j;i++) {
		CCNode *child = [children_ objectAtIndex:i];
		CGRect bb = CGRectMake(child.position.x * [ResolutionManager sharedSingleton].imageScale, child.position.y * [ResolutionManager sharedSingleton].imageScale, child.contentSize.width, child.contentSize.height);
		if(CGRectContainsPoint(bb, pos)) {
			return child;
		}
	}
	return nil;
}

#pragma mark -
#pragma mark setters
- (void) setItemSize:(CGSize)size {
	itemSize = size;
}

#pragma mark -
#pragma mark actions
- (void) addItem:(CCNode*)newItem {
	// update top bounds
	topBounds = dummyPosition.y;
	// add item with new position
	int position = -itemSize.height * [children_ count];
	[newItem setPosition:ccp(0, position)];
	[self addChild:newItem];
	// update bottom bounds
	bottomBounds = ([children_ count] * itemSize.height - itemSize.height) * [ResolutionManager sharedSingleton].inversePositionScale;
}

- (void) onEnter {
	// make the list touchable
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_LIST swallowsTouches:YES];
	self.isTouchEnabled = YES;
	[super onEnter];
}

- (void) onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	self.isTouchEnabled = NO;
	[super onExit];
}

- (void) draw {
	// slow down velocity
	velocity += (0 - velocity) / 6;
	// if it's really slow, just stop it
	if(abs(velocity) < 2) {
		velocity = 0;
	}
	// update position with velocity
	dummyPosition = ccp(dummyPosition.x, dummyPosition.y - velocity);
	
	// top snap
	if(!dragging && dummyPosition.y < topBounds) {
		float newY = dummyPosition.y + (topBounds - dummyPosition.y) / 3;
		dummyPosition = ccp(dummyPosition.x, newY);
	}
	// bottom snap
	else if(!dragging && dummyPosition.y > bottomBounds) {
		float newY = dummyPosition.y + (bottomBounds - dummyPosition.y) / 3;
		dummyPosition = ccp(dummyPosition.x, newY);
	}
    
    self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
	[super draw];
}

#pragma mark -
#pragma mark touches
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	// reset flags and variables
	touchDown = YES;
	dragging = YES;
	velocity = 0;
	totalDrag = 0;
	// get touch in point form
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	// keep track of first touch and set to last touch
	lastLastTouch = lastTouch = touchPoint.y;
	// make sure touch is within the list
	CCNode *child = [self getChildWithTouchPosition:touchPoint];
	if(child) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	if(!touchDown) {
		return;
	}
	// get touch in point form
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	// keep track of touches
	lastLastTouch = lastTouch;
	lastTouch = touchPoint.y;
	totalDrag += abs(lastLastTouch - lastTouch);
	// update position
	dummyPosition = ccp(dummyPosition.x, dummyPosition.y - (lastLastTouch - lastTouch));
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	// get touch in point form
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	// no longer dragging
	dragging = NO;
	// set velocity based on last 2 touches
	velocity = lastLastTouch - touchPoint.y;
	// see if a tap should pass through to a child
	if(totalDrag < 5) {
		velocity = 0;
		// send tap to child
		CCNode *child = [self getChildWithTouchPosition:touchPoint];
		if([child respondsToSelector:@selector(touch)]) {
			[child performSelector:@selector(touch)];
		}
	}
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	// get touch in point form
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	// no longer dragging
	dragging = NO;
	// set velocity based on last 2 touches
	velocity = lastLastTouch - touchPoint.y;
}

@end
