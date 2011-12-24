//
//  ChunkManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Chunk.h"

#define kChunkCompletedNotification @"chunkCompletedNotification"

@interface ChunkManager : CCNode {
    
	NSMutableArray *currentChunks;
	NSMutableArray *chunks;
}

+ (ChunkManager*) sharedSingleton;

- (void) update:(float)delta;

- (void) addChunk:(NSString*)chunkName;
- (void) addChunk:(NSString *)chunkName withOffset:(CGPoint)offset;
- (void) addRandomChunk;
- (void) removeChunk;

- (Chunk*) getCurrentChunk;

- (void) loadChunksForLevel:(NSString*)levelName;

@end
