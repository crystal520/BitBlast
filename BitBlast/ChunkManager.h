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
    
	NSMutableArray *chunks;
}

+ (ChunkManager*) sharedSingleton;
- (void) updateWithSpeed:(float)speed;
- (void) addChunk:(NSString*)chunkName;
- (void) loadChunksForLevel:(NSString*)levelName;

@end
