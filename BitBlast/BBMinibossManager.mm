//
//  BBMinibossManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 7/18/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMinibossManager.h"

@implementation BBMinibossManager

@synthesize frontNode, backNode, minibossLevel;

+ (BBMinibossManager*) sharedSingleton {
    
    static BBMinibossManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBMinibossManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
    if((self = [super init])) {
        // create nodes for minibosses
        frontNode = [CCNode new];
        backNode = [CCNode new];
        // explosions!
		explosionManager = [BBExplosionManager new];
        // make array of minibosses
        minibosses = [NSMutableArray new];
        for(int i=0;i<MAX_MINIBOSSES;i++) {
            BBMiniboss *miniboss = [[BBMiniboss alloc] init];
            miniboss.explosionManager = explosionManager;
            miniboss.switchNode = backNode;
            [backNode addChild:miniboss];
            [minibosses addObject:miniboss];
            [miniboss release];
        }
        [explosionManager setNode:frontNode];
        
        // load miniboss levels
		minibossLevels = [[NSArray alloc] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"minibossLevels" ofType:@"plist"]] objectForKey:@"levels"]];
		self.minibossLevel = 0;
        
        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseLevel) name:kPlayerLevelIncreaseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kEventNewGame object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [explosionManager release];
    [minibossLevels release];
    [minibosses release];
    [frontNode release];
    [backNode release];
    [super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    // only update if not paused
    if(!paused) {
        // update all minibosses
        for(BBMiniboss *b in minibosses) {
            [b update:delta];
        }
    }
}

#pragma mark -
#pragma mark notifications
- (void) pause {
    paused = YES;
    // pause all minibosses
    for(BBMiniboss *b in minibosses) {
        [b pause];
    }
    [explosionManager pause];
}

- (void) resume {
    // only resume if we're not in the end or intro boss sequence
    if(![Globals sharedSingleton].endBossSequence && ![Globals sharedSingleton].introBossSequence) {
        paused = NO;
        // resume all minibosses
        for(BBMiniboss *b in minibosses) {
            [b resume];
        }
        [explosionManager resume];
    }
}

- (void) increaseLevel {
    self.minibossLevel++;
}

- (void) gameOver {
	enabled = NO;
	self.minibossLevel = 0;
	[self pause];
}

- (void) levelWillLoad {
	enabled = YES;
	// reset dropships
	for(BBMiniboss *b in minibosses) {
		[b setEnabled:NO];
		b.alive = NO;
	}
}

#pragma mark -
#pragma mark getters
- (NSString*) getRandomMinibossType {
    NSArray *currentMinibosses = [[minibossLevels objectAtIndex:minibossLevel] objectForKey:@"minibosses"];
	int ran = CCRANDOM_MIN_MAX(0, [currentMinibosses count]);
	if(ran < [currentMinibosses count]) {
		return [currentMinibosses objectAtIndex:ran];
	}
	return [currentMinibosses objectAtIndex:0];
}

- (BBMiniboss*) getInactiveMiniboss {
    for(BBMiniboss *b in minibosses) {
        if(!b.enabled) {
            return b;
        }
    }
    return nil;
}

- (NSArray*) getActiveMinibosses {
	NSMutableArray *activeMinibosses = [NSMutableArray array];
	for(BBMiniboss *b in minibosses) {
		if(b.enabled && b.alive) {
			[activeMinibosses addObject:b];
		}
	}
	return activeMinibosses;
}

#pragma mark -
#pragma mark setters
- (void) setMinibossLevel:(int)newMinibossLevel {
    minibossLevel = newMinibossLevel;
	if(minibossLevel >= [minibossLevels count]) {
		minibossLevel = [minibossLevels count]-1;
	}
	// update target minibosses
	targetMinibosses = [[[minibossLevels objectAtIndex:minibossLevel] objectForKey:@"maxMinibossesOnScreen"] intValue];
}

- (void) setEnabled:(BOOL)newEnabled {
    for(BBMiniboss *b in minibosses) {
        [b setEnabled:newEnabled];
    }
}

#pragma mark -
#pragma mark actions
- (void) tryToSpawnMiniboss {
    // make sure there are enough active minibosses
	int numActiveMinibosses = 0;
	for(BBMiniboss *b in minibosses) {
		if(b.enabled) {
			numActiveMinibosses += 1;
		}
	}
    
    // get random number of minibosses to spawn
    int numMinibossesToSpawn = CCRANDOM_MIN_MAX(1, targetMinibosses);
	
	// if there aren't enough active dropships, trigger a new one
	if(numActiveMinibosses != numMinibossesToSpawn) {
		for(int i=0;i<(numMinibossesToSpawn - numActiveMinibosses);i++) {
			[self performSelector:@selector(spawnMiniboss) withObject:nil afterDelay:1 + i];
		}
	}
}

- (void) spawnMiniboss {
    // spawn a new miniboss if enabled
	if(enabled) {
		BBMiniboss *newMiniboss = [self getInactiveMiniboss];
		int ranLevel = [[[ChunkManager sharedSingleton] getCurrentChunk] getRandomLevel];
		ChunkLevel typeLevel = [[[ChunkManager sharedSingleton] getCurrentChunk] getLevelType:ranLevel];
		
        [explosionManager stopExploding:newMiniboss];
        [newMiniboss removeFromParentAndCleanup:NO];
        [frontNode addChild:newMiniboss];
        [newMiniboss resetWithPosition:ccp([ResolutionManager sharedSingleton].size.width * [ResolutionManager sharedSingleton].inversePositionScale, [[[ChunkManager sharedSingleton] getCurrentChunk] getLevel:ranLevel]) type:[self getRandomMinibossType] level:typeLevel];
	}
}

@end
