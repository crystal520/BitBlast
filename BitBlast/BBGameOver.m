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
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create game over label
		CCLabelBMFont *gameOverLabel = [CCLabelBMFont labelWithString:@"GAME OVER!" fntFile:@"gamefont.fnt"];
		gameOverLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.9);
		[self addChild:gameOverLabel];
		
		// create distance label
		distanceLabel = [CCLabelBMFont labelWithString:@"DISTANCE: 1234567890" fntFile:@"gamefont.fnt"];
		distanceLabel.position = ccp(winSize.width * 0.2, winSize.height * 0.66);
		distanceLabel.scale = 0.5;
		distanceLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:distanceLabel];
		
		// create kills label
		killLabel = [CCLabelBMFont labelWithString:@"KILLS: 1234567890" fntFile:@"gamefont.fnt"];
		killLabel.position = ccp(winSize.width * 0.2, winSize.height * 0.59);
		killLabel.scale = 0.5;
		killLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:killLabel];
		
		// create multiplier label
		multiplierLabel = [CCLabelBMFont labelWithString:@"MULTIPLIER: 4x" fntFile:@"gamefont.fnt"];
		multiplierLabel.position = ccp(winSize.width * 0.2, winSize.height * 0.52);
		multiplierLabel.scale = 0.5;
		multiplierLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:multiplierLabel];
		
		// create score label
		scoreLabel = [CCLabelBMFont labelWithString:@"SCORE: 1234567890" fntFile:@"gamefont.fnt"];
		scoreLabel.position = ccp(winSize.width * 0.2, winSize.height * 0.40);
		scoreLabel.scale = 0.5;
		scoreLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:scoreLabel];
		
		
		//////////////////////////////////////////// MENU ////////////////////////////////////////////
		// create shop label
		CCLabelBMFont *shopText = [CCLabelBMFont labelWithString:@"SHOP" fntFile:@"gamefont.fnt"];
		
		// create shop button
		CCMenuItemLabelAndImage *shop = [CCMenuItemLabelAndImage itemFromLabel:shopText normalImage:@"mediumButton.png" selectedImage:@"mediumButtonDown.png" target:self selector:@selector(shop)];
		shop.label.scale = 0.5;
		shop.position = ccp(-winSize.width * 0.25, -winSize.height * 0.3);
		
		// create play again label
		CCLabelBMFont *playAgainText = [CCLabelBMFont labelWithString:@"PLAY AGAIN" fntFile:@"gamefont.fnt"];
		
		// create play again button
		CCMenuItemLabelAndImage *playAgain = [CCMenuItemLabelAndImage itemFromLabel:playAgainText normalImage:@"mediumButton.png" selectedImage:@"mediumButtonDown.png" target:self selector:@selector(restartGame)];
		playAgain.label.scale = 0.5;
		playAgain.position = ccp(winSize.width * 0.25, -winSize.height * 0.3);
		
		// create menu
		CCMenu *menu = [CCMenu menuWithItems:shop, playAgain, nil];
		[self addChild:menu];
	}
	
	return self;
}

- (void) updateFinalScore {
	//[distanceLabel setString:[NSString stringWithFormat:@"DISTANCE: %i", [[ScoreManager sharedSingleton] getScore]]];
}

- (void) shop {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopNotification object:nil]];
}

- (void) restartGame {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kGameRestartNotification object:nil]];
}

@end
