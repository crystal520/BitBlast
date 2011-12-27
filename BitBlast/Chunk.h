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

@interface Chunk : CCTMXTiledMap {
    
	NSMutableArray *collidables;
	int width, height, playerZ;
	float endPosition, startPosition, lowestPosition;
}

@property (nonatomic) int width, height, playerZ;
@property (nonatomic) float endPosition, startPosition, lowestPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset;
- (void) makeTileAt:(CGPoint)point withLayer:(CCTMXLayer*)layer withOffset:(CGPoint)offset withTag:(int)tag;
- (void) cleanupPhysics;

@end
