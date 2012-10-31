//
//  BBDropshipManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "BBDropshipManager.h"


@implementation BBDropshipManager

@synthesize dropshipLevel, frontNode, backNode;

+ (BBDropshipManager*) sharedSingleton {
	
	static BBDropshipManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBDropshipManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
        // create nodes
        backNode = [CCNode new];
        frontNode = [CCNode new];
        // explosions!
		explosionManager = [BBExplosionManager new];
		dropships = [NSMutableArray new];
		// create dropships
		for(int i=0;i<MAX_DROPSHIPS;i++) {
			BBDropship *d = [BBDropship new];
            d.explosionManager = explosionManager;
            d.switchNode = backNode;
			[backNode addChild:d];
			[dropships addObject:d];
			[d release];
		}
		[explosionManager setNode:frontNode];
		// load dropship levels
		dropshipLevels = [[NSArray alloc] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dropshipLevels" ofType:@"plist"]] objectForKey:@"levels"]];
		[self setDropshipLevel:0];
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
	[dropshipLevels release];
	[dropships release];
    [frontNode removeFromParentAndCleanup:YES];
    [backNode removeFromParentAndCleanup:YES];
	[super dealloc];
}

#pragma mark -
#pragma mark setters
- (void) setDropshipLevel:(int)newDropshipLevel {
    dropshipLevel = newDropshipLevel;
	if(dropshipLevel >= [dropshipLevels count]) {
		dropshipLevel = [dropshipLevels count]-1;
	}
	// update target dropships
	targetDropships = [[[dropshipLevels objectAtIndex:dropshipLevel] objectForKey:@"maxShipsOnScreen"] intValue];
    // make sure to only spawn 1 dropship if we're in the tutorial
    if([Globals sharedSingleton].tutorial) {
        targetDropships = 1;
    }
}

- (void) setEnabled:(BOOL)newEnabled {
    for(BBDropship *d in dropships) {
        [d setEnabled:newEnabled];
    }
}

#pragma mark -
#pragma mark getters
- (NSArray*) getActiveDropships {
	NSMutableArray *activeDropships = [NSMutableArray array];
	for(BBDropship *d in dropships) {
		if(d.enabled || d.alive) {
			[activeDropships addObject:d];
		}
	}
	return activeDropships;
}

- (BBDropship*) getInactiveDropship {
	for(BBDropship *d in dropships) {
		if(!d.enabled) {
			return d;
		}
	}
	return nil;
}

- (NSString*) getRandomDropshipType {
    // return tutorial ship if player is in tutorial
    if([Globals sharedSingleton].tutorial) {
        return @"tutorialDropship";
    }
    
	NSArray *currentShips = [[dropshipLevels objectAtIndex:dropshipLevel] objectForKey:@"ships"];
	int ran = CCRANDOM_MIN_MAX(0, [currentShips count]);
	if(ran < [currentShips count]) {
		return [currentShips objectAtIndex:ran];
	}
	return [currentShips objectAtIndex:0];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if enabled and not paused
	if(enabled && !paused) {
		for(BBDropship *d in dropships) {
			[d update:delta];
		}
	}
}

#pragma mark -
#pragma mark actions
- (void) spawnDropship {
	// spawn a new dropship if enabled
	if(enabled) {
		BBDropship *newDropship = [self getInactiveDropship];
		int ranLevel;
		ChunkLevel typeLevel;
		
		// generate a random level and make sure it's not on the same level as another ship
		int numChecks = 5;
		while(true) {
            // see if there is an override level to use
            if(overrideLevel != CHUNK_LEVEL_UNKNOWN) {
                ranLevel = overrideLevel;
            }
            else {
                // get a random level for dropship to be on
                ranLevel = [[[ChunkManager sharedSingleton] getCurrentChunk] getRandomLevel];
            }
			typeLevel = [[[ChunkManager sharedSingleton] getCurrentChunk] getLevelType:ranLevel];
			// check other ships
			BOOL breakOut = YES;
			for(BBDropship *d in dropships) {
				if(d.level == typeLevel) {
					breakOut = NO;
				}
			}
			// just in case we get stuck in the loop, which could happen if there's only 1 or 2 levels
			numChecks--;
			if(breakOut || numChecks == 0) {
				break;
			}
		}
        
        // reset overrideLevel
        overrideLevel = CHUNK_LEVEL_UNKNOWN;
		
		if(numChecks > 0) {
			[explosionManager stopExploding:newDropship];
            [newDropship removeFromParentAndCleanup:NO];
            [frontNode addChild:newDropship];
			[newDropship resetWithPosition:ccp([ResolutionManager sharedSingleton].size.width * [ResolutionManager sharedSingleton].inversePositionScale, [[[ChunkManager sharedSingleton] getCurrentChunk] getLevel:ranLevel]) type:[self getRandomDropshipType] level:typeLevel];
		}
	}
}

- (void) tryToSpawnDropship {
	// make sure there are enough active dropships
	int numActiveDropships = 0;
	for(BBDropship *d in dropships) {
		if(d.enabled) {
			numActiveDropships += 1;
		}
	}
    
    // get random number of dropships to spawn
    int numDropshipsToSpawn = CCRANDOM_MIN_MAX(1, targetDropships);
    
	// if there aren't enough active dropships, trigger a new one
	if(numActiveDropships != numDropshipsToSpawn) {
		for(int i=0;i<(numDropshipsToSpawn - numActiveDropships);i++) {
			[self performSelector:@selector(spawnDropship) withObject:nil afterDelay:1 + i];
		}
	}
}

- (void) tryToSpawnDropshipWithOverrideLevel:(ChunkLevel)newOverrideLevel {
    overrideLevel = newOverrideLevel;
    [self tryToSpawnDropship];
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	enabled = NO;
	self.dropshipLevel = 0;
	[self pause];
}

- (void) levelWillLoad {
	enabled = YES;
	// reset dropships
	for(BBDropship *d in dropships) {
		[d setEnabled:NO];
		d.alive = NO;
	}
}

- (void) increaseLevel {
	self.dropshipLevel++;
}

- (void) pause {
    paused = YES;
	for(BBDropship *d in dropships) {
		[d pause];
	}
    [explosionManager pause];
}

- (void) resume {
    // only resume if we're not in the end or intro boss sequence
    if(![Globals sharedSingleton].endBossSequence && ![Globals sharedSingleton].introBossSequence) {
        paused = NO;
        for(BBDropship *d in dropships) {
            [d resume];
        }
        [explosionManager resume];
    }
}

@end
