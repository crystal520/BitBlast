//
//  BBPause.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/20/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBPause.h"


@implementation BBPause

- (id) init {
	
	if((self = [super init])) {
        
        [self addChild:[BBColorRectSprite spriteWithColor:ccc3(0,0,0) alpha:0.5f]];
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
        
        // create background
		CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"shopConfirmBackground.png"];
		background.position = ccp(winSize.width * 0.5, winSize.height * 0.39);
		[uiSpriteBatch addChild:background];
		
		// create new game label
		CCLabelBMFont *newText = [CCLabelBMFont labelWithString:@"MAIN" fntFile:@"gamefont.fnt"];
		newText.scale = 0.5;
        
        // create gGamePause label
		CCLabelBMFont *gamePaused = [CCLabelBMFont labelWithString:@"GAME PAUSED" fntFile:@"gamefont.fnt"];
		gamePaused.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		[self addChild:gamePaused];
        		
		// create new game button
		CCLabelButton *newGameButton = [CCLabelButton buttonWithLabel:newText normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(newGame)];
		[newGameButton setSpriteBatchNode:uiSpriteBatch];
		newGameButton.position = ccp(background.position.x - 150 * [ResolutionManager sharedSingleton].positionScale, background.position.y - 126 * [ResolutionManager sharedSingleton].positionScale);
		[self addChild:newGameButton];
		
		// create resume label
		CCLabelBMFont *resumeText = [CCLabelBMFont labelWithString:@"RESUME" fntFile:@"gamefont.fnt"];
		resumeText.scale = 0.5;
		
		// create resume button
		CCLabelButton *resume = [CCLabelButton buttonWithLabel:resumeText normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(resumeGame)];
		[resume setSpriteBatchNode:uiSpriteBatch];
		resume.position = ccp(background.position.x + 150 * [ResolutionManager sharedSingleton].positionScale, background.position.y - 126 * [ResolutionManager sharedSingleton].positionScale);
		[self addChild:resume];
	}
	
	return self;
}

- (void) newGame {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

- (void) resumeGame {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavResumeNotification object:nil]];
}

@end
