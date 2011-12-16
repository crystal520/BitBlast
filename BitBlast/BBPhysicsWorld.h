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
#import "GLES-Render.h"
#import "BBPhysicsObject.h"

@interface BBPhysicsWorld : CCNode {
    
	b2World *world;
	GLESDebugDraw *debugDraw;
}

@property (nonatomic) b2World *world;

+ (BBPhysicsWorld*) sharedSingleton;
- (BBPhysicsObject*) createBoxFromFile:(NSString*)fileName withPosition:(CGPoint)pos withData:(id)data;
- (void) debugPhysics;

@end
