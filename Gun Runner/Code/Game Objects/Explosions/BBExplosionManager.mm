//
//  BBExplosionManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/25/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBExplosionManager.h"


@implementation BBExplosionManager

- (id) init {
	if((self = [super init])) {
        paused = YES;
		// make explosion objects
		explosions = [NSMutableArray new];
		for(int i=0;i<MAX_NUM_EXPLOSIONS;i++) {
			BBExplosion *e = [BBExplosion new];
			[explosions addObject:e];
			[e release];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kEventNewGame object:nil];
	}
	return self;
}

- (void) dealloc {
	[explosions release];
	[super dealloc];
}

#pragma mark -
#pragma mark setters
- (void) setNode:(CCNode*)newNode {
	if(node != newNode) {
		node = newNode;
		
		for(BBExplosion *e in explosions) {
			[node addChild:e];
		}
	}
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    for(BBExplosion *e in explosions) {
        [e update:delta];
    }
}

#pragma mark -
#pragma mark actions
- (void) explodeInObject:(BBGameObject*)object number:(int)count {
    [self explodeInObject:object withOffset:CGRectZero number:count];
}

- (void) explodeInObject:(BBGameObject*)object withOffset:(CGRect)offset number:(int)count {
    if(!paused) {
        int counter = 0;
        for(BBExplosion *e in explosions) {
            if(!e.explodingObject) {
                e.explodingObject = object;
                e.offset = offset;
                CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_0_1() * 2], [CCCallFunc actionWithTarget:e selector:@selector(explode)], nil];
                [e runAction:action];
                counter++;
                if(counter == count) {
                    break;
                }
            }
        }
    }
}

- (void) stopExploding:(BBGameObject*)object {
	for(BBExplosion *e in explosions) {
		if(e.explodingObject == object) {
			e.explodingObject = nil;
			[e stopAllActions];
            [e setEnabled:NO];
		}
	}
}

#pragma mark -
#pragma mark notifications
- (void) pause {
    paused = YES;
	for(BBExplosion *e in explosions) {
		[e pause];
	}
}

- (void) resume {
    paused = NO;
	for(BBExplosion *e in explosions) {
		[e resume];
	}
}

- (void) newGame {
    paused = NO;
    for(BBExplosion *e in explosions) {
        [e resume];
        [e setEnabled:NO];
    }
}

@end
