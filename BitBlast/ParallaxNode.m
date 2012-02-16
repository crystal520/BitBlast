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
		
		// create array for sprite images
		spriteImages = [NSMutableArray new];
		[spriteImages setArray:[dict objectForKey:@"images"]];
		
		// create image, add it to this node, save it in the sprite array, and offset it
		for(int i=0;i<numImages;i++) {
			CCSprite *parallaxImage = [CCSprite spriteWithFile:[self getRandomImage]];
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
	[self removeAllChildrenWithCleanup:YES];
	[spriteImages release];
	[sprites release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) reset {
	// reset the position of each sprite
	for(CCSprite *s in sprites) {
		s.position = ccp(0, s.position.y);
	}
}

#pragma mark -
#pragma mark getters
- (NSString*) getRandomImage {
	while(true) {
		int ran = CCRANDOM_MIN_MAX(0, [spriteImages count]);
		if(ran < [spriteImages count]) {
			return [spriteImages objectAtIndex:ran];
		}
	}
}

#pragma mark -
#pragma mark update
- (void) update:(float)changeInPos {
	
	// update all sprite positions based on the changeInPos
	CCSprite *firstSprite = [sprites objectAtIndex:0];
	firstSprite.position = ccp(firstSprite.position.x + (changeInPos * ratio), firstSprite.position.y);
	
	// flag for whether first image went off screen. determines whether sprites need their images changed
	BOOL swapImages = NO;
	
	// if the first image is off the screen, reset it to its initial position
	if(firstSprite.position.x <= -(firstSprite.contentSize.width * 0.5)) {
		swapImages = YES;
		firstSprite.position = ccp(firstSprite.contentSize.width * 0.5, firstSprite.position.y);
	}
	
	// move other sprites based on the end of the first image
	for(int i=1,j=[sprites count];i<j;i++) {
		CCSprite *sprite = [sprites objectAtIndex:i];
		CCSprite *prevSprite = [sprites objectAtIndex:i-1];
		sprite.position = ccp(prevSprite.position.x + sprite.contentSize.width, sprite.position.y);
		
		if(swapImages) {
			[prevSprite setTexture:[sprite displayedFrame].texture];
			// make a new image if it's the last sprite
			if(i == [sprites count]-1) {
				[sprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[self getRandomImage]]];
			}
		}
	}
}

@end
