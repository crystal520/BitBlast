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
        
        // create the shell for the first small button.
		CCSprite *smallButtonShell1 = [CCSprite spriteWithSpriteFrameName:@"sideButtonShell.png"];
		smallButtonShell1.position = ccp(winSize.width * 0.108, winSize.height * 0.1);
		[uiSpriteBatch addChild:smallButtonShell1];
        
        // Bruce add The 2nd small shells for all the buttons.
		CCSprite *smallButtonShell2 = [CCSprite spriteWithSpriteFrameName:@"sideButtonShell.png"];
		smallButtonShell2.position = ccp(winSize.width * 0.108, smallButtonShell1.position.y + smallButtonShell2.contentSize.height * 0.977);
		[uiSpriteBatch addChild:smallButtonShell2 z:0];
        
        // Bruce add The 3nd small shells for all the buttons.
		CCSprite *smallButtonShell3 = [CCSprite spriteWithSpriteFrameName:@"sideButtonShell.png"];
		smallButtonShell3.position = ccp(winSize.width * 0.108, smallButtonShell2.position.y + smallButtonShell3.contentSize.height * 0.977);
		[uiSpriteBatch addChild:smallButtonShell3 z:0];
        
        // Bruce add The 4th small shells for all the buttons.
		CCSprite *smallButtonShell4 = [CCSprite spriteWithSpriteFrameName:@"sideButtonShell.png"];
		smallButtonShell4.position = ccp(winSize.width * 0.892, winSize.height * 0.1);
		[uiSpriteBatch addChild:smallButtonShell4 z:0];
        
        // Bruce add The 5th small shells for all the buttons.
		CCSprite *smallButtonShell5 = [CCSprite spriteWithSpriteFrameName:@"sideButtonShell.png"];
		smallButtonShell5.position = ccp(winSize.width * 0.892, smallButtonShell4.position.y + smallButtonShell5.contentSize.height * 0.977);
		[uiSpriteBatch addChild:smallButtonShell5 z:0];
        
        // Bruce add The 6th small shells for all the buttons.
		CCSprite *smallButtonShell6 = [CCSprite spriteWithSpriteFrameName:@"sideButtonShell.png"];
		smallButtonShell6.position = ccp(winSize.width * 0.892, smallButtonShell5.position.y + smallButtonShell6.contentSize.height * 0.977);
		[uiSpriteBatch addChild:smallButtonShell6 z:0];
        
        // Add Syphus Logo
		CCButton *musicBySyphus = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"musicby.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"musicByPressed.png"] target:self selector:@selector(gotoSyphus)];
		[musicBySyphus setSpriteBatchNode:uiSpriteBatch];
		musicBySyphus.position = ccp(winSize.width * 0.108, smallButtonShell1.position.y + musicBySyphus.contentSize.height * 0.23);
		[self addChild:musicBySyphus z:0];
		
		// create shop label
		CCLabelBMFont *shopText = [CCLabelBMFont labelWithString:@"GUNS" fntFile:@"gamefont.fnt"];
		shopText.scale = 0.44;
		
		// create shop button
		CCLabelButton *shop = [CCLabelButton buttonWithLabel:shopText normalSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_pressed.png"] target:self selector:@selector(shop)];
		[shop setSpriteBatchNode:uiSpriteBatch];
		shop.position = ccp(winSize.width * 0.892, smallButtonShell6.position.y + shop.contentSize.height * 0.23);
		[self addChild:shop];
		
		// create leaderboard label
		CCLabelBMFont *leaderboardText = [CCLabelBMFont labelWithString:@"LEADER\nBOARDS" fntFile:@"gamefont.fnt"];
		leaderboardText.scale = 0.30;
		
		// create leaderboard button
		CCLabelButton *leaderboard = [CCLabelButton buttonWithLabel:leaderboardText normalSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"bluebutton_pressed.png"] target:self selector:@selector(leaderboards)];
		[leaderboard setSpriteBatchNode:uiSpriteBatch];
		leaderboard.position = ccp(winSize.width * 0.108, smallButtonShell2.position.y + leaderboard.contentSize.height * 0.23);
		[self addChild:leaderboard];
		
		// create gamecenter button
		CCButton *gamecenter = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"gamecenter_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"gamecenter_pressed.png"] target:self selector:@selector(gamecenter)];
		[gamecenter setSpriteBatchNode:uiSpriteBatch];
		gamecenter.position = ccp(winSize.width * 0.108, smallButtonShell3.position.y + gamecenter.contentSize.height * 0.23);
		[self addChild:gamecenter];
		
		// create money label
		playerCash = [CCLabelBMFont labelWithString:@"$0" fntFile:@"gamefont.fnt"];
		playerCash.color = ccc3(255, 215, 0);
		playerCash.scale = 0.8;
		playerCash.anchorPoint = ccp(1, 0.5);
		playerCash.position = ccp(winSize.width * 0.98, background.position.y + (520 * [ResolutionManager sharedSingleton].positionScale));
		[self addChild:playerCash];
		
		// create SessionM button
		CCButton *sessionM = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sessionMUp.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sessionMDown.png"] target:self selector:@selector(gotoSessionM)];
		[sessionM setSpriteBatchNode:uiSpriteBatch];
		sessionM.position = ccp(winSize.width * 0.5, sessionM.contentSize.height * 0.5);
		[self addChild:sessionM];
        
        // create SessionM badge
        sessionMBadge = [CCSprite spriteWithSpriteFrameName:@"sessionMBadge.png"];
        sessionMBadge.position = ccp(winSize.width * 0.5, sessionM.position.y + sessionMBadge.contentSize.height * 0.7);
        [uiSpriteBatch addChild:sessionMBadge];
        
        // create SessionM badge label
        sessionMBadgeLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [SessionMWrapper sharedSingleton].achievementCount] fntFile:@"gamefont.fnt"];
        sessionMBadgeLabel.scale = 0.5;
        sessionMBadgeLabel.position = ccp(winSize.width * 0.5, sessionMBadge.position.y + sessionMBadge.contentSize.height * 0.19);

        [self addChild:sessionMBadgeLabel];
        
        // hide the badge and label if needed
        if([SessionMWrapper sharedSingleton].achievementCount == 0) {
            sessionMBadge.visible = NO;
            sessionMBadgeLabel.visible = NO;
        }
        
        // Bruce adds a new play button shell
		CCSprite *playButtonShell = [CCSprite spriteWithSpriteFrameName:@"playButtonHolder.png"];
		playButtonShell.position = ccp(winSize.width * 0.5, sessionMBadge.position.y + sessionMBadge.contentSize.height * 0.5 + playButtonShell.contentSize.height * 0.525);
		[uiSpriteBatch addChild:playButtonShell z:0];
        
        // Bruce Attempts to Add a Gamelogo.  Not sure why it does not work.
		CCSprite *gameLogo = [CCSprite spriteWithSpriteFrameName:@"gamelogo.png"];
		gameLogo.position = ccp(winSize.width * 0.5, playButtonShell.position.y + playButtonShell.contentSize.height * 0.5 + gameLogo.contentSize.height * 0.525);
		[uiSpriteBatch addChild:gameLogo z:0];
        
        // create play text
		CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"RUN!" fntFile:@"gamefont.fnt"];
		
		// create play button
		CCLabelButton *play = [CCLabelButton buttonWithLabel:playText normalSprite:[CCSprite spriteWithSpriteFrameName:@"playbutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"playbutton_pressed.png"] target:self selector:@selector(play)];
		[play setSpriteBatchNode:uiSpriteBatch];
		play.position = ccp(winSize.width * 0.5, playButtonShell.position.y);
		[self addChild:play];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coinsUpdated) name:kEventPromoCoinsAwarded object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionMUserInfoUpdated) name:kEventSessionMUserInfoUpdated object:nil];
	}
	
	return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
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

- (void) sessionMUserInfoUpdated {
    [sessionMBadgeLabel setString:[NSString stringWithFormat:@"%i", [SessionMWrapper sharedSingleton].achievementCount]];
    sessionMBadgeLabel.visible = ([SessionMWrapper sharedSingleton].achievementCount > 0);
    sessionMBadge.visible = ([SessionMWrapper sharedSingleton].achievementCount > 0);
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

- (void) gotoSessionM {
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
    [[SessionMWrapper sharedSingleton] openSessionM];
}

@end
