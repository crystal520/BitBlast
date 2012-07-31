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
		for(int i=0;i<MAX_BULLETS;i++) {
			BBBullet *bullet = [BBBullet new];
			[bullets addObject:bullet];
			[bullet release];
		}
		
		// register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kGameRestartNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:kNavGameNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
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

#pragma mark -
#pragma mark setters
- (void) setNode:(CCNode*)newNode {
	node = newNode;
	for(BBBullet *b in bullets) {
		[b.parent removeChild:b cleanup:YES];
		[node addChild:b z:DEPTH_GAME_BULLETS];
	}
}

- (void) setScale:(float)scale {
	for(BBBullet *b in bullets) {
		b.resetScale = scale;
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	// loop through bullets and stop all actions
	for(BBBullet *b in bullets) {
		if(!b.recycle) {
			[b stopAllActions];
		}
	}
}

- (void) newGame {
	// loop through bullets and kill them all
	for(BBBullet *b in bullets) {
		[b setEnabled:NO];
	}
}

#pragma mark -
#pragma mark actions
- (void) pause {
    for(BBBullet *b in bullets) {
        [b pauseSchedulerAndActions];
    }
}

- (void) resume {
    for(BBBullet *b in bullets) {
        [b resumeSchedulerAndActions];
    }
}

@end
