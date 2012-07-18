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
    BBGameObject *explodingObject;
    // whether or not the explosion is enabled
    BOOL enabled;
}

@property (nonatomic, assign) BBGameObject *explodingObject;

// actions
- (void) explode;
// setters
- (void) setEnabled:(BOOL)newEnabled;

@end
