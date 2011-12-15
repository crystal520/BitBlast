//
//  Chunk.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GFFParallaxNode.h"

@interface Chunk : CCNode {
    
	GFFParallaxNode *backgroundNode;
	GFFParallaxNode *foregroundNode;
	GFFParallaxNode *collisionNode;
}

- (id) initWithFile:(NSString*)chunkName;

@end
