//
//  BulletManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/5/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BulletManager.h"


@implementation BulletManager

@synthesize node;

+ (BulletManager*) sharedSingleton {
	
	static BulletManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BulletManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	
	if((self = [super init])) {
		
		bullets = [NSMutableArray new];
		activeBullets = [NSMutableArray new];
		for(int i=0;i<MAX_BULLETS;i++) {
			BBBullet *bullet = [BBBullet new];
			[bullets addObject:bullet];
			[bullet release];
		}
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kGameRestartNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
	[activeBullets release];
	[bullets release];
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// loop through bullets and update
	for(BBBullet *b in bullets) {
		[b update:delta];
	}
}

- (void) updateActiveBullets {
	[activeBullets setArray:[self getActiveBullets]];
}

#pragma mark -
#pragma mark getters
- (BBBullet*) getRecycledBullet {
	for(BBBullet *b in bullets) {
		if(b.recycle == YES) {
			return b;
		}
	}
	return nil;
}

- (NSArray*) getActiveBullets {
	NSMutableArray *newActiveBullets = [NSMutableArray array];
	for(BBBullet *b in bullets) {
		if(!b.recycle) {
			[newActiveBullets addObject:b];
		}
	}
	return newActiveBullets;
}

#pragma mark -
#pragma mark setters
- (void) setNode:(CCNode*)newNode {
	if(node != newNode) {
		node = newNode;
		
		for(BBBullet *b in bullets) {
			[node addChild:b];
		}
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	// loop through bullets and stop all actions
	for(BBBullet *b in bullets) {
		if(!b.recycle) {
			[b.sprite stopAllActions];
		}
	}
}

- (void) newGame {
	// loop through bullets and kill them all
	for(BBBullet *b in bullets) {
		[b setEnabled:NO];
	}
}

@end
