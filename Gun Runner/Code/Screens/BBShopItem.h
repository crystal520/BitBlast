//
//  BBShopItem.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelButton.h"
#import "CCButton.h"
#import "BBWeaponManager.h"
#import "SimpleAudioEngine.h"

@interface BBShopItem : CCNode {
	CCButton *background;
	CCLabelButton *buy;
    CCLabelBMFont *cost;
	NSDictionary *itemDictionary;
}

- (id) initWithFile:(NSString*)filename;
- (void) touch;
- (void) buy;
- (void) viewItem;
- (void) equipItem;

@end
