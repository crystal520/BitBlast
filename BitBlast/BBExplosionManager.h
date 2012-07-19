//
//  BBExplosionManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/25/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBExplosion.h"

#define MAX_NUM_EXPLOSIONS 10

@interface BBExplosionManager : NSObject {
    // array of explosion objects
	NSMutableArray *explosions;
	// node that contains explosions
	CCNode *node;
    BOOL paused;
}

// setters
- (void) setNode:(CCNode*)newNode;
// actions
- (void) explodeInObject:(BBGameObject*)object number:(int)count;
- (void) stopExploding:(BBGameObject*)object;
- (void) pause;
- (void) resume;

@end
