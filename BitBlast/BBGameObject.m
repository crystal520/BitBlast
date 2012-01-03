//
//  BBGameObject.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/13/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameObject.h"


@implementation BBGameObject

@synthesize sprite;

- (id) initWithFile:(NSString *)filename {
	
	if((self = [super init])) {
		
		// save dictionary for future use
		dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
		gravity = [[dictionary objectForKey:@"gravity"] floatValue];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	
	[dictionary release];
}

- (void) playAnimation:(NSString*)animName {
	
	// get animation dictionary
	NSDictionary *animDict = [[dictionary objectForKey:@"animations"] objectForKey:animName];
	
	// make sure it exists
	if(!animDict) {
		NSLog(@"ERROR: Failed to play animation \"%@\" because it doesn't exist", animName);
		return;
	}
	
	// load plist file with information about spritesheet
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[animDict objectForKey:@"plist"]];
	
	// load image file
	CCSpriteBatchNode *spritesheet = [CCSpriteBatchNode batchNodeWithFile:[animDict objectForKey:@"image"]];
	[self addChild:spritesheet];
	
	// get the frames
	NSMutableArray *frames = [NSMutableArray array];
	for(int i=0,j=[[animDict objectForKey:@"frames"] count];i<j;i++) {
		[frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[animDict objectForKey:@"frames"] objectAtIndex:i]]];
	}
	
	// create sprite with first frame
	sprite = [CCSprite spriteWithSpriteFrameName:[[animDict objectForKey:@"frames"] objectAtIndex:0]];
	
	// create the animation object
	CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:[[animDict objectForKey:@"speed"] floatValue]];
	
	// run it
	CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
	[sprite runAction:action];
	[spritesheet addChild:sprite];
}

#pragma mark -
#pragma mark convenience functions
- (float) lowestPoint {
	return self.position.y - self.contentSize.height * 0.5;
}

- (float) highestPoint {
	return self.position.y + self.contentSize.height * 0.5;
}

@end
