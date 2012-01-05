//
//  ParallaxNode.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/4/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParallaxNode : CCNode {
    float ratio;
	NSMutableArray *sprites;
}

@property (nonatomic) float ratio;

- (id) initWithDictionary:(NSDictionary*)dict;

- (void) update:(float)changeInPos;

@end
