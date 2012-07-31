//
//  BBLogic.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBLogic.h"

#define kNumberOfDropshipsToBeatForMinibossPossibility 5
// these must add up to no greater than 1, but can be less than 1
// the remaining percentage will cause a 1 second delay where nothing will spawn
#define kChanceCoin 0.25
#define kChanceDropship 0.25
#define kChanceMiniboss 0.05

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kEventNewGame object:nil];
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
        // determine whether a dropship or miniboss can be spawned
        BOOL canSpawn = ([[[BBDropshipManager sharedSingleton] getActiveDropships] count] == 0 && [[[BBMinibossManager sharedSingleton] getActiveMinibosses] count] == 0);
		// spawn a coin group
		if(ran < kChanceCoin) {
			NSLog(@"BBLogic: rollDice spawning coin group");
			[[BBCoinManager sharedSingleton] spawnCoinGroup];
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
		}
        // spawn a random number of dropships
		else if(ran >= kChanceCoin && ran < kChanceCoin + kChanceDropship && canSpawn) {
			NSLog(@"BBLogic: rollDice spawning dropship");
			[[BBDropshipManager sharedSingleton] tryToSpawnDropship];
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
		}
        // spawn a random number of minibosses
        else if(ran >= kChanceCoin + kChanceDropship && ran < kChanceCoin + kChanceDropship + kChanceMiniboss && canSpawn && [Globals sharedSingleton].dropshipsDestroyedForMiniboss >= kNumberOfDropshipsToBeatForMinibossPossibility) {
            NSLog(@"BBLogic: rollDice spawning miniboss");
            [Globals sharedSingleton].dropshipsDestroyedForMiniboss = 0;
            [[BBMinibossManager sharedSingleton] tryToSpawnMiniboss];
            [self performSelector:@selector(rollDice) withObject:nil afterDelay:5];
        }
        // delay for a bit
		else {
			NSLog(@"BBLogic: rollDice delay");
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:1];
		}
	}
}

- (void) pause {
    [self setEnabled:NO];
}

- (void) resume {
    [self setEnabled:YES];
}

- (void) newGame {
    firstRun = YES;
    [Globals sharedSingleton].dropshipsDestroyedForMiniboss = 0;
}

@end
