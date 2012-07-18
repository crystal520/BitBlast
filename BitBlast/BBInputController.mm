//
//  BBInputController.m
//  GunRunner
//
//  Created by Kristian Bauer on 6/24/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBInputController.h"

@implementation BBInputController

@synthesize delegate;

- (id) init {
    if((self = [super init])) {
        touchStartTimes = [NSMutableDictionary new];
        touchStartPositions = [NSMutableDictionary new];
    }
    
    return self;
}

- (void) dealloc {
    [touchStartTimes release];
    [touchStartPositions release];
    [super dealloc];
}

- (void) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [touchStartTimes setObject:[NSNumber numberWithDouble:touch.timestamp] forKey:[self hashForTouch:touch]];
    [touchStartPositions setObject:[NSValue valueWithCGPoint:[self positionForTouch:touch]] forKey:[self hashForTouch:touch]];
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    lastTouch = touch;
    [delegate inputControllerTouchMoved];
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self touchOver:touch];
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self touchOver:touch];
}

- (float) timeForLastTouch {
    NSString *touchKey = [self hashForTouch:lastTouch];
    if([touchStartTimes objectForKey:touchKey]) {
        return lastTouch.timestamp - [[touchStartTimes objectForKey:touchKey] doubleValue];
    }
    return 0;
}

- (CGPoint) distanceForLastTouch {
    NSString *touchKey = [self hashForTouch:lastTouch];
    if([touchStartPositions objectForKey:touchKey]) {
        return ccpSub([self positionForTouch:lastTouch], [[touchStartPositions objectForKey:touchKey] CGPointValue]);
    }
    return CGPointMake(0, 0);
}

- (void) touchOver:(UITouch *)touch {
    lastTouch = touch;
    [delegate inputControllerTouchEnded];
    [touchStartTimes removeObjectForKey:[self hashForTouch:touch]];
    [touchStartPositions removeObjectForKey:[self hashForTouch:touch]];
}

- (NSString*) hashForTouch:(UITouch*)touch {
    return [NSString stringWithFormat:@"%i", [touch hash]];
}

- (CGPoint) positionForTouch:(UITouch*)touch {
    return [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
}

@end
