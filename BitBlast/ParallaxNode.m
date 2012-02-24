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
		
		// see if the images need to be seamless
		seamless = [[dict objectForKey:@"seamless"] boolValue];
		if(!seamless) {
			numImages = 1;
		}
		
		// create array for sprite images
		spriteImages = [NSMutableArray new];
		[spriteImages setArray:[dict objectForKey:@"images"]];
		
		// create image, add it to this node, save it in the sprite array, and offset it
		for(int i=0;i<numImages;i++) {
			CCSprite *parallaxImage = [CCSprite spriteWithFile:[self getRandomImage]];
			[parallaxImage.texture setAliasTexParameters];
			parallaxImage.position = ccp((i + 0.5) * parallaxImage.contentSize.width * [ResolutionManager sharedSingleton].positionScale, parallaxImage.contentSize.height * 0.5);
			[self addChild:parallaxImage];
			[sprites addObject:parallaxImage];
		}
		
		// apply y offset to entire node
		self.position = ccp(0, [[dict objectForKey:@"y"] floatValue]);
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
	
	// update first sprite based on the changeInPos
	CCSprite *firstSprite = [sprites objectAtIndex:0];
	firstSprite.position = ccp(firstSprite.position.x + (changeInPos * ratio), firstSprite.position.y);
	// update other sprite positions based on first sprite
	[self updatePositions];
	
	// if the first image is off the screen, reset it to its initial position
	if(firstSprite.position.x <= -([firstSprite displayedFrame].rect.size.width * 0.5)) {
		// swap images so we re-use sprite objects
		[self swapImages];
		// reset first sprite's position
		firstSprite.position = ccp([firstSprite displayedFrame].rect.size.width * 0.5, [firstSprite displayedFrame].rect.size.height * 0.5);
		// update other sprite positions based on first sprite
		[self updatePositions];
		// position the sprite offscreen somewhere if not seamless
		if(!seamless) {
			float min = [ResolutionManager sharedSingleton].size.width + [firstSprite displayedFrame].rect.size.width * 0.5;
			float max = min + [firstSprite displayedFrame].rect.size.width;
			firstSprite.position = ccp(CCRANDOM_MIN_MAX(min, max), firstSprite.position.y);
		}
	}
}

- (void) updatePositions {
	// loop through sprites and set positions
	for(int i=1,j=[sprites count];i<j;i++) {
		CCSprite *sprite = [sprites objectAtIndex:i];
		CCSprite *prevSprite = [sprites objectAtIndex:i-1];
		
		sprite.position = ccp(prevSprite.position.x + ([prevSprite displayedFrame].rect.size.width + [sprite displayedFrame].rect.size.width) * 0.5, [sprite displayedFrame].rect.size.height * 0.5);
	}
}

#pragma mark -
#pragma mark actions
- (void) swapImages {
	// loop through sprites and swap images
	for(int i=1,j=[sprites count];i<j;i++) {
		CCSprite *sprite = [sprites objectAtIndex:i];
		CCSprite *prevSprite = [sprites objectAtIndex:i-1];
		
		[prevSprite setDisplayFrame:[sprite displayedFrame]];
	}
	
	// get last sprite in array and set it to a new image
	CCSprite *lastSprite = [sprites objectAtIndex:[sprites count]-1];
	[lastSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[self getRandomImage]]];
	[lastSprite setTextureRect:CGRectMake(0, 0, lastSprite.texture.contentSize.width, lastSprite.texture.contentSize.height)];
}

@end
