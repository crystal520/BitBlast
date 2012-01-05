//
//  ParallaxNode.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/4/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "ParallaxNode.h"


@implementation ParallaxNode

@synthesize ratio;

- (id) initWithDictionary:(NSDictionary*)dict {
	
	if((self = [super init])) {
		
		sprites = [NSMutableArray new];
		
		self.position = ccp(0, [[dict objectForKey:@"y"] floatValue]);
		
		// grab ratio from dictionary
		ratio = [[dict objectForKey:@"ratio"] floatValue];
		
		// grab image info from dictionary
		int width = [[dict objectForKey:@"imageWidth"] intValue];
		
		// determine how many images we'll need based on image width and screen size
		int numImages = [CCDirector sharedDirector].winSize.width / width + 1;
		
		// get image to use from array of possible images
		NSArray *possibleImages = [dict objectForKey:@"images"];
		int ranImage = floor(CCRANDOM_0_1() * [possibleImages count]);
		NSString *imageName = [possibleImages objectAtIndex:ranImage];
		
		// create image, add it to this node, save it in the sprite array, and offset it
		for(int i=0;i<numImages;i++) {
			CCSprite *parallaxImage = [CCSprite spriteWithFile:imageName];
			parallaxImage.position = ccp((i + 0.5) * width, 0);
			[self addChild:parallaxImage];
			[sprites addObject:parallaxImage];
			
		}
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
	[self removeAllChildrenWithCleanup:YES];
	[sprites release];
}

- (void) update:(float)changeInPos {
	
	// update all sprite positions based on the changeInPos
	for(CCSprite *s in sprites) {
		s.position = ccp(floor(s.position.x + (changeInPos * ratio)), s.position.y);
		
		// if the sprite is completely offscreen, append it to the back of the sprite chain
		if(s.position.x <= -(s.contentSize.width * 0.5)) {
			s.position = ccp(floor(s.position.x + [sprites count] * s.contentSize.width), s.position.y);
		}
	}
}

@end
