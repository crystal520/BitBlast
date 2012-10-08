//
//  BBMedals.m
//  GunRunner
//
//  Created by Kristian Bauer on 10/8/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMedals.h"

@implementation BBMedals

- (id) init {
    if((self = [super init])) {
        [self addChild:[BBColorRectSprite spriteWithColor:ccc3(0,0,0) alpha:0.5f]];
        
        CGSize winSize = [ResolutionManager sharedSingleton].size;
        
        // create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create back button holder
		CCSprite *backHolder = [CCSprite spriteWithSpriteFrameName:@"backbuttonshell.png"];
		backHolder.position = ccp(winSize.width * 0.075, winSize.height - backHolder.contentSize.height * 0.5);
		[uiSpriteBatch addChild:backHolder z:0];
		
		// create back button
		CCLabelButton *back = [[CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton_pressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton_unpressed.png"] target:self selector:@selector(back)] retain];
		[back setSpriteBatchNode:uiSpriteBatch];
		back.position = ccp(winSize.width * 0.075, winSize.height - back.contentSize.height * 0.5 - backHolder.contentSize.height * 0.175);
		[self addChild:back z:1];
    }
    return self;
}

- (void) back {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

@end
