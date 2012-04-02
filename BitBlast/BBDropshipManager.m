//
//  BBDropshipManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDropshipManager.h"


@implementation BBDropshipManager

@synthesize dropshipLevel;

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
		dropships = [NSMutableArray new];
		// create dropships
		for(int i=0;i<MAX_DROPSHIPS;i++) {
			BBDropship *d = [BBDropship new];
			[self addChild:d];
			[dropships addObject:d];
			[d release];
		}
		// load dropship levels
		dropshipLevels = [[NSArray alloc] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dropshipLevels" ofType:@"plist"]] objectForKey:@"levels"]];
		[self setDropshipLevel:0];
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseLevel) name:kPlayerLevelIncreaseNotification object:nil];
		// explosions!
		explosionManager = [BBExplosionManager new];
		[explosionManager setNode:self];
	}
	return self;
}

- (void) dealloc {
	[dropshipLevels release];
	[dropships release];
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
}

#pragma mark -
#pragma mark getters
- (NSArray*) getActiveDropships {
	NSMutableArray *activeDropships = [NSMutableArray array];
	for(BBDropship *d in dropships) {
		if(d.enabled && d.alive) {
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
	// only update if enabled
	if(enabled) {
		for(BBDropship *d in dropships) {
			[d update:delta];
		}
		[self checkCollisions];
	}
}

#pragma mark -
#pragma mark actions
- (void) checkCollisions {
	NSArray *activeDropships = [self getActiveDropships];
	NSArray *activeBullets = [[BulletManager sharedSingleton] getActiveBullets];
	// then loop through the active enemies
	for(BBDropship *d in activeDropships) {
		// loop through active bullets
		for(BBBullet *b in activeBullets) {
			// check for collision
			if(b.enabled && d.enabled && [d getCollidesWith:b]) {
				[d hitByBullet:b];
				if(!d.alive) {
					[explosionManager explodeInObject:d number:5];
				}
				[b setEnabled:NO];
			}
		}
	}
}

- (void) spawnDropship {
	// spawn a new dropship if enabled
	if(enabled) {
		BBDropship *newDropship = [self getInactiveDropship];
		int ranLevel;
		ChunkLevel typeLevel;
		
		// generate a random level and make sure it's not on the same level as another ship
		int numChecks = 5;
		while(true) {
			// get a random level for dropship to be on
			ranLevel = [[[ChunkManager sharedSingleton] getCurrentChunk] getRandomLevel];
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
		
		if(numChecks > 0) {
			[explosionManager stopExploding:newDropship];
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
	
	// if there aren't enough active dropships, trigger a new one
	if(numActiveDropships != targetDropships) {
		for(int i=0;i<(targetDropships - numActiveDropships);i++) {
			[self performSelector:@selector(spawnDropship) withObject:nil afterDelay:1 + i];
		}
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	enabled = NO;
	self.dropshipLevel = 0;
}

- (void) levelWillLoad {
	enabled = YES;
	// reset dropships
	for(BBDropship *d in dropships) {
		[d setEnabled:NO];
	}
}

- (void) increaseLevel {
	self.dropshipLevel++;
}

@end
