//
//  BBMainMenu.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/12/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBMainMenu.h"


@implementation BBMainMenu

- (id) init {
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create play text
		CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"PLAY!" fntFile:@"gamefont.fnt"];
		
		// create play button
		CCMenuItemLabelAndImage *play = [CCMenuItemLabelAndImage itemFromLabel:playText normalImage:@"bigButton.png" selectedImage:@"bigButtonDown.png" target:self selector:@selector(play)];
		play.anchorPoint = ccp(0.5, 1);
		play.position = ccp(play.position.x, -winSize.height * 0.25);
		
		// create shop label
		CCLabelBMFont *shopText = [CCLabelBMFont labelWithString:@"SHOP" fntFile:@"gamefont.fnt"];
		
		// create shop button
		CCMenuItemLabelAndImage *shop = [CCMenuItemLabelAndImage itemFromLabel:shopText normalImage:@"smallButton.png" selectedImage:@"smallButtonDown.png" target:self selector:@selector(shop)];
		shop.label.scale = 0.5;
		shop.position = ccp(winSize.width * 0.4, winSize.height * 0.25);
		
		// create leaderboard label
		CCLabelBMFont *leaderboardText = [CCLabelBMFont labelWithString:@"LEADER\nBOARDS" fntFile:@"gamefont.fnt"];
		
		// create leaderboard button
		CCMenuItemLabelAndImage *leaderboard = [CCMenuItemLabelAndImage itemFromLabel:leaderboardText normalImage:@"smallButton.png" selectedImage:@"smallButtonDown.png" target:self selector:@selector(leaderboards)];
		leaderboard.label.scale = 0.3;
		leaderboard.position = ccp(winSize.width * 0.4, leaderboard.position.y);
		
		// create gamecenter label
		CCLabelBMFont *gamecenterText = [CCLabelBMFont labelWithString:@"GAME\nCENTER" fntFile:@"gamefont.fnt"];
		
		// create gamecenter button
		CCMenuItemLabelAndImage *gamecenter = [CCMenuItemLabelAndImage itemFromLabel:gamecenterText normalImage:@"smallButton.png" selectedImage:@"smallButtonDown.png" target:self selector:@selector(gamecenter)];
		gamecenter.label.scale = 0.3;
		gamecenter.position = ccp(winSize.width * 0.4, -winSize.height * 0.25);
		
		// create main menu with options
		CCMenu *menu = [CCMenu menuWithItems:play, shop, leaderboard, gamecenter, nil];
		[self addChild:menu];
	}
	
	return self;
}

- (void) play {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavGameNotification object:nil]];
}

- (void) shop {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopNotification object:nil]];
}

- (void) leaderboards {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavLeaderboardsNotification object:nil]];
}

- (void) gamecenter {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavGamecenterNotification object:nil]];
}

@end
