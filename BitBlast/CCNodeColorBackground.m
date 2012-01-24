//
//  CCNodeColorBackground.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/14/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "CCNodeColorBackground.h"


@implementation CCNodeColorBackground

- (id) initWithColor:(ccColor3B)color withAlpha:(float)alpha {
	
	if((self = [super init])) {
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create faded background
		CCSprite *background = [CCSprite spriteWithFile:@"white.png" rect:CGRectMake(0, 0, winSize.width, winSize.height)];
		background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		background.color = color;
		background.opacity = alpha * 255;
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[background.texture setTexParameters:&params];
		[self addChild:background];
	}
	
	return self;
}

@end
