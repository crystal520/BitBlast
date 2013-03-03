//
//  BBMedals.m
//  GunRunner
//
//  Created by Kristian Bauer on 10/8/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "BBMission.h"

@implementation BBMission

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
 
//I ADDED THIS TO TRY TO DRAW AN IMAGE ON SCREEN ON THE MEDALS AREA
    
    if((self = [super init])) {
        
        [self addChild:[BBColorRectSprite spriteWithColor:ccc3(0,0,0) alpha:0.5f]];
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];

    
    // Bruce Attempts to Add a Gamelogo.  Not sure why it does not work.
    CCSprite *gameLogo = [CCSprite spriteWithSpriteFrameName:@"gamelogo.png"];
    gameLogo.position = ccp(winSize.width * 0.5, playButtonShell.position.y + playButtonShell.contentSize.height * 0.5 + gameLogo.contentSize.height * 0.525);
    [uiSpriteBatch addChild:gameLogo z:0];
        
    }
	
	return self;
//THUS ENDS MY GOOFY DRAW AN IMAGE AREA
    
}


/*
- (void) onEnter {
    [super onEnter];
    // check to see if player can trade in
    if([[SettingsManager sharedSingleton] getBool:@"tradeIn"]) {
        [[BBDialogQueue sharedSingleton] setEnabled:YES];
        [[BBDialogQueue sharedSingleton] addDialog:[BBDialog dialogWithTitle:@"" text:@"trade in your guns and start the fun again! you will receive a unique medal of honor for your outstanding service!" buttons:@"later,trade in" target:self selector:@selector(gotoTradeIn:)]];
        [[BBDialogQueue sharedSingleton] setEnabled:NO];
    }
    else {
        // check for a new medal
        [self checkNewMedal];
    }
}

- (void) gotoTradeIn:(BBDialog*)dialog {
    // player selected LATER
    if(dialog.buttonIndex == DIALOG_BUTTON_LEFT) {
        // don't do anything
    }
    // player wants to TRADE IN
    else {
        // player can no longer trade in
        [[SettingsManager sharedSingleton] setBool:NO keyString:@"tradeIn"];
        // award new medal
        [[SettingsManager sharedSingleton] awardMedal];
        // clear out all guns except pistol
        [[SettingsManager sharedSingleton] clearWeapons];
        // save settings just in case
        [[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
        // play new medal animation
        [self checkNewMedal];
    }
}

- (void) checkNewMedal {
    // see if there's a new medal to award
    if([[SettingsManager sharedSingleton] doesExist:@"newMedal"]) {
        // get the new medal to award
        int newMedal = [[SettingsManager sharedSingleton] getInt:@"newMedal"];
        // clear the medal so it doesn't get awarded again
        [[SettingsManager sharedSingleton] clear:@"newMedal"];
        // save settings
        [[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
        NSLog(@"award medal: %i", newMedal);
    }
}
*/
@end
