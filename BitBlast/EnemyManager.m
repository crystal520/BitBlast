//
//  EnemyManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "EnemyManager.h"


@implementation EnemyManager

+ (EnemyManager*) sharedSingleton {
	
	static EnemyManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[EnemyManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

#pragma mark -
#pragma mark initializers
- (id) init {
	if((self = [super init])) {
		currentEnemies = [NSMutableArray new];
		for(int i=0;i<MAX_ENEMIES;i++) {
			BBEnemy *enemy = [[BBEnemy alloc] init];
			[currentEnemies addObject:enemy];
			[enemy release];
		}
	}
	return self;
}

- (void) dealloc {
	[currentEnemies release];
	[super dealloc];
}

#pragma mark -
#pragma mark getters
- (BBEnemy*) getRecycledEnemy {
	for(BBEnemy *e in currentEnemies) {
		if(e.recycle) {
			return e;
		}
	}
}

#pragma mark -
#pragma mark actions
- (void) resetEnemyWithPosition:(CGPoint)newPosition withType:(NSString *)enemyType {
	BBEnemy *enemy = [self getRecycledEnemy];
	enemy.position = newPosition;
	//enemy
}

@end
