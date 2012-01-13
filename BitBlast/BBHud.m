//
//  BBHud.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBHud.h"


@implementation BBHud

- (id) init {
	if((self = [super init])) {
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create score label
		score = [[CCLabelBMFont alloc] initWithString:@"0" fntFile:@"gamefont.fnt"];
		score.anchorPoint = ccp(1, 1);
		score.scale = 0.4;
		score.position = ccp(winSize.width, winSize.height);
		[self addChild:score];
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	[score setString:[[ScoreManager sharedSingleton] getScoreString]];
}

@end
