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
    
	CCTMXTiledMap *map;
	NSMutableArray *collidables;
	int width, height, playerZ;
	float endPosition, startPosition, lowestPosition;
}

@property (nonatomic, assign) CCTMXTiledMap *map;
@property (nonatomic) int width, height, playerZ;
@property (nonatomic) float endPosition, startPosition, lowestPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset;
- (void) cleanupPhysics;

@end
