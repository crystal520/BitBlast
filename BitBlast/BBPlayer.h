//
//  BBPlayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BBPhysicsWorld.h"

@interface BBPlayer : CCNode {
	
    CCSprite *body;
	b2Body *physicsBody;
}

- (void) jump;

@end
