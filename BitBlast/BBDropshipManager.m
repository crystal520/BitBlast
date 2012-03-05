//
//  BBDropshipManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDropshipManager.h"


@implementation BBDropshipManager

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
		// set to 1 for now. could possibly increase to 2 or 3 for increased difficulty
		targetDropships = 1;
		// not spawning a dropship initially
		spawningDropship = NO;
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelWillLoad) name:kLoadLevelNotification object:nil];
	}
	return self;
}

- (void) dealloc {
	[dropships release];
	[super dealloc];
}

#pragma mark -
#pragma mark getters
- (NSArray*) getActiveDropships {
	NSMutableArray *activeDropships = [NSMutableArray array];
	for(BBDropship *d in dropships) {
		if(d.enabled) {
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

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if enabled
	if(enabled) {
		// make sure there are enough active dropships
		int numActiveDropships = 0;
		for(BBDropship *d in dropships) {
			[d update:delta];
			if(d.enabled) {
				numActiveDropships += 1;
			}
		}
		[self checkCollisions];
		
		// if there aren't enough active dropships, trigger a new one
		if(numActiveDropships != targetDropships && !spawningDropship) {
			spawningDropship = YES;
			[self performSelector:@selector(spawnDropship) withObject:nil afterDelay:1];
		}
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
				[b setEnabled:NO];
			}
		}
	}
}

- (void) spawnDropship {
	// spawn a new dropship if enabled
	if(enabled) {
		BBDropship *newDropship = [self getInactiveDropship];
		[newDropship resetWithPosition:ccp([Globals sharedSingleton].playerPosition.x + [ResolutionManager sharedSingleton].size.width, [[[ChunkManager sharedSingleton] getCurrentChunk] getGroundPositionWithLayer:@"CollisionTop"].y) type:@"testDropship"];
		spawningDropship = NO;
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	enabled = NO;
}

- (void) levelWillLoad {
	enabled = YES;
	// reset dropships
	for(BBDropship *d in dropships) {
		[d setEnabled:NO];
	}
	spawningDropship = NO;
}

@end
