//
//  EnemyManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBEnemy.h"
#import "ChunkManager.h"
#import "BulletManager.h"

#define MAX_ENEMIES 6

@interface EnemyManager : NSObject {
    NSMutableArray *enemies;
}

+ (EnemyManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// getters
- (BBEnemy*) getRecycledEnemy;
- (NSArray*) getActiveEnemies;
// notifications
- (void) chunkAdded;
- (void) gameOver;

@end
