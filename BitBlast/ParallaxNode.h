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
	// speed at which node moves
    CGPoint ratio;
	// sprites that scroll sideways with the node
	NSMutableArray *sprites;
	// possible images that the sprites can use
	NSMutableArray *spriteImages;
	// whether the images come one right after the other
	BOOL seamless;
}

@property (nonatomic) CGPoint ratio;

- (id) initWithDictionary:(NSDictionary*)dict;
// setup
- (void) reset;
// getters
- (NSString*) getRandomImage;
// update
- (void) update:(CGPoint)changeInPos;
- (void) updatePositions;
// actions
- (void) swapImages;

@end
