//
//  BBConfirmBuy.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBColorRectSprite.h"
#import "SettingsManager.h"
#import "BBWeaponManager.h"
#import "CCLabelButton.h"
#import "GameCenter.h"
#import "SimpleAudioEngine.h"

@interface BBConfirmBuy : CCNode {
    CCLabelBMFont *buyLabel, *cost;
	CCLabelButton *buyIt;
	NSMutableDictionary *itemDictionary;
}

- (void) updateWithInfo:(NSDictionary*)dict;

@end
