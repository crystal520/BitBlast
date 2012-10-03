//
//  BBExplosion.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/25/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"

@interface BBExplosion : BBGameObject {
    // an object whose position and size is used in calculating where an explosion can go off
    BBGameObject *explodingObject;
    // offset applied to explodingObject's position and size
    CGRect offset;
    // whether or not the explosion is enabled
    BOOL enabled;
    // the offset in position of the explosion from the exploding object
    CGPoint finalOffset;
    // whether or not the explosion should follow the exploding object
    BOOL followObject;
}

@property (nonatomic, assign) BBGameObject *explodingObject;
@property (nonatomic, assign) CGRect offset;

// actions
- (void) explode;
// update
- (void) update:(float)delta;
// setters
- (void) setEnabled:(BOOL)newEnabled;

@end
