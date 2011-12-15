//
//  GFFParallaxNode.m
//
//  Created by Rolando Abarca on 12/14/09.
//

#import "GFFParallaxNode.h"
#import "RepeatableLayer.h"

@implementation GFFParallaxNode
- (id)init {
	if ((self = [super init])) {
		childrenNo = 0;
	}
	return self;
}

- (void)addChild:(RepeatableLayer *)child z:(int)z parallaxRatio:(float)ratio {
	NSAssert(childrenNo < MAX_PARALLAX_CHILDREN, @"Reached max of parallax children!");
	ratios[childrenNo++] = ratio;

	[super addChild:child z:z];
}

- (void)scroll:(float)offset {
	int idx = 0;
	for (RepeatableLayer *child in self.children) {
		[child scroll:offset * ratios[idx++]];
	}
}

- (void)scrollTest {
	[self scroll:0.3f];
}
@end
