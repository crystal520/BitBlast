//
//  BBMainMenu.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/12/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeColorBackground.h"
#import "CCLabelButton.h"
#import "SimpleAudioEngine.h"
#import "SettingsManager.h"
#import "BBDialogQueue.h"
#import "SessionMWrapper.h"

@interface BBMainMenu : CCNodeColorBackground {
    CCLabelBMFont *playerCash;
    CCLabelBMFont *sessionMBadgeLabel;
    CCSprite *sessionMBadge;
}

- (void) coinsUpdated;

@end
