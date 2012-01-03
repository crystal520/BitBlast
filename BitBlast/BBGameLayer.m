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
		
		[self loadCameraVariables];
		
		// for objects that need to scroll
		scrollingNode = [[CCNode alloc] init];
		scrollingNode.scale = 1;
		[self addChild:scrollingNode];
		
		// for the HUD
		hud = [[BBHud alloc] init];
		[self addChild:hud];
		
		// listen for touches
		self.isTouchEnabled = YES;
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
		// load level
		[scrollingNode addChild:[ChunkManager sharedSingleton]];
		[[ChunkManager sharedSingleton] loadChunksForLevel:@"jungleLevel"];
		
		// create player and add it to this layer
		player = [[BBPlayer alloc] init];
		
		// update tick
		[self scheduleUpdate];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	[scrollingNode release];
	[hud release];
	[player release];
}

#pragma mark -
#pragma mark setup
- (void) loadCameraVariables {
	
	// get dictionary from plist
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cameraProperties" ofType:@"plist"]];
	
	cameraOffset = ccp([[plist objectForKey:@"offsetX"] floatValue], [[plist objectForKey:@"offsetY"] floatValue]);
	cameraBounds = ccp([[plist objectForKey:@"minimumY"] floatValue], [[plist objectForKey:@"maximumY"] floatValue]);
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	[[ChunkManager sharedSingleton] update:delta];
	[player update:delta];
	[self updateCamera];
	[hud update:delta];
}

- (void) updateCamera {
	
	// convert player's y position to screen space
	CGPoint currentPlayerScreenPosition = [player convertToWorldSpace:CGPointZero];
	currentPlayerScreenPosition.y = [CCDirector sharedDirector].winSize.height - (currentPlayerScreenPosition.y + player.sprite.contentSize.height);
	
	float yOffset = 0;
	// check to see if player is too close to the top of the screen
	if(currentPlayerScreenPosition.y < cameraBounds.x) {
		yOffset = cameraBounds.x - currentPlayerScreenPosition.y;
	}
	// check to see if player is too close to the bottom of the screen
	else if(currentPlayerScreenPosition.y > cameraBounds.y) {
		yOffset = cameraBounds.y - currentPlayerScreenPosition.y;
	}
	
	CGPoint newPos = ccp(-1 * player.position.x + cameraOffset.x, scrollingNode.position.y + cameraOffset.y - yOffset);
    
    // make sure newPos's y coordinate is not less than the current chunk's lowest point
    if(newPos.y > [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
		newPos.y = [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition;
	}
	[scrollingNode setPosition:newPos];
}

- (void) draw {
	
	[super draw];
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
	
	//CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// get coordinates of touch
	//CGPoint touchPoint = [touch locationInView:[touch view]];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// get coordinates of touch
	CGPoint touchPoint = [touch locationInView:[touch view]];
	
	// right side of screen is jump
	if(touchPoint.x > winSize.width * 0.5f) {
		[player endJump];
	}
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	
}

#pragma mark -

@end
