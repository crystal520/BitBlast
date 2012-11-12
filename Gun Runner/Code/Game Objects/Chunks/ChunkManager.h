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
	// which array within the chunks array in the level plist is currently being used
	int curSpeedLevel;
    // number of chunks added within the current tutorial state
    int chunkCount;
    // last group of chunks the last chunk was taken from. to avoid repeats
    int lastChunkGroup;
}

@property (nonatomic, readonly) NSMutableArray *currentChunks;
@property (nonatomic, assign) int curSpeedLevel, chunkCount;

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
- (void) replaceChunksWithLevel:(NSString*)levelName;

@end
