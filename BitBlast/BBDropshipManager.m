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
			[d loadFromFile:@"testDropship"];
			[self addChild:d];
			[dropships addObject:d];
			[d release];
		}
	}
	return self;
}

- (void) dealloc {
	[dropships release];
	[super dealloc];
}

#pragma mark -
#pragma mark setters
- (void) setVelocity:(float)velocity {
	for(BBDropship *d in dropships) {
		[d setVelocity:velocity];
	}
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

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	for(BBDropship *d in dropships) {
		[d update:delta];
	}
	[self checkCollisions];
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

@end
