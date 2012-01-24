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
		
		// grab ratio from dictionary
		ratio = [[dict objectForKey:@"ratio"] floatValue];
		
		// grab image info from dictionary
		int width = [[dict objectForKey:@"imageWidth"] intValue];
		
		// determine how many images we'll need based on image width and screen size
		int numImages = ceil([CCDirector sharedDirector].winSize.width / width) + 1;
		if((int)([ResolutionManager sharedSingleton].size.width) % width > 0) {
			numImages++;
		}
		numImages = MAX(2, numImages);
		
		// get image to use from array of possible images
		NSArray *possibleImages = [dict objectForKey:@"images"];
		int ranImage = floor(CCRANDOM_0_1() * [possibleImages count]);
		NSString *imageName = [possibleImages objectAtIndex:ranImage];
		
		// create image, add it to this node, save it in the sprite array, and offset it
		for(int i=0;i<numImages;i++) {
			CCSprite *parallaxImage = [CCSprite spriteWithFile:imageName];
			[parallaxImage.texture setAliasTexParameters];
			parallaxImage.position = ccp((i + 0.5) * width, 0);
			[self addChild:parallaxImage];
			[sprites addObject:parallaxImage];
		}
		
		// apply y offset
		CCSprite *sprite = [sprites objectAtIndex:0];
		self.position = ccp(0, [[dict objectForKey:@"y"] floatValue] + (0.5 * sprite.contentSize.height));
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
	[self removeAllChildrenWithCleanup:YES];
	[sprites release];
}

- (void) reset {
	// reset the position of each sprite
	for(CCSprite *s in sprites) {
		s.position = ccp(0, s.position.y);
	}
}

- (void) update:(float)changeInPos {
	
	// update all sprite positions based on the changeInPos
	CCSprite *firstSprite = [sprites objectAtIndex:0];
	firstSprite.position = ccp(firstSprite.position.x + (changeInPos * ratio), firstSprite.position.y);
	
	if(firstSprite.position.x <= -(firstSprite.contentSize.width * 0.5)) {
		firstSprite.position = ccp(firstSprite.contentSize.width * 0.5, firstSprite.position.y);
	}
	
	for(int i=1,j=[sprites count];i<j;i++) {
		CCSprite *sprite = [sprites objectAtIndex:i];
		CCSprite *prevSprite = [sprites objectAtIndex:i-1];
		sprite.position = ccp(prevSprite.position.x + sprite.contentSize.width, sprite.position.y);
	}
}

@end
