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

#define MAX_BULLETS 100

@interface BulletManager : NSObject {
    NSMutableArray *bullets;
	CCNode *node;
	NSMutableArray *activeBullets;
}

@property (nonatomic, assign) CCNode *node;

+ (BulletManager*) sharedSingleton;

// update
- (void) update:(float)delta;
- (void) updateActiveBullets;
// getters
- (BBBullet*) getRecycledBullet;
- (NSArray*) getActiveBullets;
// setters
- (void) setNode:(CCNode*)newNode;
- (void) setScale:(float)scale;
// actions
- (void) pause;
- (void) resume;

@end
