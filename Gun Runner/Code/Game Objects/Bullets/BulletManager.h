//
//  BulletManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/5/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBBullet.h"

#define MAX_BULLETS 200

@interface BulletManager : NSObject {
    NSMutableArray *bullets;
	CCNode *node;
}

@property (nonatomic, assign) CCNode *node;

+ (BulletManager*) sharedSingleton;

// update
- (void) update:(float)delta;
// getters
- (BBBullet*) getRecycledBullet;
// setters
- (void) setNode:(CCNode*)newNode;
- (void) setScale:(float)scale;
- (void) setEnabled:(BOOL)newEnabled;
// actions
- (void) pause;
- (void) resume;

@end
