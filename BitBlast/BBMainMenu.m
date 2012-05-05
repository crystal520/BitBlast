//
//  BBMainMenu.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/12/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBMainMenu.h"
#import "AppDelegate.h"

@implementation BBMainMenu

- (id) init {
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create background
		CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"mainmenushell.png"];
		background.position = ccp(winSize.width * 0.5, background.contentSize.height * 0.5);
		[uiSpriteBatch addChild:background];
       
		// Bruce Attempts to Add a Gamelogo.  Not sure why it does not work.
		CCSprite *gameLogo = [CCSprite spriteWithSpriteFrameName:@"gamelogo.png"];
		gameLogo.position = ccp(winSize.width * 0.4, background.position.y + gameLogo.contentSize.height * 0.7);
		[uiSpriteBatch addChild:gameLogo z:0];
        
        // Add Syphus Logo
		CCButton *musicBySyphus = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"musicby.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"musicby.png"] target:self selector:@selector(gotoSyphus)];
		[musicBySyphus setSpriteBatchNode:uiSpriteBatch];
		musicBySyphus.position = ccp(winSize.width * 0.1, winSize.height - musicBySyphus.contentSize.height * 0.55);
		[self addChild:musicBySyphus z:0];
		
		// create play text
		CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"RUN!" fntFile:@"gamefont.fnt"];
		
		// create play button
		CCLabelButton *play = [CCLabelButton buttonWithLabel:playText normalSprite:[CCSprite spriteWithSpriteFrameName:@"playbutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"playbutton_pressed.png"] target:self selector:@selector(play)];
		[play setSpriteBatchNode:uiSpriteBatch];
		play.position = ccp(background.position.x - (80 * [ResolutionManager sharedSingleton].positionScale), background.position.y - (144 * [ResolutionManager sharedSingleton].positionScale));
		[self addChild:play];
		
		// create shop label
		CCLabelBMFont *shopText = [CCLabelBMFont labelWithString:@"GUNS" fntFile:@"gamefont.fnt"];
		shopText.scale = 0.48;
		
		// create shop button
		CCLabelButton *shop = [CCLabelButton buttonWithLabel:shopText normalSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_pressed.png"] target:self selector:@selector(shop)];
		[shop setSpriteBatchNode:uiSpriteBatch];
		shop.position = ccp(background.position.x + (296 * [ResolutionManager sharedSingleton].positionScale), background.position.y + (216 * [ResolutionManager sharedSingleton].positionScale));
		[self addChild:shop];
		
		// create leaderboard label
		CCLabelBMFont *leaderboardText = [CCLabelBMFont labelWithString:@"LEADER\nBOARDS" fntFile:@"gamefont.fnt"];
		leaderboardText.scale = 0.34;
		
		// create leaderboard button
		CCLabelButton *leaderboard = [CCLabelButton buttonWithLabel:leaderboardText normalSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_pressed.png"] target:self selector:@selector(leaderboards)];
		[leaderboard setSpriteBatchNode:uiSpriteBatch];
		leaderboard.position = ccp(background.position.x + (296 * [ResolutionManager sharedSingleton].positionScale), background.position.y + (36 * [ResolutionManager sharedSingleton].positionScale));
		[self addChild:leaderboard];
		
		// create gamecenter button
		CCButton *gamecenter = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"gamecenter_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"gamecenter_pressed.png"] target:self selector:@selector(gamecenter)];
		[gamecenter setSpriteBatchNode:uiSpriteBatch];
		gamecenter.position = ccp(background.position.x + (296 * [ResolutionManager sharedSingleton].positionScale), background.position.y - (142 * [ResolutionManager sharedSingleton].positionScale));
		[self addChild:gamecenter];
		
		// create money label
		playerCash = [CCLabelBMFont labelWithString:@"$0" fntFile:@"gamefont.fnt"];
		playerCash.color = ccc3(255, 215, 0);
		playerCash.scale = 0.5;
		playerCash.anchorPoint = ccp(1, 0.5);
		playerCash.position = ccp(winSize.width * 0.46, background.position.y - (10 * [ResolutionManager sharedSingleton].positionScale));
		[self addChild:playerCash];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coinsUpdated) name:kEventPromoCoinsAwarded object:nil];
	}
	
	return self;
}

- (void) onEnter {
	[super onEnter];
	// enable dialog queue
	[[BBDialogQueue sharedSingleton] setEnabled:YES];
	[self coinsUpdated];
}

- (void) onExit {
	[super onExit];
	// disable dialog queue
	[[BBDialogQueue sharedSingleton] setEnabled:NO];
}

- (void) coinsUpdated {
	// update player's money dollars
	[playerCash setString:[NSString stringWithFormat:@"$%i", [[SettingsManager sharedSingleton] getInt:@"totalCoins"]]];
}

- (void) play {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavGameNotification object:nil]];
}

- (void) shop {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopNotification object:nil]];
}

- (void) leaderboards {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavLeaderboardsNotification object:nil]];
}

- (void) gamecenter {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavAchievementsNotification object:nil]];
}

- (void) gotoSyphus {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.syphus.net"]];
}

@end
