//
//  Chunk.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-extensions.h"

typedef enum {
	CHUNK_LEVEL_UNKNOWN = -1,
	CHUNK_LEVEL_TOP = 0,
	CHUNK_LEVEL_MIDDLE = 1,
	CHUNK_LEVEL_BOTTOM = 2,
    CHUNK_LEVEL_COUNT = 3
} ChunkLevel;

@interface Chunk : HKTMXTiledMap {
    
	int width, height, playerZ;
	float endPosition, startPosition, lowestPosition, dummyStartPosition;
	CGPoint dummyPosition;
	CGSize dummySize;
	// set of levels within chunk
	NSMutableArray *levels;
	// types of levels within chunk
	NSMutableArray *levelTypes;
}

@property (nonatomic, assign) CGPoint dummyPosition;
@property (nonatomic, assign) CGSize dummySize;
@property (nonatomic) int width, height, playerZ;
@property (nonatomic) float endPosition, startPosition, lowestPosition, dummyStartPosition;

// setup
- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset;
- (void) generateLevels;
// getters
- (int) getRandomLevel;
- (ChunkLevel) getLevelType:(int)index;
- (int) getLevel:(int)index;
- (BOOL) isLowestLevel:(CGPoint)position;

@end
