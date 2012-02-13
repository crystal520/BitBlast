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

@interface ChunkManager : CCNode {
    
	NSMutableArray *currentChunks;
	NSMutableArray *chunks;
	NSMutableString *overrideChunk;
}

@property (nonatomic, readonly) NSMutableArray *currentChunks;

+ (ChunkManager*) sharedSingleton;
// update
- (void) update:(float)delta;
// actions
- (void) resetWithLevel:(NSString*)level;
- (void) addChunk:(NSString*)chunkName;
- (void) addChunk:(NSString *)chunkName withOffset:(CGPoint)offset;
- (void) addRandomChunk;
- (void) removeChunk;
- (void) removeChunks;
// getters
- (Chunk*) getCurrentChunk;
- (Chunk*) getChunkAtIndex:(int)index;
- (Chunk*) getLastChunk;
// setup
- (void) loadChunksForLevel:(NSString*)levelName;

@end
