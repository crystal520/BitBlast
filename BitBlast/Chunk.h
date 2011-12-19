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
	int width, height;
	float endPosition, startPosition;
}

@property (nonatomic) int width, height;
@property (nonatomic) float endPosition, startPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset;
- (void) cleanupPhysics;

@end
