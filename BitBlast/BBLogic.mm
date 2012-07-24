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
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rollDice) name:kEventDropshipsDestroyed object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rollDice) name:kEventCoinGroupDone object:nil];
	}
	return self;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
		enabled = newEnabled;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
	else if(!enabled && newEnabled) {
		enabled = newEnabled;
		firstRun = YES;
		[self performSelector:@selector(rollDice) withObject:nil afterDelay:0.5];
	}
}

#pragma mark -
#pragma mark notifications
- (void) rollDice {
	NSLog(@"BBLogic: rollDice - %i", enabled);
	if(enabled) {
		// TODO: make this way cooler. for now, just determine whether to wait, spawn a dropship, or spawn some coins
		float ran = CCRANDOM_0_1();
		// automatically generate a coin group on first run
		if(firstRun) {
			firstRun = NO;
			ran = 0;
		}
		// wait for a half second
		if(ran < 0.25) {
			NSLog(@"BBLogic: rollDice spawning coin group");
			[[BBCoinManager sharedSingleton] spawnCoinGroup];
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
		}
		else if(ran >= 0.25 && ran < 0.5 && [[[BBDropshipManager sharedSingleton] getActiveDropships] count] == 0) {
			NSLog(@"BBLogic: rollDice spawning dropship");
			[[BBDropshipManager sharedSingleton] tryToSpawnDropship];
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
		}
		else {
			NSLog(@"BBLogic: rollDice delay");
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:1];
		}
	}
}

@end
