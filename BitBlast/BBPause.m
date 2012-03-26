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
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
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
        		
		// create new game button
		CCLabelButton *new = [CCLabelButton buttonWithLabel:newText normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(newGame)];
		[new setSpriteBatchNode:uiSpriteBatch];
		new.position = ccp(winSize.width * 0.35, winSize.height * 0.2);
		[self addChild:new];
		
		// create resume label
		CCLabelBMFont *resumeText = [CCLabelBMFont labelWithString:@"RESUME" fntFile:@"gamefont.fnt"];
		resumeText.scale = 0.5;
		
		// create resume button
		CCLabelButton *resume = [CCLabelButton buttonWithLabel:resumeText normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(resumeGame)];
		[resume setSpriteBatchNode:uiSpriteBatch];
		resume.position = ccp(winSize.width * 0.65, winSize.height * 0.2);
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
