//
//  BBGameWin.m
//  GunRunner
//
//  Created by Kristian Bauer on 10/3/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBGameWin.h"

@implementation BBGameWin

- (id) init {
    if(([super init])) {
        
        CGSize winSize = [ResolutionManager sharedSingleton].size;
        
        [self addChild:[BBColorRectSprite spriteWithColor:ccc3(255,255,255) alpha:0]];
        
        // fade in a completely white screen
        CCAction *fadeAction = [CCSequence actions:[CCFadeTo actionWithDuration:3 opacity:255], [CCCallFunc actionWithTarget:self selector:@selector(showText)], nil];
        [[self getChildByTag:SPRITE_TAG_BACKGROUND] runAction:fadeAction];
        
        // set initial variables for typing out the game win text
        typeText = @"The sky trembled as the huge\nbeast collapsed under its own\nweight. The Earth is safe.\nWhatever forces brought you to\nthis alien world release you as\nyou materialize back in the\njungles of South America. This\nmonster is gone, but others\nremain. And you still have not\nfound your missing brother. Time\nto suit up and head back into the\njungle. Mayhem awaits.";
        typeCounter = 0;
        
        // add tap to continue label to screen
        tapToContinueLabel = [CCLabelBMFont labelWithString:@"TAP TO CONTINUE" fntFile:@"small.fnt"];
        tapToContinueLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.05);
        tapToContinueLabel.color = ccc3(0, 0, 0);
        tapToContinueLabel.visible = NO;
        [self addChild:tapToContinueLabel];
        
        // add blank label to screen
        gameWinLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"medium.fnt" width:winSize.width * 0.95 alignment:UITextAlignmentCenter];
        gameWinLabel.anchorPoint = ccp(0.5,1);
        gameWinLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.985);
        gameWinLabel.color = ccc3(0, 0, 0);
        [self addChild:gameWinLabel];
        
        // register for pause and resume notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPause) name:kNavPauseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoResume) name:kNavResumeNotification object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_MENU swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (void) showText {
    // let everyone know that we've reached the game win screen
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventGameWin object:nil]];
    // start typing out text
    CCAction *typeAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(updateText)], [CCDelayTime actionWithDuration:0.05], nil]];
    typeAction.tag = ACTION_TAG_TYPE;
    [self runAction:typeAction];
}

- (void) updateText {
    // increase the type counter
    typeCounter++;
    // see if the string is done being typed
    if(typeCounter >= [typeText length]) {
        [self stopActionByTag:ACTION_TAG_TYPE];
        
        // start flashing tap to continue
        if(![self getActionByTag:ACTION_TAG_FLASH]) {
            CCAction *flashAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(flashTap)], [CCDelayTime actionWithDuration:0.5], nil]];
            flashAction.tag = ACTION_TAG_FLASH;
            [self runAction:flashAction];
        }
    }
    // make sure we don't go beyond the length of the string
    typeCounter = MIN(typeCounter, [typeText length]);
    // update the label based on the type counter
    [gameWinLabel setString:[typeText substringToIndex:typeCounter]];
}

- (void) flashTap {
    tapToContinueLabel.visible = !tapToContinueLabel.visible;
}

#pragma mark -
#pragma mark notifications
- (void) gotoPause {
    [[self getChildByTag:SPRITE_TAG_BACKGROUND] pauseSchedulerAndActions];
}

- (void) gotoResume {
    [[self getChildByTag:SPRITE_TAG_BACKGROUND] resumeSchedulerAndActions];
}

#pragma mark -
#pragma mark CCTargetedTouchDelegate
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return (typeCounter > 0);
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // see if the full text should be shown
    if(typeCounter < [typeText length]) {
        typeCounter = [typeText length];
        [self updateText];
    }
    // otherwise advance to medal screen
    else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMedalsNotification object:nil]];
    }
}

@end
