//
//  BBInputController.h
//  GunRunner
//
//  Created by Kristian Bauer on 6/24/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBInputControllerDelegate <NSObject>

- (void) inputControllerTouchEnded;
- (void) inputControllerTouchMoved;

@end

@interface BBInputController : NSObject {
    // most recent touch that ended
    UITouch *lastTouch;
    // dictionary of start times of UITouches
    NSMutableDictionary *touchStartTimes;
    // dictionary of start positions of UITouches
    NSMutableDictionary *touchStartPositions;
    id delegate;
}

@property (nonatomic, assign) id delegate;

- (void) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;
// getters
- (float) timeForLastTouch;
- (CGPoint) distanceForLastTouch;
// helper
- (void) touchOver:(UITouch*)touch;
- (NSString*) hashForTouch:(UITouch*)touch;
- (CGPoint) positionForTouch:(UITouch*)touch;

@end
