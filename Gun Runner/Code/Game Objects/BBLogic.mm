//
//  BBLogic.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
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
        // load variables from plist
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dice" ofType:@"plist"]];
        [Globals sharedSingleton].numKeysForMiniboss = [[plist objectForKey:@"numKeysToSummonMiniboss"] intValue];
        [Globals sharedSingleton].numPiecesForFinalBoss = [[plist objectForKey:@"numPiecesForFinalBoss"] intValue];
        [Globals sharedSingleton].numDropshipsForceKey = [[plist objectForKey:@"numDropshipsForceKey"] intValue];
        levels = [[NSArray alloc] initWithArray:[plist objectForKey:@"levels"]];
        
		// register for noticiations
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kEventNewGame object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelIncrease) name:kPlayerLevelIncreaseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triforceCollected) name:kPlayerTriforceNotification object:nil];
	}
	return self;
}

- (void) dealloc {
    [levels release];
    [super dealloc];
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
#pragma mark getters
- (BOOL) getCanSpawnBoss {
    return ([[SettingsManager sharedSingleton] getInt:@"totalTriforce"] >= [Globals sharedSingleton].numPiecesForFinalBoss);
}

#pragma mark -
#pragma mark actions
- (void) checkQuickSpawnBoss {
    // see if player was fighting boss
    if([self getCanSpawnBoss]) {
        // spawn the boss
        [[BBBossManager sharedSingleton] tryToSpawnBoss];
        // trigger the boss
        [[BBBossManager sharedSingleton] triggerBoss];
    }
}

#pragma mark -
#pragma mark notifications
- (void) rollDice {
	//NSLog(@"BBLogic: rollDice - %i", enabled);
	if(enabled) {
        
        // see if the tutorial is enabled
        if([Globals sharedSingleton].tutorial) {
            // determine what to do based on tutorial state
            switch([Globals sharedSingleton].tutorialState) {
                case TUTORIAL_STATE_JUMP_UP: case TUTORIAL_STATE_DOUBLE_JUMP:
                    // spawn coins on the top level to encourage player to swipe upwards
                    [[BBCoinManager sharedSingleton] spawnCoinGroupWithLevel:CHUNK_LEVEL_TOP];
                    break;
                case TUTORIAL_STATE_JUMP_DOWN:
                    // spawn coins on the middle level to encourage player to swipe downwards
                    [[BBCoinManager sharedSingleton] spawnCoinGroupWithLevel:CHUNK_LEVEL_MIDDLE];
                    break;
                case TUTORIAL_STATE_DROPSHIP:
                    // make sure there are no dropships
                    if([[[BBDropshipManager sharedSingleton] getActiveDropships] count] == 0) {
                        // spawn a dropship on the top level so the player learns how to aim
                        [[BBDropshipManager sharedSingleton] tryToSpawnDropshipWithOverrideLevel:CHUNK_LEVEL_TOP];
                    }
                default:
                    break;
            }
            // make sure to keep calling rollDice
            [self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
        }
        // otherwise proceed with normal game logic
        else {
            // determine whether a dropship or miniboss can be spawned
            BOOL canSpawn = ([[[BBDropshipManager sharedSingleton] getActiveDropships] count] == 0 && [[[BBMinibossManager sharedSingleton] getActiveMinibosses] count] == 0 && !firstRun && ![[BBBossManager sharedSingleton] isActive] && ![[BBMovingCoinManager sharedSingleton] isTriforceActive]);
        
#if DEBUG_SPAWN_BOSS
            if(canSpawn && ![Globals sharedSingleton].introBossSequence) {
                [self triforceCollected];
                canSpawn = NO;
            }
#endif
        
            NSDictionary *diceResult;
            // automatically generate a coin group on first run
            if(firstRun) {
                firstRun = NO;
                diceResult = [BBGameObject randomDictionaryFromArray:[levels objectAtIndex:currentLevel] overrideRandom:0];
            }
            else {
                diceResult = [BBGameObject randomDictionaryFromArray:[levels objectAtIndex:currentLevel]];
            }
            
            // spawn a random number of minibosses
            if(canSpawn && [[SettingsManager sharedSingleton] getInt:@"totalKeys"] >= [Globals sharedSingleton].numKeysForMiniboss) {
                //NSLog(@"BBLogic: rollDice spawning miniboss");
                [[BBMinibossManager sharedSingleton] tryToSpawnMiniboss];
                [self performSelector:@selector(rollDice) withObject:nil afterDelay:5];
                return;
            }
            
            // spawn a coin group
            if([[diceResult objectForKey:@"type"] isEqualToString:@"coinGroup"]) {
                //NSLog(@"BBLogic: rollDice spawning coin group");
                [[BBCoinManager sharedSingleton] spawnCoinGroup];
                [self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
            }
            // spawn a random number of dropships
            else if([[diceResult objectForKey:@"type"] isEqualToString:@"dropship"] && canSpawn) {
                //NSLog(@"BBLogic: rollDice spawning dropship");
                [[BBDropshipManager sharedSingleton] tryToSpawnDropship];
                [self performSelector:@selector(rollDice) withObject:nil afterDelay:2];
            }
            // delay for a bit
            else {
                //NSLog(@"BBLogic: rollDice delay");
                CGPoint delayRange = CGPointFromString([diceResult objectForKey:@"range"]);
                [self performSelector:@selector(rollDice) withObject:nil afterDelay:CCRANDOM_MIN_MAX(delayRange.x, delayRange.y)];
            }
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
    currentLevel = 0;
}

- (void) levelIncrease {
    currentLevel++;
    // make sure we don't go out of range of the levels array
    if(currentLevel >= [levels count]) {
        currentLevel = [levels count]-1;
    }
}

- (void) triforceCollected {
    // check to see if we should spawn the final boss
#if DEBUG_SPAWN_BOSS
    if(1) {
#else
    if([[SettingsManager sharedSingleton] getInt:@"totalTriforce"] >= [Globals sharedSingleton].numPiecesForFinalBoss) {
#endif
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventSpawnFinalBoss object:nil]];
    }
}

@end
