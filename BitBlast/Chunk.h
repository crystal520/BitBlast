//
//  Chunk.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Chunk : CCTMXTiledMap {
    
	int width, height, playerZ;
	float endPosition, startPosition, lowestPosition, dummyStartPosition;
	CGPoint dummyPosition;
	CGSize dummySize;
}

@property (nonatomic, assign) CGPoint dummyPosition;
@property (nonatomic, assign) CGSize dummySize;
@property (nonatomic) int width, height, playerZ;
@property (nonatomic) float endPosition, startPosition, lowestPosition, dummyStartPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset;
// getters
- (CGPoint) getGroundPositionWithLayer:(NSString*)layerName;

@end
