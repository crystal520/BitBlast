//
//  ChunkLoader.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ChunkManager.h"

@interface ChunkLoader : CCNode {
    
}

- (void) loadChunksForLevel:(NSString*)levelName;

@end
