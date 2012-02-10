//
//  BBEnemy.h
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"

@interface BBEnemy : BBGameObject {
    // damage the enemy can take before it's considered dead
	float health;
}

// update
- (void) update:(float)delta;

@end
