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

#define MAX_BULLETS 500

@interface BulletManager : NSObject {
    NSMutableArray *bullets;
	CCNode *node;
	NSMutableArray *activeBullets;
}

+ (BulletManager*) sharedSingleton;

// update
- (void) update:(float)delta;
- (void) updateActiveBullets;
// getters
- (BBBullet*) getRecycledBullet;
- (NSArray*) getActiveBullets;
// setters
- (void) setNode:(CCNode*)newNode;

@end
