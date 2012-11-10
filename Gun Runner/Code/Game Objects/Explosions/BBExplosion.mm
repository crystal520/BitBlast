//
//  BBExplosion.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/25/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBExplosion.h"


@implementation BBExplosion

@synthesize explodingObject, offset;

- (id) init {
	if((self = [super initWithFile:@"explosion"])) {
        enabled = YES;
		[self setEnabled:NO];
		self.scale = 2;
        followObject = YES;
	}
	return self;
}

#pragma mark -
#pragma mark actions
- (void) explode {
    // make sure it's visible
    [self setEnabled:YES];
	// generate random position within object to explode in
	CGPoint bounds = ccpAdd(ccp(explodingObject.contentSize.width, explodingObject.contentSize.height), ccp(offset.size.width, offset.size.height));
	int ranX = CCRANDOM_MIN_MAX(0, bounds.x) - bounds.x * explodingObject.anchorPoint.x + explodingObject.position.x + offset.origin.x;
	int ranY = CCRANDOM_MIN_MAX(0, bounds.y) - bounds.y * explodingObject.anchorPoint.y + explodingObject.position.y - offset.origin.y;
	self.position = ccp(ranX, ranY);
    // keep track of final offset in case this explosion should follow the explodingObject
    finalOffset = ccpSub(self.position, explodingObject.position);
	// delay, explode, repeat
	[self playAnimation:@"explosion" target:self selector:@selector(explode)];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    if(followObject) {
        self.position = ccpAdd(explodingObject.position, finalOffset);
    }
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    if(newEnabled && !enabled) {
        self.visible = YES;
    }
    else if(!newEnabled && enabled) {
        self.visible = NO;
    }
    enabled = newEnabled;
}

@end
