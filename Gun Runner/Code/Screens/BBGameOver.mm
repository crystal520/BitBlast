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
		
        [self addChild:[BBColorRectSprite spriteWithColor:ccc3(0,0,0) alpha:0.5f]];
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create background
		CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"shopConfirmBackground.png"];
		background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		[uiSpriteBatch addChild:background];
		
		// create game over label
		CCLabelBMFont *gameOverLabel = [CCLabelBMFont labelWithString:@"RUN OVER!" fntFile:@"gamefont.fnt"];
		gameOverLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.9);
		[self addChild:gameOverLabel];
		
		// create distance label
		distanceLabel = [CCLabelBMFont labelWithString:@"YOU RAN: 1234567890" fntFile:@"gamefont.fnt"];
		distanceLabel.position = ccp(background.position.x - 275 * [ResolutionManager sharedSingleton].positionScale, background.position.y + 125 * [ResolutionManager sharedSingleton].positionScale);
		distanceLabel.scale = 0.4;
		distanceLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:distanceLabel];
		
		// create kills label
		killLabel = [CCLabelBMFont labelWithString:@"KILLS: 1234567890" fntFile:@"gamefont.fnt"];
		killLabel.position = ccp(background.position.x - 275 * [ResolutionManager sharedSingleton].positionScale, background.position.y + 50 * [ResolutionManager sharedSingleton].positionScale);
		killLabel.scale = 0.4;
		killLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:killLabel];
		
		// create multiplier label
		multiplierLabel = [CCLabelBMFont labelWithString:@"MULTIPLIER: 4x" fntFile:@"gamefont.fnt" width:1228 * [ResolutionManager sharedSingleton].positionScale alignment:kCCTextAlignmentLeft];
		multiplierLabel.position = ccp(background.position.x - 275 * [ResolutionManager sharedSingleton].positionScale, background.position.y - 25 * [ResolutionManager sharedSingleton].positionScale);
		multiplierLabel.scale = 0.4;
		multiplierLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:multiplierLabel];
		
		// create score label
		/*scoreLabel = [CCLabelBMFont labelWithString:@"SCORE: 1234567890" fntFile:@"gamefont.fnt"];
		scoreLabel.position = ccp(winSize.width * 0.2, winSize.height * 0.40);
		scoreLabel.scale = 0.5;
		scoreLabel.anchorPoint = ccp(0, 0.5);
		[self addChild:scoreLabel];*/
		
		
		//////////////////////////////////////////// MENU ////////////////////////////////////////////
		// create shop label
		CCLabelBMFont *shopText = [CCLabelBMFont labelWithString:@"GUNS!" fntFile:@"gamefont.fnt"];
		shopText.scale = 0.5;
		
		// create shop button
		CCLabelButton *shop = [CCLabelButton buttonWithLabel:shopText normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(shop)];
		[shop setSpriteBatchNode:uiSpriteBatch];
		shop.position = ccp(background.position.x - 150 * [ResolutionManager sharedSingleton].positionScale, background.position.y - 126 * [ResolutionManager sharedSingleton].positionScale);
		[self addChild:shop];
		
		// create play again label
		CCLabelBMFont *playAgainText = [CCLabelBMFont labelWithString:@"RUN!" fntFile:@"gamefont.fnt"];
		playAgainText.scale = 0.5;
		
		// create play again button
		CCLabelButton *playAgain = [CCLabelButton buttonWithLabel:playAgainText normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(restartGame)];
		[playAgain setSpriteBatchNode:uiSpriteBatch];
		playAgain.position = ccp(background.position.x + 150 * [ResolutionManager sharedSingleton].positionScale, background.position.y - 126 * [ResolutionManager sharedSingleton].positionScale);
		[self addChild:playAgain];
	}
	
	return self;
}

- (void) updateFinalScore {
	[distanceLabel setString:[NSString stringWithFormat:@"YOU RAN %iM, COLLECTING", [[SettingsManager sharedSingleton] getInt:@"currentMeters"]]];
	[killLabel setString:[NSString stringWithFormat:@"%i COINS BEFORE", [[SettingsManager sharedSingleton] getInt:@"currentCoins"]]];
	[multiplierLabel setString:[self getRandomDeathMessage]];
}

- (NSString*) getRandomDeathMessage {
    // get dictionary from plist
    NSDictionary *deathMessageDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gameOverMessages" ofType:@"plist"]];
    // determine which array we should grab based on how the player died
    NSString *arrayToGrab;
    if([Globals sharedSingleton].playerReasonForDeath == kDeathEnemy) {
        arrayToGrab = @"hearts";
    }
    else if([Globals sharedSingleton].playerReasonForDeath == kDeathFall) {
        arrayToGrab = @"fall";
    }
    else if([Globals sharedSingleton].playerReasonForDeath == kDeathMiniboss) {
        arrayToGrab = @"miniboss";
    }
    else {
        arrayToGrab = @"default";
    }
    // get the death messages
    NSArray *messages = [deathMessageDictionary objectForKey:arrayToGrab];
    // return a random one
    return [messages objectAtIndex:CCRANDOM_MIN_MAX(0, [messages count])];
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
