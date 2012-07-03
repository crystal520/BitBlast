//
//  Chunk.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
	CHUNK_LEVEL_UNKNOWN,
	CHUNK_LEVEL_TOP,
	CHUNK_LEVEL_MIDDLE,
	CHUNK_LEVEL_BOTTOM
} ChunkLevel;

@interface Chunk : CCTMXTiledMap {
    
	int width, height, playerZ;
	float endPosition, startPosition, lowestPosition, dummyStartPosition;
	CGPoint dummyPosition;
	CGSize dummySize;
	// set of levels within chunk
	NSMutableSet *levels;
	// types of levels within chunk
	NSMutableSet *levelTypes;
}

@property (nonatomic, assign) CGPoint dummyPosition;
@property (nonatomic, assign) CGSize dummySize;
@property (nonatomic) int width, height, playerZ;
@property (nonatomic) float endPosition, startPosition, lowestPosition, dummyStartPosition;

// setup
- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset;
- (void) generateLevels;
// getters
- (CGPoint) getGroundPositionWithLayer:(NSString*)layerName;
- (int) getRandomLevel;
- (ChunkLevel) getLevelType:(int)index;
- (int) getLevel:(int)index;
- (BOOL) isPlatformBelowPosition:(CGPoint)position;

@end
