//
//  BBGameObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BBPhysicsWorld.h"

@interface BBGameObject : CCNode {
    
	b2Body *body;
	CCSprite *sprite;
	NSDictionary *dictionary;
}

- (id) initWithFile:(NSString*)filename;
- (void) setupPhysics;
- (void) playAnimation:(NSString*)animName;

@end
