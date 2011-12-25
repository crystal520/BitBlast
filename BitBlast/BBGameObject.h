//
//  BBGameObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBPhysicsWorld.h"
#import "BBPhysicsObject.h"

@interface BBGameObject : CCNode {
    
	BBPhysicsObject *body;
	CCSprite *sprite;
	NSDictionary *dictionary;
}

@property (nonatomic, assign) BBPhysicsObject *body;
@property (nonatomic, readonly) CCSprite *sprite;

- (id) initWithFile:(NSString*)filename;
- (void) playAnimation:(NSString*)animName;

@end
