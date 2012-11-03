//
//  BBCoinManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBCoinManager.h"


@implementation BBCoinManager

+ (BBCoinManager*) sharedSingleton {
	
	static BBCoinManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBCoinManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

#pragma mark -
#pragma mark initializers
- (id) init {
	if((self = [super init])) {
		// create array of coins
		coins = [NSMutableArray new];
		for(int i=0;i<MAX_COINS;i++) {
			BBCoin *coin = [[BBCoin alloc] init];
			[self addChild:coin];
			[coins addObject:coin];
			[coin release];
		}
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kEventNewGame object:nil];
		// load patterns from plist
		patterns = [[NSArray alloc] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"coinPatterns" ofType:@"plist"]] objectForKey:@"patterns"]];
	}
	return self;
}

- (void) dealloc {
	[patterns release];
	[coins release];
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    // only update if not paused
    if(!paused) {
        // update active coins
        for(BBCoin *c in coins) {
            if(!c.recycle) {
                // see if coin has gone off screen
                if(c.dummyPosition.x < [Globals sharedSingleton].playerPosition.x - [Globals sharedSingleton].cameraOffset.x) {
                    [c setEnabled:NO];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark getters
- (BBCoin*) getRecycledCoin {
	for(BBCoin *c in coins) {
		if(c.recycle && !c.enabled) {
			return c;
		}
	}
	return nil;
}

- (NSArray*) getActiveCoins {
	NSMutableArray *activeCoins = [NSMutableArray array];
	for(BBCoin *c in coins) {
		if(!c.recycle && c.enabled && c.alive) {
			[activeCoins addObject:c];
		}
	}
	return activeCoins;
}

- (NSDictionary*) getRandomCoinGroup {
	// generate random number from array
	int ran = MIN(CCRANDOM_MIN_MAX(0, [patterns count]), [patterns count]-1);
	return [patterns objectAtIndex:ran];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    for(BBCoin *c in coins) {
        [c setEnabled:newEnabled];
    }
}

#pragma mark -
#pragma mark notifications
- (void) levelWillLoad {
	for(BBCoin *c in coins) {
		[c setEnabled:NO];
	}
}

- (void) pause {
    paused = YES;
	for(BBCoin *c in coins) {
		[c pause];
	}
}

- (void) resume {
    // only resume if we're not in the end or intro boss sequence
    if(![Globals sharedSingleton].endBossSequence && ![Globals sharedSingleton].introBossSequence) {
        paused = NO;
        for(BBCoin *c in coins) {
            [c resume];
        }
    }
}

- (void) newGame {
    for(BBCoin *c in coins) {
        [c resume];
        [c setEnabled:NO];
    }
}

#pragma mark -
#pragma mark actions
- (void) spawnCoinGroup {
	// get random level from current chunk
	[self spawnCoinGroupWithLevel:((ChunkLevel)([[[ChunkManager sharedSingleton] getCurrentChunk] getRandomLevel]))];
}

- (void) spawnCoinGroupWithLevel:(ChunkLevel)chunkLevel {
    // get a random coin group
	NSDictionary *coinGroup = [self getRandomCoinGroup];
    // determine whether spacing should be enabled
    spacing = YES;
    if([coinGroup objectForKey:@"spacing"] != nil) {
        spacing = [[coinGroup objectForKey:@"spacing"] boolValue];
    }
    [self spawnCoinGroupWithString:[coinGroup objectForKey:@"string"] withLevel:chunkLevel];
}

- (void) spawnCoinGroupWithString:(NSString*)coinString withLevel:(ChunkLevel)chunkLevel {
    // get the y level that the coin group will start at
	int level = [[[ChunkManager sharedSingleton] getCurrentChunk] getLevel:chunkLevel] + 32;
    // convert the string to all lowercase
    coinString = [coinString lowercaseString];
    // get the letter dictionary, which contains coin positions for each character
    NSDictionary *letterDictionary = [NSDictionary dictionaryWithDictionary:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"coinPatterns" ofType:@"plist"]] objectForKey:@"letters"]];
    // keep track of the last x position of each letter
    int lastX = 0;
    // loop through each character in the string
    for(int i=0;i<[coinString length];i++) {
        // get the character at the given index
        NSString *letter = [coinString substringWithRange:NSMakeRange(i, 1)];
        // get the string of coin positions using the letter
        NSString *coinPositionString = [letterDictionary objectForKey:letter];
        // split the string up into coin positions
        NSArray *coinPositions = [coinPositionString componentsSeparatedByString:@"|"];
        // keep track of the maximum x position of the coins in the current letter
        int maxX = 0;
        // loop through coin positions
        for(NSString *s in coinPositions) {
            // get a recycled coin that can be used
            BBCoin *c = [self getRecycledCoin];
            // convert the string to a point for positioning the coin
            CGPoint p = ccpMult(CGPointFromString(s), 32);
            // keep track of the maximum x position for this letter
            maxX = MAX(maxX, p.x);
            // reset coin with new position
            [c resetWithPosition:ccpAdd(p, ccp([Globals sharedSingleton].playerPosition.x + lastX + [ResolutionManager sharedSingleton].size.width * [ResolutionManager sharedSingleton].inversePositionScale, level))];
        }
        if(spacing) {
            // space the letters out by their width and two coin widths
            lastX += (maxX + 64);
        }
        else {
            // space the letters out by their width and one coin width, so that they appear right next to each other
            lastX += (maxX + 32);
        }
    }
}

@end
