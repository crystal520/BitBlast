//
//  BBCoinManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/14/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kEventNewGame object:nil];
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
	// check to see how many active coins are on screen
	int numActiveCoins = 0;
	// update active coins
	for(BBCoin *c in coins) {
		if(!c.recycle) {
			// see if coin has gone off screen
			if(c.dummyPosition.x < [Globals sharedSingleton].playerPosition.x - [Globals sharedSingleton].cameraOffset.x) {
				[c setEnabled:NO];
			}
			else {
				numActiveCoins++;
			}
		}
	}
	// see if a coin group has been collected
	if(checkForCoinGroup && numActiveCoins == 0) {
		checkForCoinGroup = NO;
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventCoinGroupDone object:nil]];
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

- (NSArray*) getRandomCoinGroup {
	// generate random number from array
	int ran = CCRANDOM_MIN_MAX(0, [patterns count]);
	// make sure it exists
	if(ran < [patterns count]) {
		return [patterns objectAtIndex:ran];
	}
	return [patterns objectAtIndex:0];
}

#pragma mark -
#pragma mark notifications
- (void) levelWillLoad {
	for(BBCoin *c in coins) {
		[c setEnabled:NO];
	}
}

- (void) pause {
	for(BBCoin *c in coins) {
		[c pause];
	}
}

- (void) resume {
	for(BBCoin *c in coins) {
		[c resume];
	}
}

#pragma mark -
#pragma mark actions
- (void) spawnCoinGroup {
	// get random level from current chunk
	Chunk *currentChunk = [[ChunkManager sharedSingleton] getCurrentChunk];
	int level = [currentChunk getLevel:[currentChunk getRandomLevel]] + 50;
	// get a random coin group
	NSArray *coinGroup = [self getRandomCoinGroup];
	// loop through and position coins
	for(NSString *s in coinGroup) {
		// get an inactive coin
		BBCoin *c = [self getRecycledCoin];
		// make string into a point
		CGPoint p = CGPointFromString(s);
		// reset coin with new position
		[c resetWithPosition:ccpAdd(p, ccp([Globals sharedSingleton].playerPosition.x + [ResolutionManager sharedSingleton].size.width * [ResolutionManager sharedSingleton].inversePositionScale, level))];
	}
	// start checking for when there are no coin groups
	checkForCoinGroup = YES;
}

@end
