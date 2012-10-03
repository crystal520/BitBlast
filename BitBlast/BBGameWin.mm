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
    if(([super initWithColor:ccc3(255, 255, 255) withAlpha:0])) {
        // fade in a completely white screen
        CCAction *fadeAction = [CCSequence actions:[CCFadeTo actionWithDuration:3 opacity:255], [CCCallFunc actionWithTarget:self selector:@selector(showText)], nil];
        [[self getChildByTag:SPRITE_TAG_BACKGROUND] runAction:fadeAction];
        
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

- (void) showText {
    // let everyone know that we've reached the game win screen
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventGameWin object:nil]];
    // for now, just go to the main menu
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

#pragma mark -
#pragma mark notifications
- (void) gotoPause {
    [[self getChildByTag:SPRITE_TAG_BACKGROUND] pauseSchedulerAndActions];
}

- (void) gotoResume {
    [[self getChildByTag:SPRITE_TAG_BACKGROUND] resumeSchedulerAndActions];
}

@end
