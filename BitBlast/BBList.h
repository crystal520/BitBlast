//
//  BBList.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBList : CCLayer {
	// amount of dragging the player has done. used to determine whether to send touch to item in list
	float totalDrag;
	// speed of list if player flicked it
    float velocity;
	// location of the last touch on the list
	float lastTouch;
	// location of the 2nd to last touch on the list
	float lastLastTouch;
	// topmost position the list can scroll to
	float topBounds;
	// bottommost position the list can scroll to
	float bottomBounds;
	// whether or not the player is dragging the list
	BOOL dragging;
	// whether or not player is touching the list
	BOOL touchDown;
	// size of each item in the list
	CGSize itemSize;
	
}

// getters
- (CCNode*) getItemAtIndex:(int)index;
- (BOOL) getDragging;
- (CCNode*) getChildWithTouchPosition:(CGPoint)pos;
// setters
- (void) setItemSize:(CGSize)size;
// actions
- (void) addItem:(CCNode*)newItem;

@end
