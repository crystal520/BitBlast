//
//  BBPhysicsWorld.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface BBPhysicsWorld : CCNode {
    
	b2World *world;
}

@property (nonatomic) b2World *world;

+ (BBPhysicsWorld*) sharedSingleton;

@end
