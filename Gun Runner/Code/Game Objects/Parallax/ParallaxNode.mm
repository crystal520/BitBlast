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
		ratio = CGPointFromString([dict objectForKey:@"ratio"]);
		
		// grab image info from dictionary
		spriteWidth = [[dict objectForKey:@"imageWidth"] intValue];
		
		// determine how many images we'll need based on image width and screen size
		int numImages = floor([CCDirector sharedDirector].winSize.width / spriteWidth) + 1;
		if((int)([ResolutionManager sharedSingleton].size.width) % spriteWidth > 0) {
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
			BBParallaxSprite *parallaxImage = [BBParallaxSprite spriteWithFile:[self getRandomImage]];
            parallaxImage.scale = 4;
			ccTexParams params = {GL_NEAREST,GL_NEAREST,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE};
            [parallaxImage.texture setTexParameters:&params];
            parallaxImage.anchorPoint = ccp(0, 0);
			parallaxImage.dummyPosition = ccp(i * spriteWidth, 0);
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
	for(BBParallaxSprite *s in sprites) {
		s.dummyPosition = ccp(0, s.dummyPosition.y);
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

- (int) getSpriteWidth {
    return [sprites count] * spriteWidth;
}

#pragma mark -
#pragma mark update
- (void) update:(CGPoint)changeInPos {
    
    // update all sprites with change in position
    for(BBParallaxSprite *s in sprites) {
        // update the sprite's position using ratio
        s.dummyPosition = ccpAdd(s.dummyPosition, ccp(changeInPos.x * ratio.x, changeInPos.y * ratio.y));
        // see if the sprite is no longer visible on screen
        if(s.dummyPosition.x <= -spriteWidth) {
            // use a new image for this sprite
            [s setTexture:[[CCTextureCache sharedTextureCache] addImage:[self getRandomImage]]];
            [s setTextureRect:CGRectMake(0, 0, s.texture.contentSize.width, s.texture.contentSize.height)];
            ccTexParams params = {GL_NEAREST,GL_NEAREST,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE};
            [s.texture setTexParameters:&params];
            // see if this sprite should be seamless
            if(seamless) {
                // get the offset to apply to this sprite
                s.dummyPosition = ccpAdd(s.dummyPosition, ccp([self getSpriteWidth], 0));
            }
            else {
                // otherwise generate a random x position for it
                s.dummyPosition = ccpAdd(s.dummyPosition, ccp([self getSpriteWidth] + CCRANDOM_MIN_MAX([ResolutionManager sharedSingleton].size.width, [ResolutionManager sharedSingleton].size.width * 2), 0));
            }
        }
        s.position = ccpMult(s.dummyPosition, [ResolutionManager sharedSingleton].positionScale);
    }
}

@end
