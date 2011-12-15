//
//  BBPhysicsObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface BBPhysicsObject : NSObject {
    
	b2Body *body;
}

@property (nonatomic) b2Body *body;

- (id) initWithBody:(b2Body*)body;

@end
