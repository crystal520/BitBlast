//
//  BBLogic.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBLogic.h"


@implementation BBLogic

+ (BBLogic*) sharedSingleton {
	
	static BBLogic *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBLogic alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		// register for noticiations
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rollDice) name:kEventDropshipDestroyed object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rollDice) name:kEventCoinGroupDone object:nil];
	}
	return self;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
		enabled = newEnabled;
	}
	else if(!enabled && newEnabled) {
		enabled = newEnabled;
		[self rollDice];
	}
}

#pragma mark -
#pragma mark notifications
- (void) rollDice {
	if(enabled) {
		// TODO: make this way cooler. for now, just determine whether to wait, spawn a dropship, or spawn some coins
		float ran = CCRANDOM_0_1();
		// wait for a half second
		if(ran < 0.25) {
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:0.5];
		}
		else if(ran >= 0.25 && ran < 0.5) {
			[[BBDropshipManager sharedSingleton] tryToSpawnDropship];
		}
		else {
			[[BBCoinManager sharedSingleton] spawnCoinGroup];
		}
	}
}

@end
