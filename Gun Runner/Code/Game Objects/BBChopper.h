//
//  BBChopper.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBMovingObject.h"

@interface BBChopper : BBMovingObject {
	CCNode *offsetNode;
}

- (CGPoint) getOffset;

@end