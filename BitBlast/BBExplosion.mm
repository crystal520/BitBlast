//
//  BBExplosion.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/25/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBExplosion.h"


@implementation BBExplosion

@synthesize explodingObject;

- (id) init {
	if((self = [super initWithFile:@"dropshipExplosion"])) {
        enabled = YES;
		[self setEnabled:NO];
		self.scale = 2;
	}
	return self;
}

#pragma mark -
#pragma mark actions
- (void) explode {
    // make sure it's visible
    [self setEnabled:YES];
	// generate random position within object to explode in
	CGPoint bounds = ccpMult(ccp(explodingObject.contentSize.width, explodingObject.contentSize.height), [ResolutionManager sharedSingleton].positionScale);
	int ranX = CCRANDOM_MIN_MAX(0, bounds.x) - bounds.x * 0.5 + explodingObject.position.x + 50;
	int ranY = CCRANDOM_MIN_MAX(0, bounds.y) - bounds.y * 0.5 + explodingObject.position.y - 50;
	self.position = ccp(ranX, ranY);
	// delay, explode, repeat
	[self playAnimation:@"explosion" target:self selector:@selector(explode)];
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
