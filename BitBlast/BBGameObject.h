//
//  BBGameObject.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBGameObject : CCNode {
    
	CCSprite *sprite;
	CCSpriteBatchNode *spriteBatch;
	NSDictionary *dictionary;
}

@property (nonatomic, readonly) CCSprite *sprite;

- (id) initWithFile:(NSString*)filename;
- (void) playAnimation:(NSString*)animName;

- (float) lowestPoint;
- (float) highestPoint;

@end
