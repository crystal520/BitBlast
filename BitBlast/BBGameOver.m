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
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
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
		shopText.scale = 0.5;
		
		// create shop button
		CCLabelButton *shop = [CCLabelButton buttonWithLabel:shopText normalSprite:[CCSprite spriteWithSpriteFrameName:@"mediumButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mediumButtonDown.png"] target:self selector:@selector(shop)];
		[shop setSpriteBatchNode:uiSpriteBatch];
		shop.position = ccp(winSize.width * 0.3, winSize.height * 0.2);
		[self addChild:shop];
		
		// create play again label
		CCLabelBMFont *playAgainText = [CCLabelBMFont labelWithString:@"PLAY AGAIN" fntFile:@"gamefont.fnt"];
		playAgainText.scale = 0.5;
		
		// create play again button
		CCLabelButton *playAgain = [CCLabelButton buttonWithLabel:playAgainText normalSprite:[CCSprite spriteWithSpriteFrameName:@"mediumButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mediumButtonDown.png"] target:self selector:@selector(restartGame)];
		[playAgain setSpriteBatchNode:uiSpriteBatch];
		playAgain.position = ccp(winSize.width * 0.7, winSize.height * 0.2);
		[self addChild:playAgain];
	}
	
	return self;
}

- (void) updateFinalScore {
	[distanceLabel setString:[NSString stringWithFormat:@"DISTANCE: %i", [[SettingsManager sharedSingleton] getInt:@"currentMeters"]]];
	[killLabel setString:[NSString stringWithFormat:@"COINS: %i", [[SettingsManager sharedSingleton] getInt:@"currentCoins"]]];
	[multiplierLabel setString:[NSString stringWithFormat:@"TOTAL COINS: %i", [[SettingsManager sharedSingleton] getInt:@"totalCoins"]]];
}

- (void) shop {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopNotification object:nil]];
}

- (void) restartGame {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kGameRestartNotification object:nil]];
}

@end
