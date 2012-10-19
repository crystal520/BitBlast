//
//  ParallaxNode.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/4/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBParallaxSprite.h"

@interface ParallaxNode : CCNode {
	// speed at which node moves
    CGPoint ratio;
	// sprites that scroll sideways with the node
	NSMutableArray *sprites;
	// possible images that the sprites can use
	NSMutableArray *spriteImages;
	// whether the images come one right after the other
	BOOL seamless;
    // width of the sprites in this parallax node
    int spriteWidth;
}

@property (nonatomic) CGPoint ratio;

- (id) initWithDictionary:(NSDictionary*)dict;
// setup
- (void) reset;
// getters
- (NSString*) getRandomImage;
- (int) getSpriteWidth;
// update
- (void) update:(CGPoint)changeInPos;

@end
