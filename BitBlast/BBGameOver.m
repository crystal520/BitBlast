//
//  BBGameOver.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/3/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBGameOver.h"


@implementation BBGameOver

- (id) init {
	if((self = [super init])) {
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create faded background
		CCSprite *background = [CCSprite spriteWithFile:@"white.png" rect:CGRectMake(0, 0, winSize.width, winSize.height)];
		background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		background.color = ccc3(0, 0, 0);
		background.opacity = 128;
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[background.texture setTexParameters:&params];
		[self addChild:background];
		
		// create game over label
		CCLabelBMFont *gameOverLabel = [CCLabelBMFont labelWithString:@"GAME OVER" fntFile:@"gamefont.fnt"];
		gameOverLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.75);
		[self addChild:gameOverLabel];
		
		// create final score label
		finalScoreLabel = [CCLabelBMFont labelWithString:[[ScoreManager sharedSingleton] getScoreString] fntFile:@"gamefont.fnt"];
		finalScoreLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		[self addChild:finalScoreLabel];
		
		// create restart button
		CCMenuItemImage *restart = [CCMenuItemImage itemFromNormalImage:@"restart.png" selectedImage:@"restartDown.png" target:self selector:@selector(restartGame)];
		CCMenu *menu = [CCMenu menuWithItems:restart, nil];
		menu.position = ccp(winSize.width * 0.5, winSize.height * 0.25);
		[self addChild:menu];
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) updateFinalScore {
	[finalScoreLabel setString:[[ScoreManager sharedSingleton] getScoreString]];
}

- (void) restartGame {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kGameRestartNotification object:nil]];
}

@end
