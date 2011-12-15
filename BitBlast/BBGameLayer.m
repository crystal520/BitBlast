//
//  BBGameLayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameLayer.h"

@implementation BBGameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BBGameLayer *layer = [BBGameLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

- (id) init {
	if((self = [super init])) {
		
		// create player and add it to this layer
		player = [[BBPlayer alloc] init];
		[self addChild:player];
		
		// add physics world node to this layer
		[self addChild:[BBPhysicsWorld sharedSingleton]];
		
		// listen for touches
		self.isTouchEnabled = YES;
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
		// load level
		[self addChild:[ChunkManager sharedSingleton]];
		[[ChunkManager sharedSingleton] loadChunksForLevel:@"jungleLevel"];
		
		// update tick
		[self scheduleUpdate];
	}
	
	return self;
}

- (void) update:(float)delta {
	
	[[ChunkManager sharedSingleton] updateWithSpeed:-1];
}

#pragma mark -
#pragma mark touch input
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// get coordinates of touch
	CGPoint touchPoint = [touch locationInView:[touch view]];
	
	// right side of screen is jump
	if(touchPoint.x > winSize.width * 0.5f) {
		[player jump];
	}
	
	return true;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	
}

#pragma mark -

@end
