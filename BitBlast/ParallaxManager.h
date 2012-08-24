//
//  ParallaxManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/4/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ParallaxNode.h"

@interface ParallaxManager : CCNode {
    NSMutableArray *nodes;
}

- (void) loadWithFile:(NSString*)file;
- (void) resetWithFile:(NSString*)file;
- (void) update:(float)changeInPos;

@end
