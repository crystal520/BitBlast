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
		score = [[CCLabelTTF alloc] initWithString:@"0" dimensions:CGSizeMake(100, 24) alignment:CCTextAlignmentRight fontName:@"Verdana" fontSize:20.0f];
		score.position = ccp(winSize.width - (score.contentSize.width * 0.5), winSize.height - (score.contentSize.height * 0.5));
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
