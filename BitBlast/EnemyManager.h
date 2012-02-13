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

#define MAX_ENEMIES 20

@interface EnemyManager : NSObject {
    NSMutableArray *currentEnemies;
}

+ (EnemyManager*) sharedSingleton;
// actions
- (void) resetEnemyWithPosition:(CGPoint)newPosition withType:(NSString*)enemyType;

@end
