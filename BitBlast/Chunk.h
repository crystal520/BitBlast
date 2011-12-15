//
//  Chunk.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBPhysicsWorld.h"

@interface Chunk : CCNode {
    
	NSMutableArray *collidables;
}

- (id) initWithFile:(NSString*)chunkName;
- (void) scrollWithSpeed:(float)speed;

@end
