//
//  BBMovingCoinManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/16/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBMovingCoinManager.h"


@implementation BBMovingCoinManager

+ (BBMovingCoinManager*) sharedSingleton {
	
	static BBMovingCoinManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBMovingCoinManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		coins = [NSMutableArray new];
		
		// create coins
		for(int i=0;i<MAX_MOVING_COINS;i++) {
			BBMovingCoin *coin = [BBMovingCoin new];
			[self addChild:coin];
			[coins addObject:coin];
			[coin release];
		}
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kEventNewGame object:nil];
	}
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[coins release];
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    // only update if not paused
    if(!paused) {
        for(BBMovingCoin *c in coins) {
            if(!c.recycle) {
                [c update:delta];
            }
        }
    }
}

#pragma mark -
#pragma mark getters
- (BBMovingCoin*) getRecycledCoin {
	for(BBMovingCoin *c in coins) {
		if(c.recycle) {
			return c;
		}
	}
	return nil;
}

- (NSArray*) getActiveCoins {
	NSMutableArray *activeCoins = [NSMutableArray array];
	for(BBMovingCoin *c in coins) {
		if(!c.recycle) {
			[activeCoins addObject:c];
		}
	}
	return activeCoins;
}

-(BOOL) isTriforceActive {
    for(BBMovingCoin *c in coins) {
        if(c.type == MOVING_COIN_TYPE_TRIFORCE) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    for(BBMovingCoin *c in coins) {
        [c setEnabled:newEnabled];
    }
}

#pragma mark -
#pragma mark actions
- (void) spawnCoins:(int)numCoins atPosition:(CGPoint)position {
	for(int i=0;i<numCoins;i++) {
		BBMovingCoin *coin = [self getRecycledCoin];
		[coin resetWithPosition:position];
	}
}

- (void) spawnKeyAtPosition:(CGPoint)position {
    BBMovingCoin *key = [self getRecycledCoin];
    [key resetWithPosition:position];
    [key playAnimation:@"key"];
    key.type = MOVING_COIN_TYPE_KEY;
}

- (void) spawnTriforceAtPosition:(CGPoint)position {
    BBMovingCoin *triforce = [self getRecycledCoin];
    [triforce resetWithPosition:position];
    [triforce repeatAnimation:@"triforceFlashing"];
    triforce.type = MOVING_COIN_TYPE_TRIFORCE;
}

- (void) spawnHeartAtPosition:(CGPoint)position {
    BBMovingCoin *heart = [self getRecycledCoin];
    [heart resetWithPosition:position];
    [heart repeatAnimation:@"heart"];
    heart.type = MOVING_COIN_TYPE_HEART;
}

#pragma mark -
#pragma mark notifications
- (void) pause {
    paused = YES;
	for(BBMovingCoin *c in coins) {
		[c pause];
	}
}

- (void) resume {
    // only resume if we're not in the end or intro boss sequence
    if(![Globals sharedSingleton].endBossSequence && ![Globals sharedSingleton].introBossSequence) {
        paused = NO;
        for(BBMovingCoin *c in coins) {
            [c resume];
        }
    }
}

@end
